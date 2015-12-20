*
*       amiga_draw.s - optimized rendering
*       by Aki Laukkanen <amlaukka@cc.helsinki.fi>
*
*       This file is public domain.
*

		mc68020

		INCDIR AINCLUDE:

		include "exec/types.i"
		include "exec/funcdef.i"
		include "exec/exec_lib.i"

;-----------------------------------------------------------------------

SCREENWIDTH	equ	320

FRACBITS	equ	16
FRACUNIT	equ	(1<<FRACBITS)

*
*       global functions
*

 
		xdef	_V_DrawPatch
		xdef	@V_DrawPatch
		xdef	_V_DrawPatchDirect
		xdef	@V_DrawPatchDirect

*
*       needed symbols/labels
*

		xref	_SysBase
		XDEF	_SCREENWIDTH
		xref	_SCREENHEIGHT
		xref    _dc_yl
		xref    _dc_yh
		xref    _dc_x
		xref    _columnofs
;;		xref    _ylookup
		xref    _ylookup2
		xref    _dc_iscale
		xref    _centery
		xref    _dc_texturemid
		xref    _dc_source
		xref    _dc_colormap
		xref    _ds_xfrac
		xref    _ds_yfrac
		xref    _ds_x1
		xref    _ds_y
		xref    _ds_x2
		xref    _ds_xstep
		xref    _ds_ystep
		xref    _ds_source
		xref    _ds_colormap
		xref    _fuzzoffset
		xref	_fuzzpos
		xref	_viewheight
		xref    _dc_translation
		xref	_colormaps

_SCREENWIDTH:	dc.l	320
;-----------------------------------------------------------------------
		section	text,code

		;near	a4,-2

; low detail drawing functions
 
;-----------------------------------------------------------------------
; V_DrawPatch (in v_video.c) by Arto Huusko <arto.huusko@pp.qnet.fi>

		xref	_I_VideoBuffer	 

		xref	_V_MarkRect

		STRUCTURE	patch,0
		 WORD	width
		 WORD	height
		 WORD	leftoffset
		 WORD	topoffset
		 STRUCT	columnofs,9*4	;nine ints
		LABEL	patch_size

;width		equ	0
;height		equ	2
;leftoffset	equ	4
;topoffset	equ	6
;columnofs	equ	8
;patch_size	equ	8+(9*4)

column_t
		STRUCTURE	column,0
		 BYTE	topdelta
		 BYTE	length
		LABEL	column_size

;topdelta	equ	0
;length		equ	1
;column_size	equ	2

		cnop	0,4
_V_DrawPatch:
@V_DrawPatch:
_V_DrawPatchDirect:
@V_DrawPatchDirect:
		movem.l	d3-d6/a2/a3/a5,-(sp)

		move.l	d0,d3	;x
		move.l	d1,d4	;y.. scrn in (sp), patch in a0

		move.l	a0,a2	;Store patch
		moveq	#0,d0
		move.w	topoffset,d0
		rol.w	#8,d0	;SWAPSHORT
		ext.l	d0
		sub.l	d0,d4
		moveq	#0,d0
		move.w	leftoffset,d0
		rol.w	#8,d0	;SWAPSHORT
		ext.l	d0
		sub.l	d0,d3

		move.l	32(sp),d6
		bne.b	.vd_ScrnOK
		move.l	d3,d0
		move.l	d4,d1
		moveq	#0,d5
		move.w	height(a2),d5
		rol.w	#8,d5
		move.l	d5,-(sp)
		move.w	width(a2),d5
		rol.w	#8,d5
		move.l	d5,-(sp)
		jsr	(_V_MarkRect)
		addq.l	#8,sp

.vd_ScrnOK:
		lea	_I_VideoBuffer,a0
		move.l	(a0,d6.l*4),d5
;Peter... change here (quite obvious)
		muls.l	_SCREENWIDTH,d4	;y not needed further
		add.l	d3,d5	;+x
		add.l	d4,d5	;+y*SCREENWIDTH

		;D3=x, D5=desttop,
		moveq	#0,d6
		move.w	width,d6
		rol.w	#8,d6	;SWAPSHORT
		;D6=w
		subq.l	#1,d6	;for ; col<w
		lea	columnofs,a3	;prepare for columnofs[col]

.vd_Loop:
		move.l	(a3)+,d0
		rol.w	#8,d0
		swap	d0
		rol.w	#8,d0		;three instructions for SWAPLONG
		move.l	a2,a5		;column=patch+
		add.l	d0,a5		;... SWAPLONG(patch->columnofs[col])

		cmp.b	#$FF,(a5)
		beq.b	.vdl_Next	;last column

.vdl_Loop:
		move.l	d5,a1		;dest=desttop + 

;... here are the other references to SCREENWIDTH
;	lsl.l #8,x + lsl.l #6,x is equal to 256x+64x=320x

		moveq	#0,d0
		move.b	(a5),d0		;column->topdelta*
;;;		move.l	d0,d1	;!
;;;		lsl.l	#8,d0	;!
;;;		lsl.l	#6,d1	;!
;;;		add.l	d0,a1	;!
;;;		add.l	d1,a1	;!

		muls.l	_SCREENWIDTH,d0
		add.l	d0,a1

		move.b	1(a5),d0
		addq.l	#3,a5		;source
		;Would it be possible to use the code from DrawColumn functions by Aki
		;here, too??
.vdl_DrawLoop:
		move.b	(a5)+,(a1)
		add.l	_SCREENWIDTH,a1
		subq.b	#1,d0
		bne.b	.vdl_DrawLoop

		addq.l	#1,a5		;bump to next column..
		;bumped already by three and length, so one more. (column +=column->length+4)

		cmp.b	#$FF,(a5)
		bne.b	.vdl_Loop

.vdl_Next:
		addq.l	#1,d5

		dbf		d6,.vd_Loop
.vd_exit:
		movem.l	(sp)+,d3-d6/a2/a3/a5

		rts

;void
;V_DrawPatch
;( int		x,
;  int		y,
;  int		scrn,
;  patch_t*	patch ) 
;{ 
;
;    int		count;
;    int		col; 
;    column_t*	column; 
;    byte*	desttop;
;    byte*	dest;
;    byte*	source; 
;    int		w; 
;	 
;    y -= SWAPSHORT(patch->topoffset); 
;    x -= SWAPSHORT(patch->leftoffset); 
; 
;    col = 0; 
;    desttop = screens[scrn]+y*SCREENWIDTH+x; 
;	 
;    w = SWAPSHORT(patch->width); 
;
;    for ( ; col<w ; x++, col++, desttop++)
;    { 
;	column = (column_t *)((byte *)patch + SWAPLONG(patch->columnofs[col])); 
; 
;	// step through the posts in a column 
;	while (column->topdelta != 0xff ) 
;	{ 
;	    source = (byte *)column + 3; 
;	    dest = desttop + column->topdelta*SCREENWIDTH; 
;	    count = column->length; 
;			 
;	    while (count--) 
;	    { 
;		*dest = *source++; 
;		dest += SCREENWIDTH; 
;	    } 
;	    column = (column_t *)(  (byte *)column + column->length 
;				    + 4 ); 
;	}
;    }
;    if (!scrn)
;	I_MarkRect (x, y, SWAPSHORT(patch->width), SWAPSHORT(patch->height)); 
;
;} 

;***********************************************************************

		end
