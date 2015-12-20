	MACHINE 68020
	FPU

	INCDIR AINCLUDE:
	
	include "r_engine.i"
	include "doom.i"
	
	XREF	_I_Error
	XREF	_R_MapPlane
 
	XREF	_xtoviewangle	 
 	XREF	_lumpcache
	XREF	_spanstart
	XREF	_cachedheight
	XREF	_cacheddistance
	XREF	_cachedxstep
	XREF	_cachedystep
	XREF	_distscale
	XREF	_finesine
	XREF	_numnodes
	XREF	_subsectors
    XREF	_tantoangle
	XREF	_viewx
	XREF	_viewy	    
	XREF	_nodestab
	XREF	_WW_CacheLumpNum		
	SECTION	r_engine,CODE
 



 

;/***************************************************/
;/*                                                 */
;/*       R_MAIN                                    */
;/*                                                 */
;/***************************************************/

;/*= SlopeDiv ======================================================================*/


SLOPEDIV MACRO
	cmp.l		#512,\2
	blo.s		.\@raus

	lsr.l		#8,\2
	lsl.l		#3,\1
	divul.l		\2,\1:\1

	cmp.l		#SLOPERANGE+1,\1
	blo.s		.\@raus2

.\@raus:
	move.l		#SLOPERANGE,\1
.\@raus2:	
	ENDM

;/*===== R_PointToAngle =================================================*/

	XDEF	_R_PointToAngle
	XDEF	_R_PointToAngle_ASM
	CNOP	0,4

_R_PointToAngle:
	movem.l	4(sp),d0/d1
_R_PointToAngle_ASM:
	sub.l	_viewx,d0
	sub.l	_viewy,d1
	bne.s	.weiter
	tst.l	d0
	bne.s	.weiter
	moveq	#0,d0
	rts
	
.weiter:
	tst.l	d0
	blt.s	.xkleinernull
	tst.l	d1
	blt.s	.ykleinernull
	
;x>=0 und y>=0:

	cmp.l	d1,d0
	ble.s	.xkleinergleichy

;octant 0 = tantoangle[s(y,x)]
	
	SLOPEDIV	D1,D0

	lea		_tantoangle,a0
	move.l	(a0,d1.l*4),d0
	rts
	
.xkleinergleichy:

;octant1 = ANG90 - 1 - tantoangle[s(x,y)]
	
	SLOPEDIV	D0,D1

	move.l	#ANG90-1,d1
	lea		_tantoangle,a0
	sub.l	(a0,d0.l*4),d1
	move.l	d1,d0
	rts

.ykleinernull:
	neg.l	d1
	cmp.l	d1,d0
	ble.s	.xkleinergleichy2
	
; octant 8 = -tantoangle[s(y,x)]

	SLOPEDIV	d1,d0

	lea		_tantoangle,a0
	move.l	(a0,d1.l*4),d0
	neg.l	d0
	rts

.xkleinergleichy2:

; octant 7 = ANG270 + tantoangle[s(x,y)]

	SLOPEDIV	d0,d1
	
	lea		_tantoangle,a0
	move.l	(a0,d0.l*4),d0
	add.l	#ANG270,d0
	rts
		
.xkleinernull:
	neg.l	d0
	
	tst.l	d1
	blt.s	.ykleinernull2
	
	cmp.l	d1,d0
	ble.s	.xkleinergleichy3
	
	;octant 3 = ANG180 - 1 - tantoangle[s(y,x)]

	SLOPEDIV	d1,d0

	lea		_tantoangle,a0
	move.l	#ANG180-1,d0
	sub.l	(a0,d1.l*4),d0
	rts
	
.xkleinergleichy3:

	; octant 2 = ANG90 + tantoangle[s(x,y)]

	SLOPEDIV	d0,d1
	
	lea		_tantoangle,a0
	move.l	(a0,d0.l*4),d0
	add.l	#ANG90,d0
	rts


.ykleinernull2:
	neg.l	d1
	
	cmp.l	d1,d0
	ble.s	.xkleinergleichy4
	
	;octant 4 = ANG180 + tantoangle[s(y,x)]
	
	SLOPEDIV	d1,d0
	
	lea		_tantoangle,a0
	move.l	(a0,d1.l*4),d0
	add.l	#ANG180,d0
	rts

.xkleinergleichy4:
	
	;octant 5 = ANG270 - 1 - tantoangle[s(x,y)]
	
	SLOPEDIV	d0,d1
	
	lea		_tantoangle,a0
	move.l	#ANG270-1,d1
	sub.l	(a0,d0.l*4),d1
	move.l	d1,d0
	rts
	
	XDEF	_R_PointInSubsector
	CNOP	0,4
	
_R_PointInSubsector:		;'(fixed_t x, fixed_t y)
;//    node_t*	node;
;//    int		side;
;//    int		nodenum;
;//
	movem.l	a2/d2-d7,-(sp)

;//    /* single subsector is a special case*/

;//    if (!numnodes)				
;//	return subsectors;
	move.l	_numnodes,d4
	beq.s		.nonodes
		
;//    nodenum = numnodes-1;

	subq		#1,d4
	btst		#NFB_SUBSECTOR,d4
	bne.s		.whiledone
	
	move.l	_nodestab,a2
	movem.l	7*4+4(sp),d5/d6		;'d5 = x
											;'d6 = y

;//    while (! (nodenum & NF_SUBSECTOR) )
;//    {
.while:
;//	node = &nodes[nodenum];
	move.l	(a2,d4.w*4),a0
	
	move.l	d5,d0
	move.l	d6,d1
			
;//	side = R_PointOnSide (x, y, node);
	tst.l		8(a0)
	bne.s		.1

	cmp.l		(a0),d0
	bgt.s		.2

	tst.l		12(a0)
	bgt.s		.3

.return0:
	move		nd_children(a0),d4
	bra.s		.9

.return1:
.3:
	move		nd_children+2(a0),d4
	bra.s		.9

.2:
	tst.l		12(a0)
	blt.s		.return1
	move		nd_children(a0),d4
	bra.s		.9
	
.1:
	tst.l		12(a0)
	bne.s		.5
	
	cmp.l		4(a0),d1
	bgt.s		.6
	
	tst.l		8(a0)
	blt.s		.return1
	move		nd_children(a0),d4
	bra.s		.9
	
.6:
	tst.l		8(a0)
	bgt.s		.return1
	move		nd_children(a0),d4
	bra.s		.9

.5:
	sub.l		(a0),d0
	sub.l		4(a0),d1
	
	move.l	d0,d2
	eor.l		d1,d2
	move.l	8(a0),d3
	eor.l		d3,d2
	move.l	12(a0),d3
	eor.l		d3,d2
	bpl.s		.33
	
	eor.l		d3,d0
	bpl.s		.return0
	
	move		nd_children+2(a0),d4
	bra.s		.9

.33:
	move		12(a0),d2
	ext.l		d2

	IFND	version060

	muls.l	d2,d2:d0
	move	d2,d0
	swap	d0

	ELSE

	fmove.l	d0,fp0
	fmul.l	d2,fp0
	fmul.x	fp7,fp0
	fmove.l	fp0,d0

	ENDC

	move		8(a0),d2
	ext.l		d2

	IFND	version060

	muls.l	d2,d2:d1
	move		d2,d1
	swap		d1

	ELSE

	fmove.l	d1,fp0
	fmul.l	d2,fp0
	fmul.x	fp7,fp0
	fmove.l	fp0,d1
	
	ENDC
	
	cmp.l		d0,d1
	blt.s		.return0

	move		nd_children+2(a0),d4
	
.9:

;//	nodenum = node->children[side];

;//    }
	btst		#NFB_SUBSECTOR,d4
	beq.s		.while

.whiledone:
;//    return &subsectors[nodenum & ~NF_SUBSECTOR];
	bclr		#NFB_SUBSECTOR,d4
	move.l	_subsectors,d0
	lsl.l		#3,d4
	add.l		d4,d0
	movem.l	(sp)+,a2/d2-d7
	rts
	
.nonodes:
	move.l	_subsectors,d0
	movem.l	(sp)+,a2/d2-d7
	rts

		
;/*= R_DrawColumn =================================================================*/

	XDEF _R_DrawColumn
	XDEF _R_DrawColumn_Check

	CNOP	0,4

_R_DrawColumn_Check:
_R_DrawColumn:
		movem.l d3-d4/d6-d7/a2/a3,-(sp)

		move.l  _dc_yh(pc),d7     ; count = _dc_yh - _dc_yl
		move.l  _dc_yl(pc),d0
		sub.l   d0,d7
		bmi.w   dc_end8

		move.l  _dc_x(pc),d1      ; dest = ylookup[_dc_yl] + columnofs[_dc_x]
		lea     _ylookup(pc),a0
		move.l  (a0,d0.l*4),a0
		lea     _columnofs(pc),a1
		add.l   (a1,d1.l*4),a0

		move.l  _dc_colormap(pc),d4
		move.l  _dc_source(pc),a1

		move.l  _dc_iscale(pc),d1 ; frac = _dc_texturemid + (_dc_yl-centery)*fracstep
		sub.l   _centery(pc),d0
		muls.l  d1,d0
		add.l   _dc_texturemid(pc),d0

		moveq   #$7f,d3

__RESPATCH6:
		lea     (SCREENWIDTH*4).w,a3

; d7: cnt >> 2
; a0: chunky
; a1: texture
; d0: frac  (uuuu uuuu uuuu uuuu 0000 0000 0UUU UUUU)
; d1: dfrac (.......................................)
; d3: $7f
; d4: light table aligned to 256 byte boundary
; a3: SCREENWIDTH

		move.l  d7,d6
		and.w   #3,d6

		swap    d0              ; swap decimals and fraction
		swap    d1

		add.w   dc_width_tab8(pc,d6.w*2),a0
		lsr.w   #2,d7
		move.w  dc_tmap_tab8(pc,d6.w*2),d6

		and.w   d3,d0
		sub.w   d1,d0
		add.l   d1,d0           ; setup the X flag

		jmp	dc_loop8(pc,d6.w)

		cnop    0,4

__RESPATCH7:
dc_width_tab8
		dc.w    -3*SCREENWIDTH
		dc.w    -2*SCREENWIDTH
		dc.w    -1*SCREENWIDTH
		dc.w    0
dc_tmap_tab8
		dc.w    dc_08-dc_loop8
		dc.w    dc_18-dc_loop8
		dc.w    dc_28-dc_loop8
		dc.w    dc_38-dc_loop8
dc_loop8
dc_38
		move.b  (a1,d0.w),d4
		addx.l  d1,d0
		move.l  d4,a2
		and.w   d3,d0
		move.b  (a2),(a0)
dc_28
		move.b  (a1,d0.w),d4
		addx.l  d1,d0
		move.l  d4,a2
		and.w   d3,d0
		
__RESPATCH8:
		move.b  (a2),SCREENWIDTH(a0)
dc_18
		move.b  (a1,d0.w),d4
		addx.l  d1,d0
		move.l  d4,a2
		and.w   d3,d0
		
__RESPATCH9:
		move.b  (a2),SCREENWIDTH*2(a0)
dc_08
		move.b  (a1,d0.w),d4
		addx.l  d1,d0
		move.l  d4,a2
		and.w   d3,d0

__RESPATCH10:
		move.b  (a2),SCREENWIDTH*3(a0)

		add.l   a3,a0
.loop_end8
		dbf d7,dc_loop8
dc_end8
		movem.l (sp)+,d3-d4/d6-d7/a2/a3
		rts
	
;/*= R_DrawTranslatedColumn =======================================================*/

	XDEF	_R_DrawTranslatedColumn
	XDEF	_R_DrawTranslatedColumn_Check

	CNOP	0,4

_R_DrawTranslatedColumn_Check
_R_DrawTranslatedColumn:
  		movem.l d2-d4/d6-d7/a2/a3,-(sp)

		move.l  _dc_yh(pc),d7	; count = _dc_yh - _dc_yl
		move.l  _dc_yl(pc),d0
		sub.l   d0,d7
		bmi.w   dtc_end6

		move.l  _dc_x(pc),d1	; dest = ylookup[_dc_yl] + columnofs[_dc_x]
		lea     _ylookup(pc),a0
		move.l  (a0,d0.l*4),a0
		lea     _columnofs(pc),a1
		add.l   (a1,d1.l*4),a0

		move.l	_dc_translation(pc),d2
		move.l  _dc_colormap(pc),d4
		move.l  _dc_source(pc),a1

		move.l  _dc_iscale(pc),d1 ; frac = _dc_texturemid + (_dc_yl-centery)*fracstep
		sub.l   _centery(pc),d0
		muls.l  d1,d0
		add.l   _dc_texturemid(pc),d0

		moveq   #$7f,d3
		
__RESPATCH16:
		lea     (SCREENWIDTH*4).w,a3

; d7: cnt >> 2
; a0: chunky
; a1: texture
; d0: frac  (uuuu uuuu uuuu uuuu 0000 0000 0UUU UUUU)
; d1: dfrac (.......................................)
; d3: $7f
; d4: light table aligned to 256 byte boundary
; d2: translation table aligned to 256 byte boundary
; a3: SCREENWIDTH

		move.l  d7,d6
		and.w   #3,d6

		swap    d0              ; swap decimals and fraction
		swap    d1

		add.w   dtc_width_tab6(pc,d6.w*2),a0
		lsr.w   #2,d7
		move.w  dtc_tmap_tab6(pc,d6.w*2),d6

		and.w   d3,d0
		sub.w   d1,d0
		add.l   d1,d0           ; setup the X flag

		jmp 	dtc_loop6(pc,d6.w)

		cnop    0,4
		
__RESPATCH17:
dtc_width_tab6
		dc.w    -3*SCREENWIDTH
		dc.w    -2*SCREENWIDTH
		dc.w    -1*SCREENWIDTH
		dc.w    0
dtc_tmap_tab6
		dc.w    dtc_06-dtc_loop6
		dc.w    dtc_16-dtc_loop6
		dc.w    dtc_26-dtc_loop6
		dc.w    dtc_36-dtc_loop6
dtc_loop6
dtc_36
		move.b  (a1,d0.w),d2
		move.l	d2,a2
		addx.l  d1,d0
		move.b	(a2),d4
		and.w   d3,d0
		move.l  d4,a2
		move.b  (a2),(a0)
dtc_26
		move.b  (a1,d0.w),d2
		move.l	d2,a2
		addx.l  d1,d0
		move.b	(a2),d4
		and.w   d3,d0
		move.l  d4,a2
		
__RESPATCH18:
		move.b  (a2),SCREENWIDTH(a0)
dtc_16
		move.b  (a1,d0.w),d2
		move.l	d2,a2
		addx.l  d1,d0
		move.b	(a2),d4
		and.w   d3,d0
		move.l  d4,a2
		
__RESPATCH19:
		move.b  (a2),SCREENWIDTH*2(a0)
dtc_06
		move.b  (a1,d0.w),d2
		move.l	d2,a2
		addx.l  d1,d0
		move.b	(a2),d4
		and.w   d3,d0
		move.l  d4,a2

__RESPATCH20:
		move.b  (a2),SCREENWIDTH*3(a0)

		add.l   a3,a0
.loop_end6
		dbf 	d7,dtc_loop6
dtc_end6
		movem.l (sp)+,d2-d4/d6-d7/a2/a3
		rts
		
;/*= R_DrawSpan ==================================================================*/

	XDEF	_R_DrawSpan
	XDEF	_R_DrawSpan_Check

	CNOP	0,4

_R_DrawSpan_Check:
		movem.l d2-d7/a2-a4,-(sp)
		move.l  _ds_y(pc),d0
		cmp.l	_REALSCREENHEIGHT(pc),d0
		bhs.s	DrawSpan_Exit

		move.l  _ds_x1(pc),d1	; dest = ylookup[_ds_y] + columnofs[_ds_x1]
		bmi.s	DrawSpan_Exit

		lea     _ylookup(pc),a0
		move.l  (a0,d0.l*4),a0
		lea     _columnofs(pc),a1
		add.l   (a1,d1.l*4),a0
		move.l  _ds_source(pc),a1
		move.l  _ds_colormap(pc),a2
		move.l  _ds_x2(pc),d7	; count = _ds_x2 - _ds_x1
		cmp.l	d1,d7
		blt.s	DrawSpan_Exit
		
__RESPATCH43:
		cmp.l	#SCREENWIDTH,d7
		bhs.s	DrawSpan_Exit

		bra.s	DrawSpan_Common
		
		CNOP	0,4

_R_DrawSpan:    
		movem.l d2-d7/a2-a4,-(sp)
		move.l  _ds_y(pc),d0
		move.l  _ds_x1(pc),d1	; dest = ylookup[_ds_y] + columnofs[_ds_x1]
		lea     _ylookup(pc),a0
		move.l  (a0,d0.l*4),a0
		lea     _columnofs(pc),a1
		add.l   (a1,d1.l*4),a0
		move.l  _ds_source(pc),a1
		move.l  _ds_colormap(pc),a2
		move.l  _ds_x2(pc),d7	; count = _ds_x2 - _ds_x1

DrawSpan_Common:
		sub.l   d1,d7
		addq.l  #1,d7
		move.l  _ds_xfrac(pc),d0
		move.l  _ds_yfrac(pc),d1
		move.l  _ds_xstep(pc),d2
		move.l  _ds_ystep(pc),d3
		move.l  a0,d4
		btst    #0,d4
		beq.b   .skipb0
		move.l  d0,d5           ; do the unaligned pixels
		move.l  d1,d6           ; so we can write to longword
		swap    d5              ; boundary in the main loop
		swap    d6
		and.w   #$3f,d5
		and.w   #$3f,d6
		lsl.w   #6,d6
		or.w    d5,d6
		move.b  (a1,d6.w),d5
		add.l   d2,d0
		move.b  (a2,d5.w),(a0)+
		add.l   d3,d1
		move.l  a0,d4
		subq.l  #1,d7
.skipb0		btst    #1,d4
		beq.b   .skips0
		moveq   #2,d4
		cmp.l   d4,d7
		bls.b   .skips0
		move.l  d0,d5           ; write two pixels
		move.l  d1,d6
		swap    d5
		swap    d6
		and.w   #$3f,d5
		and.w   #$3f,d6
		lsl.w   #6,d6
		or.w    d5,d6
		move.b  (a1,d6.w),d5
		move.w  (a2,d5.w),d4
		add.l   d2,d0
		add.l   d3,d1
		move.l  d0,d5
		move.l  d1,d6
		swap    d5
		swap    d6
		and.w   #$3f,d5
		and.w   #$3f,d6
		lsl.w   #6,d6
		or.w    d5,d6
		move.b  (a1,d6.w),d5
		move.b  (a2,d5.w),d4
		add.l   d2,d0
		move.w  d4,(a0)+
		add.l   d3,d1
		subq.l  #2,d7
.skips0		move.l  a2,d4
		add.l   #$1000,a1       ; catch 22
		move.l  a0,a3
		add.l   d7,a3
		move.l  d7,d5
		and.b   #~3,d5
		move.l  a0,a4
		add.l   d5,a4
		eor.w   d0,d1           ; swap fraction parts for addx
		eor.w   d2,d3
		eor.w   d1,d0
		eor.w   d3,d2
		eor.w   d0,d1
		eor.w   d2,d3
		swap    d0
		swap    d1
		swap    d2
		swap    d3
		lsl.w   #6,d1
		lsl.w   #6,d3
		move.w  #$ffc0,d6
		move.w  #$f03f,d7
		lsr.w   #2,d5
		beq.b   .skip_loop20
		sub.w   d2,d0
		add.l   d2,d0           ; setup the X flag
.loop20		or.w    d6,d0
		or.w    d7,d1
		and.w   d1,d0
		addx.l  d3,d1
		move.b  (a1,d0.w),d4
		addx.l  d2,d0
		move.l  d4,a2
		move.w  (a2),d5
		or.w    d6,d0
		or.w    d7,d1
		and.w   d1,d0
		addx.l  d3,d1
		move.b  (a1,d0.w),d4
		addx.l  d2,d0
		move.l  d4,a2
		move.b  (a2),d5
		swap    d5
		or.w    d6,d0
		or.w    d7,d1
		and.w   d1,d0
		addx.l  d3,d1
		move.b  (a1,d0.w),d4
		addx.l  d2,d0
		move.l  d4,a2
		move.w  (a2),d5
		or.w    d6,d0
		or.w    d7,d1
		and.w   d1,d0
		addx.l  d3,d1
		move.b  (a1,d0.w),d4
		addx.l  d2,d0
		move.l  d4,a2
		move.b  (a2),d5
		move.l  d5,(a0)+
		cmp.l   a0,a4
		bne.b   .loop20
.skip_loop20
		sub.w   d2,d0
		add.l   d2,d0

		bra.b   .loop_end20
.loop30		or.w    d6,d0
		or.w    d7,d1
		and.w   d1,d0
		addx.l  d3,d1
		move.b  (a1,d0.w),d4
		addx.l  d2,d0
		move.l  d4,a2
		move.b  (a2),(a0)+
.loop_end20
		cmp.l   a0,a3
		bne.b   .loop30

DrawSpan_Exit:
.end20		movem.l (sp)+,d2-d7/a2-a4
		rts		
		
;/***************************************************/
;/*                                                 */
;/*       R_PLANE                                   */
;/*                                                 */
;/***************************************************/

	
	XDEF	_R_FindPlane
	CNOP	0,4

_R_FindPlane:	;//fixed_t height,int picnum,int lightlevel
	move.l	d2,-(sp)

;//    visplane_t*	check;
	
	movem.l	4+4(sp),d0-d2		;d0 = height,d1 = picnum, d2 = lightlevel
	
;//    if (picnum == skyflatnum)
;//    {
;//	height = 0;			/* all skys map together*/
;//	lightlevel = 0;
;//    }
	
	cmp.l		_skyflatnum(pc),d1
	bne.s		.picnumok
	moveq		#0,d0		;// height = 0
	moveq		#0,d2		;// lightlevel = 0
	
.picnumok:

;//    for (check=visplanes; check<lastvisplane; check++)

	move.l	_visplanes(pc),a0		;// a0 = check
	move.l	_lastvisplane(pc),a1	;// a1 = lastvisplane
	bra.s		.forentry

.for:

;//	if (height == check->height
;//	    && picnum == check->picnum
;//	    && lightlevel == check->lightlevel)
;//	{
;//	    break;
;//	}
;//    }
    
   cmp.l		vp_height(a0),d0
   bne.s		.next
   cmp.l		vp_picnum(a0),d1
   bne.s		.next
   cmp.l		vp_lightlevel(a0),d2
   beq.s		fp_found

.next:
	lea		vp_SIZEOF(a0),a0
.forentry:
	cmp.l		a1,a0
	blt.s		.for

   ;// if (lastvisplane - visplanes == MAXVISPLANES)
	;// I_Error ("R_FindPlane: no more visplanes");

	cmp.l		_maxvisplane(pc),a0
	bne.s		.stillok
	
	pea		ERRTXT_NOVISPLANES(pc)
	jsr		_I_Error
	;// does not return!!
	
.stillok
	;// lastvisplane++;

	lea		vp_SIZEOF(a1),a1
	move.l	a1,_lastvisplane
	
   ;// check->height = height;
   ;// check->picnum = picnum;
   ;// check->lightlevel = lightlevel;
   ;// check->minx = SCREENWIDTH;
   ;// check->maxx = -1;

	movem.l	d0-d2,(a0)
	;// move.l	d0,vp_height(a0)
	;// move.l	d1,vp_picnum(a0)
	;// move.l	d2,vp_lightlevel(a0)

__RESPATCH1:
	move.l	#SCREENWIDTH,vp_minx(a0)
	moveq		#-1,d0
	move.l	d0,vp_maxx(a0)
	
   ;//memset (check->top,0xff,sizeof(check->top));
   
	
	movem.l	d3/d4,-(sp)

	moveq		#-1,d2
	moveq		#-1,d3
	moveq		#-1,d4

__RESPATCH2:
	lea		SCREENWIDTH*2+vp_top(a0),a1
__RESPATCH3:
	moveq		#SCREENWIDTH*2/32,d1
	bra.s		.clrentry
	
	CNOP		0,4

.clr:
	movem.l	d0/d2/d3/d4,-(a1)
	movem.l	d0/d2/d3/d4,-(a1)
.clrentry:
	dbf		d1,.clr

	movem.l	(sp)+,d3/d4

   ;// return check;

fp_found:
;//    if (check < lastvisplane)
;//	return check;

	move.l	a0,d0
	
	move.l	(sp)+,d2
	rts



	XDEF	_R_CheckPlane
	CNOP	0,4

_R_CheckPlane:	;// visplane_t *pl,int start,int stop
	movem.l	d2-d6,-(sp)

;//    int		intrl;	d2
;//    int		intrh;	d3
;//    int		unionl;	d4
;//    int		unionh;	d5
;//    int		x;			d6
	
	move.l	4+20(sp),a0		;// a0 = pl
	movem.l	8+20(sp),d0/d1	;// d0 = start  d1 = stop

;//    if (start < pl->minx)
;//    {
;//	intrl = pl->minx;
;//	unionl = start;
;//    }

	move.l	vp_minx(a0),d2

	cmp.l		d2,d0
	bge.s		.greatereq
	
;//	move.l	vp_minx(a0),d2		;// intrl = d2 = pl->minx
	move.l	d0,d4					;// unionl = d4 = start
	bra.s		.checkstop
	
.greatereq:
;//    else
;//    {
;//	unionl = pl->minx;
;//	intrl = start;
;//    }

	move.l	d2,d4				;// unionl = d4 = pl->minx
	move.l	d0,d2				;// intrl = d2 = start

.checkstop:
;//    if (stop > pl->maxx)
;//    {
;// 	intrh = pl->maxx;
;// 	unionh = stop;
;//    }

	move.l	vp_maxx(a0),d3
	cmp.l		d3,d1
	ble.s		.lowereq
	
	;// move.l	vp_maxx(a0),d3 // intrh = d3 = pl->maxx
	move.l	d1,d5				;// unionh = d5 = stop
	bra.s		.checksdone

.lowereq:	
;//    else
;//    {
;//	unionh = pl->maxx;
;//	intrh = stop;
;//    }

	move.l	d3,d5				;// unionh = d5 = pl->maxx
	move.l	d1,d3				;// intrh = d3 = stop

.checksdone:
;//    for (x=intrl ; x<= intrh ; x++)
;//	if (pl->top[x] != 0xffff)
;//	    break;
	move.l	d2,d6				;// d6 = x = intrl
	lea		vp_top(a0,d6.w*2),a1
	bra.s		.forentry

.for:
	cmp.w		#-1,(a1)+
	bne.s		.found
	
.next:
	addq.l	#1,d6
.forentry:
	cmp.l		d3,d6
	ble.s		.for

;//    if (x > intrh)
;//   {
;//	pl->minx = unionl;
;//	pl->maxx = unionh;

;//	/* use the same one*/
;//	return pl;		
;//    }

	movem.l	d4/d5,vp_minx(a0)
	move.l	a0,d0
	
	movem.l	(sp)+,d2-d6
	rts

.found:
;//    /* make a new visplane*/
;//    lastvisplane->height = pl->height;
;//    lastvisplane->picnum = pl->picnum;
;//    lastvisplane->lightlevel = pl->lightlevel;
 
 	move.l	_lastvisplane(pc),a1
 	movem.l	(a0),d2-d4
 	move.l	a1,a0				;//pl = a0 = lastvisplane ++
 	movem.l	d2-d4,(a1)
 	
;//    pl = lastvisplane++;
;//    pl->minx = start;
;//    pl->maxx = stop;

	movem.l	d0/d1,vp_minx(a1)
	
;//    memset (pl->top,0xff,sizeof(pl->top));

	moveq		#-1,d1
	moveq		#-1,d2
	moveq		#-1,d3
	moveq		#-1,d4

__RESPATCH4:
	lea		SCREENWIDTH*2+vp_top(a0),a1
__RESPATCH5:
	moveq		#SCREENWIDTH*2/32,d0
	bra.s		.clrentry
	CNOP		0,4

.clr:
	movem.l	d1-d4,-(a1)
	movem.l	d1-d4,-(a1)
.clrentry:
	dbf		d0,.clr

;// lastvisplane++ von oben

 	lea		vp_SIZEOF(a0),a1
	move.l	a1,_lastvisplane
	
	move.l	a0,d0
	
	movem.l	(sp)+,d2-d6
	
;// return pl
	rts	
	
	XREF	_R_GenerateComposite
	CNOP	0,4	
	
R_GetColumn:	;d0 = tex  d1 = col 	
	movem.l	d2/d3/a2,-(sp)

	;/* col &= texturewidthmask[tex] */
	
	move.l	_texturewidthmask(pc),a0
	and.l		(a0,d0.w*4),d1

	;/* ofs = texturecolumnofs[tex][col] */

	move.l	_texturecolumnofs(pc),a0
	move.l	(a0,d0.w*4),a0
	moveq		#0,d2
	move.w	(a0,d1.w*2),d2

	;/* d2 = ofs */

	;/* lump = texturecolumnlump[tex][col] */
	
	move.l	_texturecolumnlump(pc),a0
	move.l	(a0,d0.w*4),a0
	moveq		#0,d3
	move.w	(a0,d1.w*2),d3

	;/* d3 = lump */
		
	;/* lump >0 ? */
	
	ble.s		.lumpkleinernull
		
	;/* return W_CacheLumpNum(lump,PU_CACHE)+ofs */
		
	move.l	_lumpcache,a0
	move.l	(a0,d3.w*4),d0
	beq.s		.nichtgecached

	move.l	d0,a0
	moveq		#PU_CACHE,d1
	move.l	d1,-16(a0)	;	/* tag -> PU_CACHE */
	add.l		d2,d0			;	/* + ofs */

	movem.l	(sp)+,d2/d3/a2
	rts		
			
.nichtgecached:
	;/* nicht gecached -> richtige (langsame) Funktion aufrufen */

	moveq		#PU_CACHE,d0
	move.l	d0,-(sp)
	move.l	d3,-(sp)
	jsr		_WW_CacheLumpNum
	addq.l	#8,sp
	add.l		d2,d0
	
	movem.l	(sp)+,d2/d3/a2
	rts
		
.lumpkleinernull:
	;/* <0: texturecomposite[tex] ? */
	
	move.l	_texturecomposite(pc),a2
	move.l	(a2,d0.w*4),d1
	beq.s		.istnull
		
	;/* return texturecomposite[tex] + ofs */
	
	move.l	d1,d0
	add.l		d2,d0

	movem.l	(sp)+,d2/d3/a2
	rts			
	
.istnull:
	;/* !texturecomposite[tex]: */

	move.l	d0,-(sp)
	lea		(a2,d0.w*4),a2
	jsr		_R_GenerateComposite
	addq.l	#4,sp
		
	move.l	(a2),d0
	add.l		d2,d0
	
	movem.l	(sp)+,d2/d3/a2
	rts
	
	
;/*******************************************************/
;/*																	  */
;/*						68060 routinen							  */
;/*																	  */
;/*******************************************************/


;/*= R_DrawColumn_060 =============================================================*/

	XDEF	_R_DrawColumn_060
	XDEF	_R_DrawColumn_060_Check
	
	CNOP	0,4
	
_R_DrawColumn_060:
_R_DrawColumn_060_Check:
		movem.l d2-d3/d5-d7/a2/a3,-(sp)

		move.l  (_dc_yh,pc),d7     ; count = _dc_yh - _dc_yl
		move.l  (_dc_yl,pc),d0
		sub.l   d0,d7
		bmi.w   dc60_end7

		move.l  (_dc_x,pc),d1      ; dest = ylookup[_dc_yl] + columnofs[_dc_x]
		lea     (_ylookup,pc),a0
		move.l  (a0,d0.l*4),a0
		lea     (_columnofs,pc),a1
		add.l   (a1,d1.l*4),a0

		move.l  (_dc_colormap,pc),a2
		move.l  (_dc_source,pc),a1

		move.l  (_dc_iscale,pc),d1 ; frac = _dc_texturemid + (_dc_yl-centery)*fracstep
		sub.l   (_centery),d0
		muls.l  d1,d0
		add.l   (_dc_texturemid,pc),d0

		moveq   #$7f,d3
		
__RESPATCH45:
		move.w  #SCREENWIDTH,a3

		move.l  d7,d6           ; Do the leftover iterations in
		and.w   #3,d6           ; this loop.
		addq.w	#1,d6
.skip_loop7
		move.l  d0,d5
		swap    d5
		and.l   d3,d5
		move.b  (a1,d5.w),d5
		add.l   d1,d0
		move.b  (a2,d5.w),(a0)
		add.l   a3,a0
		subq.w  #1,d6
		bne.b   .skip_loop7
; d7: cnt >> 2
; a0: chunky
; a1: texture
; a2: light_table
; d0: frac  (uuuu uuuu uuuu uuuu 0000 0000 0UUU UUUU)
; d1: dfrac*2   (.......................................)
; d2: frac+dfrac(.......................................)
; d3: $7f
; a3: SCREENWIDTH
.skip7
		lsr.l   #2,d7
		subq.l	#1,d7
		bmi.b	dc60_end7

		add.l   a3,a3

		move.l  d0,d2
		add.l   a3,a3
		add.l   d1,d2
		add.l   d1,d1

		eor.w   d0,d2           ; swap the fraction part for addx
		eor.w   d2,d0           ; assuming 16.16 fixed point
		eor.w   d0,d2

		swap    d0              ; swap decimals and fraction
		swap    d1
		swap    d2

		moveq   #0,d5
		and.w   d3,d2
		and.w   d3,d0

		sub.w   d1,d0
		add.l   d1,d0           ; setup the X flag

		move.b  (a1,d2.w),d5
dc60_loop7
		; This should be reasonably scheduled for
		; m68060. It should perform well on other processors
		; too. That AGU stall still bothers me though.

		move.b  (a1,d0.w),d6        ; stall + pOEP but allows sOEP
		addx.l  d1,d2               ; pOEP only
		move.b  (a2,d5.l),d5        ; pOEP but allows sOEP
		and.w   d3,d2               ; sOEP
		move.b  (a2,d6.l),d6        ; pOEP but allows sOEP

__RESPATCH46:
		move.b  d5,SCREENWIDTH(a0)  ; sOEP
		addx.l  d1,d0               ; pOEP only
		move.b  (a1,d2.w),d5        ; pOEP but allows sOEP
		and.w   d3,d0               ; sOEP
		move.b  d6,(a0)             ; pOEP
						; = ~4 cycles/pixel
						; + cache misses

		; The vertical writes are the true timehog of the loop
		; because of the characteristics of the copyback cache
		; operation.
		
		; Better mark the chunky buffer as write through
		; with the MMU and have all the horizontal writes
		; be longs aligned to longword boundary.

		move.b  (a1,d0.w),d6
		addx.l  d1,d2
		move.b  (a2,d5.l),d5
		and.w   d3,d2
		move.b  (a2,d6.l),d6

__RESPATCH47:
		move.b  d5,SCREENWIDTH*3(a0)
		addx.l  d1,d0
		move.b  (a1,d2.w),d5
		and.w   d3,d0

__RESPATCH48:
		move.b  d6,SCREENWIDTH*2(a0)

		add.l   a3,a0
.loop_end7
		dbf     d7,dc60_loop7

		; it's faster to divide it to two lines on 060
		; and shouldn't be slower on 040.

;		move.b  (a1,d0.w),d6    ; new
;		move.b  (a2,d6.l),d6    ; new
;		move.b  d6,(a0)     ; new

dc60_end7
		movem.l (sp)+,d2-d3/d5-d7/a2/a3
		rts

;/*= R_DrawSpan_060 =============================================================*/

	XDEF	_R_DrawSpan_060
	XDEF	_R_DrawSpan_060_Check
	
	CNOP	0,4
	
_R_DrawSpan_060_Check:
		movem.l d2-d7/a2/a3,-(sp)
		move.l  _ds_y(pc),d0
		cmp.l		_REALSCREENHEIGHT(pc),d0
		bhs.s		DrawSpan_060_Exit

		move.l  _ds_x1(pc),d1	; dest = ylookup[_ds_y] + columnofs[_ds_x1]
		bmi.s		DrawSpan_060_Exit

		lea     _ylookup(pc),a0
		move.l  (a0,d0.l*4),a0
		lea     _columnofs(pc),a1
		add.l   (a1,d1.l*4),a0
		move.l  _ds_source(pc),a1
		move.l  _ds_colormap(pc),a2
		move.l  _ds_x2(pc),d7	; count = _ds_x2 - _ds_x1
		cmp.l		d1,d7
		blt.s		DrawSpan_060_Exit

__RESPATCH49:
		cmp.l		#SCREENWIDTH,d7
		bhs.s		DrawSpan_060_Exit

		bra.s		DrawSpan_060_Common
		
		CNOP	0,4

_R_DrawSpan_060:
		movem.l d2-d7/a2/a3,-(sp)
		move.l  (_ds_y,pc),d0
		move.l  (_ds_x1,pc),d1     ; dest = ylookup[_ds_y] + columnofs[_ds_x1]
		lea     (_ylookup,pc),a0
		move.l  (a0,d0.l*4),a0
		lea     (_columnofs,pc),a1
		add.l   (a1,d1.l*4),a0
		move.l  (_ds_source,pc),a1
		move.l  (_ds_colormap,pc),a2
		move.l  (_ds_x2),d7     ; count = _ds_x2 - _ds_x1

DrawSpan_060_Common:
		sub.l   d1,d7
		addq.l  #1,d7
		move.l  (_ds_xfrac,pc),d0
		move.l  (_ds_yfrac,pc),d1
		move.l  (_ds_xstep,pc),d2
		move.l  (_ds_ystep,pc),d3
		move.l  a0,d4
		btst    #0,d4
		beq.b     .skipb9
		move.l  d0,d5           ; do the unaligned pixels
		move.l  d1,d6           ; so we can write to longword
		swap    d5              ; boundary in the main loop
		swap    d6
		and.w   #$3f,d5
		and.w   #$3f,d6
		lsl.w   #6,d6
		or.w    d5,d6
		move.b  (a1,d6.w),d5
		add.l   d2,d0
		move.b  (a2,d5.w),(a0)+
		add.l   d3,d1
		move.l  a0,d4
		subq.l  #1,d7
.skipb9		btst    #1,d4
		beq.b     .skips9
		moveq   #2,d4
		cmp.l   d4,d7
		bls.b   .skips9
		move.l  d0,d5           ; write two pixels
		move.l  d1,d6
		swap    d5
		swap    d6
		and.w   #$3f,d5
		and.w   #$3f,d6
		lsl.w   #6,d6
		or.w    d5,d6
		move.b  (a1,d6.w),d5
		move.w  (a2,d5.w),d4
		add.l   d2,d0
		add.l   d3,d1
		move.l  d0,d5
		move.l  d1,d6
		swap    d5
		swap    d6
		and.w   #$3f,d5
		and.w   #$3f,d6
		lsl.w   #6,d6
		or.w    d5,d6
		move.b  (a1,d6.w),d5
		move.b  (a2,d5.w),d4
		add.l   d2,d0
		move.w  d4,(a0)+
		add.l   d3,d1
		subq.l  #2,d7
.skips9		move.l  d7,d6           ; setup registers
		and.w   #3,d6
		move.l  d6,a3
		eor.w   d0,d1           ; swap fraction parts for addx
		eor.w   d2,d3
		eor.w   d1,d0
		eor.w   d3,d2
		eor.w   d0,d1
		eor.w   d2,d3
		swap    d0
		swap    d1
		swap    d2
		swap    d3
		lsl.w   #6,d1
		lsl.w   #6,d3
		moveq   #0,d6
		moveq   #0,d5
		sub.l   #$f000,a1
		lsr.l   #2,d7
		beq.w   .skip_loop29
		subq.l  #1,d7
		sub.w   d3,d1
		add.l   d3,d1           ; setup the X flag
		or.w    #$ffc0,d0
		or.w    #$f03f,d1
		move.w  d0,d6
		and.w   d1,d6
		bra.b   .start_loop29
		cnop    0,4
.loop29		or.w    #$ffc0,d0       ; pOEP
		or.w    #$f03f,d1       ; sOEP
		move.b  (a2,d5.l),d4    ; pOEP but allows sOEP
		move.w  d0,d6           ; sOEP
		and.w   d1,d6           ; pOEP
		move.l  d4,(a0)+        ; sOEP
.start_loop29
		addx.l  d2,d0           ; pOEP only
		addx.l  d3,d1           ; pOEP only
		move.b  (a1,d6.l),d5    ; pOEP but allows sOEP
		or.w    #$ffc0,d0       ; sOEP
		or.w    #$f03f,d1       ; pOEP
		move.w  d0,d6           ; sOEP
		move.w  (a2,d5.l),d4    ; pOEP but allows sOEP
		and.w   d1,d6           ; sOEP
		addx.l  d2,d0           ; pOEP only
		addx.l  d3,d1           ; pOEP only
		move.b  (a1,d6.l),d5    ; pOEP but allows sOEP
		or.w    #$ffc0,d0       ; sOEP
		or.w    #$f03f,d1       ; pOEP
		move.w  d0,d6           ; sOEP
		move.b  (a2,d5.l),d4    ; pOEP but allows sOEP
		and.w   d1,d6           ; sOEP
		addx.l  d2,d0           ; pOEP only
		addx.l  d3,d1           ; pOEP only
		move.b  (a1,d6.l),d5    ; pOEP but allows sOEP
		or.w    #$ffc0,d0       ; sOEP
		or.w    #$f03f,d1       ; pOEP
		move.w  d0,d6           ; sOEP
		swap    d4              ; pOEP only
		move.w  (a2,d5.l),d4    ; pOEP but allows sOEP
		and.w   d1,d6           ; sOEP
		addx.l  d2,d0           ; pOEP only
		addx.l  d3,d1           ; pOEP only
		move.b  (a1,d6.l),d5    ; pOEP but allows sOEP
		dbf     d7,.loop29      ; pOEP only = 7.75 cycles/pixel
		move.b  (a2,d5.l),d4
		move.l  d4,(a0)+
.skip_loop29
		sub.w   d3,d1
		add.l   d3,d1
		move.l  a3,d7
		bra.b     .loop_end29
.loop39  	or.w    #$ffc0,d0
		or.w    #$f03f,d1
		move.w  d0,d6
		and.w   d1,d6
		addx.l  d2,d0
		addx.l  d3,d1
		move.b  (a1,d6.l),d5
		move.b  (a2,d5.l),(a0)+
.loop_end29
		dbf     d7,.loop39
DrawSpan_060_Exit:
.end29   	movem.l (sp)+,d2-d7/a2/a3
		rts

;/***************************************************/
;/*                                                 */
;/*       V_VIDEO                                   */
;/*                                                 */
;/***************************************************/

	XDEF	_V_CopyRect
	XREF	_I_VideoBuffer

	CNOP	0,4
	
_V_CopyRect:				;//( int		srcx,
								;//  int		srcy,
								;//  int		srcscrn,
								;//  int		width,
								;//  int		height,
								;//  int		destx,
								;//  int		desty,
								;//  int		destscrn ) 
;//{ 
;//    byte*	src;
;//    byte*	dest; 
	 
	movem.l	d2-d4/a2-a6,-(sp)
	
;//    V_MarkRect (destx, desty, width, height); 
	 
	movem.l	8*4+4(sp),d0-d4/a2-a4
	 
;//    src = screens[srcscrn]+SCREENWIDTH*srcy+srcx;

	lea		_yoffsettable,a5
	move.l	(a5,d1.w*4),a0
	lea		_I_VideoBuffer,a6
	add.l		(a6,d2.w*4),a0
	add.w		d0,a0						;'a0 = src
	     
;//    dest = screens[destscrn]+SCREENWIDTH*desty+destx; 
	
	move.l	(a5,a3.w*4),a1
	add.l		(a6,a4.w*4),a1
	add.w		a2,a1						;'a1 = dest
	
	subq		#1,d4

__RESPATCH50:
	move		#SCREENWIDTH,d0
	sub		d3,d0						;'d0 = modulo
	subq		#1,d3
		
.yloop:
	move		d3,d1
	
.xloop:
	move.b	(a0)+,(a1)+
	dbf		d1,.xloop

	add.w		d0,a0
	add.w		d0,a1
	dbf		d4,.yloop

 	movem.l	(sp)+,d2-d4/a2-a6
 	rts	
	
 
			
;/********** DATA **************************************/

	CNOP	0,4
	
	XDEF	_finecosine
	XDEF	_validcount
	XDEF	_dc_yh
	XDEF	_dc_yl
	XDEF	_dc_x
	XDEF	_ylookup
	XDEF	_columnofs	
	XDEF	_dc_texturemid
	XDEF	_dc_iscale
	XDEF	_dc_colormap
	XDEF	_dc_source
	XDEF	_centery
	XDEF	_dc_translation	
	XDEF	_ds_y
	XDEF	_ds_x1
	XDEF	_ds_x2
	XDEF	_ds_colormap
	XDEf	_ds_xfrac
	XDEF	_ds_yfrac
	XDEF	_ds_xstep
	XDEF	_ds_ystep
	XDEF	_ds_source
	XDEF	_REALSCREENHEIGHT
	XDEF	_REALSCREENWIDTH
	XDEF	_skyflatnum
	XDEF	_visplanes
	XDEF	_lastvisplane
	XDEF	_maxvisplane
	XDEF	_texturewidthmask
	;XDEF	_textureheight
	XDEF	_texturecolumnlump
	XDEF	_texturecolumnofs
	XDEF	_texturecomposite	
 
	
 	 
_finecosine:		dc.l	_finesine+(FINEANGLES/4*4)
_validcount:		dc.l	1 
_dc_yh:				dc.l	0
_dc_yl:				dc.l	0
_dc_x:				dc.l	0
_ylookup:	blk.l	MAXHEIGHT,0
_columnofs:	blk.l	MAXWIDTH,0
_dc_colormap:		dc.l 	0
_dc_source:			dc.l 	0
_dc_iscale:			dc.l	0
_dc_texturemid:		dc.l	0
_centery:			dc.l	0
_dc_translation:	dc.l 	0
_ds_y:				dc.l 0
_ds_x1:				dc.l 0
_ds_x2:				dc.l 0
_ds_colormap:		dc.l 0
_ds_xfrac:			dc.l 0
_ds_yfrac:			dc.l 0
_ds_xstep:			dc.l 0
_ds_ystep:			dc.l 0
_ds_source:			dc.l 0
_REALSCREENWIDTH:	dc.l	320
_REALSCREENHEIGHT:	dc.l	200
_skyflatnum:		dc.l	0
_visplanes:			dc.l	0
_lastvisplane:		dc.l	0
_maxvisplane:		dc.l	0
_texturewidthmask:	dc.l	0
;_textureheight:		dc.l	0
_texturecolumnlump:	dc.l	0
_texturecolumnofs:	dc.l	0
_texturecomposite:	dc.l	0

 
 
;/********** ERROR TEXTS *******************************/

ERRTXT_NOVISPLANES:
	dc.b 'R_FindPlane: No more visplanes',0
ERRTXT_NONETGAME:
	dc.b 'Tried to transmit to another node',0


;/*************** BSS *********************************/

	SECTION r_engine_data,BSS

	XDEF	_yoffsettable

_yoffsettable:
	ds.l		MAXHEIGHT
cliptop:
	ds.w		MAXWIDTH+4
clipbot:
	ds.w		MAXWIDTH+4

	END

