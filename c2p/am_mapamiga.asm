	MACHINE 68020
	
MAXHEIGHT = 512;

	SECTION	am_mapamiga,CODE

	XDEF	_AM_InitMapDraw

	cnop	0,4

_AM_InitMapDraw:
	; fb screenwidth screenheight

	move.l	d2,-(sp)
	
	lea		ylookuptable,a0
	move.l	a0,ylookup
	
	move.l	4+4(sp),a1		;fb
	move.l	4+8(sp),d1		;d1=screenwidth
	move.l	4+12(sp),d2		;d2=screenheight
	subq		#1,d2

	moveq		#0,d0
.loop:
	move.l	a1,(a0)+
	add.w		d1,a1
	dbf		d2,.loop

	move.l	(sp)+,d2
	rts


	XDEF	_AM_drawFline
	XREF	_mapfb
	XREF	_mapf_h

fline = 10*4+4
color = 10*4+8

_AM_drawFline:
	;fline color
	
	movem.l	d2-d6/a2-a6,-(sp)
	move.l	fline(sp),a0
	movem.l	(a0),d0-d3			;x1,y1,x2,y2
	move.l	color(sp),d6		;d6 = color
	move.l	ylookup(pc),a1		;a1 = ylookup
	
	move.l	d2,d4
	sub.l	d0,d4				;d4 = dx
	move.l	d3,d5
	sub.l	d1,d5				;d5 = dy
	beq.s	.fastxline
	
	tst.l	d4
	beq		.fastyline
	
	move.l	(a1,d1.w*4),a1
	add.w		d0,a1					;a1 = 1. Pixel

	moveq	#1,d2
	move.l	d4,d0
	bpl.s	.dxpositive
	neg.l	d0
	moveq	#-1,d2

.dxpositive:
	move.l	_mapf_w(pc),d3
	move.l	d5,d1
	bpl.s	.dypositive
	neg.l	d1
	neg.l	d3

.dypositive:
	moveq	#-1,d5			;d5=0xFFFFFFFF
	clr		d5				;d5=0xFFFF0000
	swap	d5				;d5=0x0000FFFF

	cmp.l	d0,d1
	beq.s	.dxdyequal
	bgt.s	.dygreater

;======== flache Linie (dx>dy) ============

.dxgreater:
	swap	d1
	divu	d0,d1			;65536*dy/dx
	and.l	d5,d1

.dxdx:
	move.l	#$8000,d4
	tst.l	d2
	bmi.s	.loop1back
	moveq	#16,d2

.loop1:
	move.b	d6,(a1)+
	add.l	d1,d4
	btst	d2,d4
	bne.s	.dostep1
	dbf		d0,.loop1
	bra.s	.raus

.dostep1:
	and.l	d5,d4
	add.l	d3,a1
	dbf		d0,.loop1
	bra.s	.raus

.loop1back:
	moveq	#16,d2
	addq.l	#1,a1
	
.loop11:
	move.b	d6,-(a1)
	add.l	d1,d4
	btst	d2,d4
	bne.s	.dostep11
	dbf		d0,.loop11
	bra.s	.raus

.dostep11:
	and.l	d5,d4
	add.l	d3,a1
	dbf		d0,.loop11
	
	bra.s	.raus

	
.dxdyequal:
	moveq	#1,d1
	swap	d1
	bra.s	.dxdx
	

;======== steile Linie (dy>dx) ============


.dygreater:
	swap	d0
	divu	d1,d0			;65536*dx/dy
	and.l	d5,d0

	move.l	#$8000,d4
	
	move.l	d3,a0
	moveq	#16,d3

.loop2:
	move.b	d6,(a1)
	add.l	a0,a1
	add.l	d0,d4
	btst	d3,d4
	bne.s	.dostep2
	dbf		d1,.loop2
	bra.s	.raus

.dostep2:
	and.l	d5,d4
	add.l	d2,a1
	dbf		d1,.loop2

	bra.s	.raus
	
;====== gerade X Linie ========

.fastxline:
	move.l	(a1,d1.w*4),a1
	add.w		d0,a1					;a1 = 1. Pixel

	tst.l	d4
	bmi.s	.fastxbackline

.fastxloop:
	move.b	d6,(a1)+
	dbf		d4,.fastxloop
	bra.s	.raus

.fastxbackline:
	neg.l	d4
	addq.l	#1,a1
.fastxbackloop:
	move.b	d6,-(a1)
	dbf		d4,.fastxbackloop
	bra.s	.raus

;====== gerade Y Linie ========
	
.fastyline:
	move.l	_mapf_w(pc),d4

	move.l	(a1,d1.w*4),a1
	add.w		d0,a1					;a1 = 1. Pixel

	tst.l	d5
	bpl.s	.fastyloop
	neg.l	d4
	neg.l	d5
	
.fastyloop:
	move.b	d6,(a1)
	add.w 	d4,a1
	dbf		d5,.fastyloop

.raus:
	movem.l	(sp)+,d2-d6/a2-a6
	rts

	XDEF	_AM_DoTransparency

	cnop	0,4
	
_AM_DoTransparency:
	;colmap x1 y1 sx sy		; sx = durch vier teilbar

	movem.l	a2/d2-d5,-(sp)
	
	move.l	ylookup(pc),a0
	move.l	24+8(sp),d0
	move.l	(a0,d0.w*4),a0
	add.l		24+4(sp),a0			;// start
	
	move.l	24+0(sp),d4			;// colmap
	move.l	24+12(sp),d0			;// d0 = f_w
	move.l	_mapf_w(pc),d3
	sub		d0,d3					;// d3 = modulo
	lsr		#2,d0					;// sx / 4
	subq		#1,d0

	lea		.jumptab(pc),a2
	move		d0,d1
	and		#3,d1
	move.l	(a2,d1.w*4),a2
	
	lsr		#2,d0
	
	move.l	24+16(sp),d1			;// d1 = f_h
	subq		#1,d1

.yloop:
	move		d0,d2
	jmp		(a2)

.xloop:
.x3:
	move.b	(a0),d4
	move.l	d4,a1
	move	   (a1),d5

	move.b	1(a0),d4
	move.l	d4,a1
	move.b	(a1),d5
	
	move		d5,(a0)+

	move.b	(a0),d4
	move.l	d4,a1
	move  	(a1),d5

	move.b	1(a0),d4
	move.l	d4,a1
	move.b	(a1),d5
	
	move		d5,(a0)+

.x2:
	move.b	(a0),d4
	move.l	d4,a1
	move 	   (a1),d5

	move.b	1(a0),d4
	move.l	d4,a1
	move.b	(a1),d5
	
	move		d5,(a0)+

	move.b	(a0),d4
	move.l	d4,a1
	move		(a1),d5

	move.b	1(a0),d4
	move.l	d4,a1
	move.b	(a1),d5
	
	move		d5,(a0)+

.x1:
	move.b	(a0),d4
	move.l	d4,a1
	move	   (a1),d5

	move.b	1(a0),d4
	move.l	d4,a1
	move.b	(a1),d5
	
	move		d5,(a0)+

	move.b	(a0),d4
	move.l	d4,a1
	move		(a1),d5

	move.b	1(a0),d4
	move.l	d4,a1
	move.b	(a1),d5
	
	move		d5,(a0)+

.x0:
	move.b	(a0),d4
	move.l	d4,a1
	move		(a1),d5

	move.b	1(a0),d4
	move.l	d4,a1
	move.b	(a1),d5
	
	move		d5,(a0)+

	move.b	(a0),d4
	move.l	d4,a1
	move		(a1),d5

	move.b	1(a0),d4
	move.l	d4,a1
	move.b	(a1),d5
	
	move		d5,(a0)+

	dbf		d2,.xloop
	
	add.w		d3,a0
	dbf		d1,.yloop
	
	movem.l	(sp)+,a2/d2-d5
	rts
	
	cnop		0,4
		
.jumptab:
	dc.l		.x0
	dc.l		.x1
	dc.l		.x2
	dc.l		.x3



	XDEF	_AM_DoBlack
	cnop	0,4
	
_AM_DoBlack:
	;x1 y1 sx sy
	
	movem.l	d2/d3,-(sp)

	move.l	ylookup(pc),a0
	move.l	12+4(sp),d0
	move.l	(a0,d0.w*4),a0
	add.l		12+0(sp),a0			;// a0 = start
	
	move.l	12+8(sp),d0
	move.l	_mapf_w(pc),d3
	sub		d0,d3					;// d3 = modulo
	
	lsr		#2,d0					;// sx in longwords
	subq		#1,d0

	move		d0,d1
	and		#7,d1
	lsr		#3,d0

	lea		.jumptab(pc),a1
	move.l	(a1,d1.w*4),a1

	move.l	12+12(sp),d1
	subq		#1,d1					;// sy
	
.yloop:
	move		d0,d2
	jmp		(a1)

.xloop:
.x7
	clr.l		(a0)+
.x6
	clr.l		(a0)+
.x5
	clr.l		(a0)+
.x4
	clr.l		(a0)+
.x3
	clr.l		(a0)+
.x2
	clr.l		(a0)+
.x1
	clr.l		(a0)+
.x0
	clr.l		(a0)+
	dbf		d2,.xloop

	add.w		d3,a0
	dbf		d1,.yloop
	
	movem.l	(sp)+,d2/d3
	rts

	cnop		0,4
		
.jumptab:
	dc.l		.x0
	dc.l		.x1
	dc.l		.x2
	dc.l		.x3
	dc.l		.x4
	dc.l		.x5
	dc.l		.x6
	dc.l		.x7


	
	CNOP	0,4
	XDEF	_mapf_w

ylookup: dc.l 0
_mapf_w:	dc.l 0 

	SECTION "2",BSS

ylookuptable:
	ds.l		MAXHEIGHT
	END
