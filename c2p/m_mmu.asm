	MACHINE 68040
	PMMU

	incdir AINCLUDE:
	
	include exec/types.i
	include hardware/cia.i
	include lvo/exec_lib.i

	;include "DoomFont.i"
	include "amiga_mmu.i"
	;include "d_engine.i"

	xref	_ciaa
	
SLOPERANGE=2048

MAXWIDTH=320
MAXHEIGHT=512

SCREENWIDTH=320
SCREENHEIGHT=200

FUZZTABLE=50

	SECTION mfixedamiga,CODE

;/*= SWAPLONG ===================================================================*/

	XDEF	_SWAPLONG
	CNOP	0,4

_SWAPLONG:
	move.l	4(sp),d0
	ror.w		#8,d0
	swap		d0
	ror.w		#8,d0
	rts

;/*= mmu_mark ===================================================================*/

	IFND    TRUE
TRUE EQU    1
	ENDC

	IFND    FALSE
FALSE EQU   0
	ENDC

*
*   FUNCTION
*       UBYTE __asm mmu_mark (register __a0 UBYTE *start,
*                             register __d0 ULONG length,
*                             register __d1 ULONG cm,
*                             register __a6 struct ExecBase *SysBase);
*
*   SYNOPSIS
*       Changes the cache mode for the specified memory area. This
*       area  must be aligned by 4kB and be multiple of 4kB in size.
*
*   RESULT
*       Returns the old cache mode for the memory area.
*
*   NOTES
*       Works only after setpatch has been issued and in such
*       systems where 68040.library/68060.library is correctly
*       installed.
*

		XDEF	_mmu_mark
		CNOP	0,4

_mmu_mark:
		move.l	a6,-(sp)

		move.l	4+4(sp),a0
		move.l	4+8(sp),d0
		move.l	4+12(sp),d1
		move.l	4+16(sp),a6
		bsr.s		mmu_mark
		
		move.l	(sp)+,a6
		rts

mmu_mark
		movem.l	d2/d3/d7/a2/a4/a6,-(sp)

		move.l	a1,a4
		movem.l	d0/d1/a0,-(sp)
		jsr	(_LVOSuperState,a6)
		movec	tc,d3			; translation code register
		movec	urp,d2			; user root pointer
		jsr	(_LVOUserState,a6)
		movem.l	(sp)+,d0/d1/a0

		btst	#TCB_E,d3
		beq	.error
		btst	#TCB_P,d3
		bne	.error

		move.l	d1,-(sp)
		move.l	d0,d1

		lsr.l	#8,d0
		lsr.l	#4,d0

		move.l	a0,a1

		and.w	#$fff,d1
		beq.s	.skip_a
		addq.l	#1,d0
.skip_a
		move.l	(sp)+,d1
		subq.l	#1,d0
		move.l	d0,d7

; a1 - chunkybuffer
; d7 - counter
; d2 - urp
; d1 - cache mode

.loop
		move.l	d2,-(sp)
		move.l	a1,d0
		rol.l	#8,d0
		lsl.l	#1,d0
		and.w	#%1111111000000000,d2
		and.w	#%0000000111111100,d0
		or.w	d0,d2
		move.l	d2,a2
		move.l	(a2),d2
		btst	#TDB_UDT0,d2
		beq	.skip			; if 0
		btst	#TDB_UDT1,d2		; if 1
		beq	.end
		bra	.skip2
.skip
		btst	#TDB_UDT1,d2
		bne	.end
.skip2
		move.l	a1,d0
		lsr.l	#8,d0
		lsr.l	#8,d0
		and.w	#%1111111000000000,d2
		and.w	#%0000000111111100,d0
		or.w	d0,d2
		move.l	d2,a2
		move.l	(a2),d2
		btst	#TDB_UDT0,d2
		beq	.skip1			; if 0
		btst	#TDB_UDT1,d2		; if 1
		beq	.end
		bra	.skip3
.skip1
		btst	#TDB_UDT1,d2
		bne	.end
.skip3
		move.l	a1,d0
		lsr.l	#8,d0
		lsr.l	#2,d0
		and.w	#%1111111100000000,d2
		and.w	#%0000000011111100,d0
		or.w	d0,d2

		move.l	d2,a2
		btst	#PDB_PDT1,(3,a2)
		bne	.skip4
		btst	#PDB_PDT0,(3,a2)
		beq	.end
		bra	.skip5
.skip4
		btst	#PDB_PDT0,(3,a2)
		beq	.indirect
.skip5
		move.b	(3,a2),d3
		and.b	#~CM_MASK,(3,a2)
		or.b	d1,(3,a2)

.indirect
		lea	(4096,a1),a1

		move.l	(sp)+,d2
		dbf	d7,.loop

		and.b	#CM_MASK,d3
		jsr	(_LVOSuperState,a6)
		pflusha
		jsr	(_LVOUserState,a6)

		moveq	#0,d0
		move.b	d3,d0

		movem.l	(sp)+,d2/d3/d7/a2/a4/a6
		rts
.end
		move.l	(sp)+,d2
.error
		movem.l	(sp)+,d2/d3/d7/a2/a4/a6
		moveq	#0,d0
		rts

;/*= mmu_stuff2 =================================================================*/

	XDEF	_mmu_stuff2
	CNOP	0,4
	
_mmu_stuff2:
	move.l	a6,-(sp)

	move.l	4.w,a6
	jsr		_LVOSuperState(a6)        ; must be executed in supervisor mode

	moveq		#0,d1           ; set up
	movec		d1,DTT1         ; MMU registers
	movec		d1,ITT1
	movec		d1,ITT0
	move.l	#$0106e020,d1
	movec		d1,DTT0         ; to return to the original state, write
									 ; zero to this register.

; Meaning of bits in ITT/DTT (Instruction/Data Transparent Translation)
; registers:

; %BBBBBBBBMMMMMMMMESS000UU0CC00W00

; B - Logical Address Base - compared with address bits A31-A24. Addresses
;                            that match in this comparision are
;                            transparently translated
; M - Logical Address Mask - setting a bit in this field causes
;                            corresponding bit in Base field to be ignored
; E - Enable Bit - 1 - translation enabled; 0 - disabled
; S - Supervisor Mode - 00 - match only in user mode
;                       01 - match only in supervisor mode
;                       1x - ignore mode when matching
; U - User Page Attributes - ignored by 040
; C - Cache mode - 00 - Cacheable, Write-through
;                  01 - Cacheable, Copyback
;                  10 - Noncacheable, Serialized
;                  11 - Noncacheable
; W - Write protect - 0 - write permitted; 1 - write disabled

;//	move.l	4.w,a6
	jsr		_LVOUserState(a6)        ; return to user mode

	move.l	(sp)+,a6
	rts
        
;/*= mmu_stuff2_cleanup =========================================================*/

	XDEF	_mmu_stuff2_cleanup
	CNOP	0,4
	
_mmu_stuff2_cleanup:
	move.l	a6,-(sp)

	move.l	4.w,a6
	jsr		_LVOSuperState(a6)        ; must be executed in supervisor mode
	
	moveq		#0,d1
	movec		d1,DTT0         ; to return to the original state, write
									 ; zero to this register.
	
	jsr		_LVOUserState(a6)
	
	move.l	(sp)+,a6
	rts

 

;/*= SoundFilter_Get ==============================================================*/

	XDEF	_SoundFilter_Get
	CNOP	0,4
	
_SoundFilter_Get:
	move.l	a6,-(sp)
	move.l	4.w,a6

	jsr		_LVODisable(a6)
	
	lea		_ciaa,a0
	moveq		#0,d0
	move.b	ciapra(a0),d0
	
	jsr		_LVOEnable(a6)

	and.b		#CIAF_LED,d0
	sne		d1
	neg.b		d1
	and.b		d1,d0
	
	move.l	(sp)+,a6
	rts


;/*= SoundFilter_Set ==============================================================*/

	XDEF	_SoundFilter_Set
	CNOP	0,4
	
_SoundFilter_Set:
	move.l	a6,-(sp)
	move.l	4.w,a6

	jsr		_LVODisable(a6)
	
	lea		_ciaa,a0
	move.b	ciapra(a0),d0
	
	tst.l		4+4(sp)
	beq.s		.clear
	
	or.b		#CIAF_LED,d0
	bra.s		.done

.clear:
	and.b		#~CIAF_LED,d0
	
.done
	move.b	d0,ciapra(a0)
	jsr		_LVOEnable(a6)

	move.l	(sp)+,a6
	rts
 
	END
	
