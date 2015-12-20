	IFND    MMU_I
MMU_I   SET 1

*
*   mmu.i - 68040/68060 MMU registers and page table definitions
*   This file is public domain.
*

;	IFND    EXEC_TYPES_I
;	INCLUDE "exec/types.i"
;	ENDC

; bit definitions for 040/060 translation control register (TCR/TC)

	BITDEF	TC,RESERVED0,0  ; reserved
	BITDEF	TC,DUI0,1       ; These bits are two user-defined bits for instruction 
	BITDEF	TC,DUI1,2       ; prefetch bus cycles (see M68060UM/AD 4.2.2.3 "Descriptor
				; field definitions"
	BITDEF	TC,DCI0,3       ; Default cache mode (instruction cache)
	BITDEF	TC,DCI1,4       ; 00: Writethrough, cachable
				; 01: Copyback, cachable;
				; 10: Cache-inhibited, precise exception model
				; 11: Cache-inhibited, imprecise exception model
	BITDEF	TC,DWO,5        ; Default Write protect
				; 0: Reads and writes are allowed
				; 1: Reads are allowed but writes cause a protection exception
	BITDEF	TC,DUO0,6       ; These bits are two user-defined bits for operand accesses
	BITDEF	TC,DUO1,7       ; (see M68060UM/AD 4.2.2.3 "Descriptor field definitions"
	BITDEF	TC,DCO0,8       ; Default cache mode (data cache)
	BITDEF	TC,DCO1,9       ; (see DCI for description of the bits)
	BITDEF	TC,FITC,10      ; 1/2-Cache mode (Instruction ATC)
				; 0: The instruction ATC operates with 64 entries
				; 1: The instruction ATC operates with 32 entries
	BITDEF	TC,FOTC,11      ; 1/2-Cache mode (Data ATC)
				; (see FITC for description)
	BITDEF	TC,NAI,12       ; No allocate mode (Instruction ATC)
				; This bit freezes the instruction ATC in the current state, by
				; enforcing a no-allocate policy for all accesses. Accesses can
				; still hit, misses will cause a table search.
	BITDEF	TC,NAD,13       ; No Allocate mode (Data ATC)
				; This bit freezes the data ATC in the current state, by enforcing
				; a no-allocate policy for all accesses. Accesses can still hit, misses
				; will cause a table search. A write access which finds a corresponding
				; valid read will update the M-bit and the entry remains valid.
	BITDEF	TC,P,14         ; Page size
				; 0: 4 kB
				; 1: 8 kB
	BITDEF	TC,E,15         ; This bit enables and disables paged address translation
				; 0: Disable
				; 1: Enable
				; A reset operation clears this bit. When translation is disabled,
				; logical addresses are used as physical addresses. The MMU instruction,
				; PFLUSH, can be executed succesfully despite the state of the E-bit.
				; If translation is disabled and an access does not match a transparent
				; translation register (TTR), the default attributes for the access
				; on the TTR is defined by the DCO, DUO, DCI, DWO, DUI (default TTR)
				; bits in TCR.
				; bits 16-31 are reserved by Motorola. Always read as zero.

; bit definitions for table descriptors

	BITDEF	TD,UDT0,0       ; Upper level descriptor type
	BITDEF	TD,UDT1,1       ; 00,01: invalid
					; 10,11: resident
	BITDEF	TD,W,2          ; Write protected
	BITDEF	TD,U,3          ; Used
	BITDEF	TD,X0,4         ; Motorola reserved
	BITDEF	TD,X1,5
	BITDEF	TD,X2,6
	BITDEF	TD,X3,7
	BITDEF	TD,X4,8
				; bits 9-31 describe the pointer or page table address

; bit definitions for page descriptors

	BITDEF	PD,PDT0,0       ; Page descriptor type
	BITDEF	PD,PDT1,1       ; 00: invalid
				; 01,11: resident
				; 10: indirect
	BITDEF	PD,W,2          ; Write protected
	BITDEF	PD,U,3          ; Used
	BITDEF	PD,M,4          ; Modified
	BITDEF	PD,CM0,5        ; Cache mode
	BITDEF	PD,CM1,6        ; 00: Writethrough, cachable
				; 01: Copyback, cachable;
				; 10: Cache-inhibited, precise exception model
				; 11: Cache-inhibited, imprecise exception model
	BITDEF	PD,S,7          ; Supervisor protected
	BITDEF	PD,U0,8         ; User page attributes
	BITDEF	PD,U1,9         ; These bits are echoed to UPA0 and UPA1 respectively
	BITDEF	PD,G,10         ; Global
	BITDEF	PD,UR0,11       ; User reserved
	BITDEF	PD,UR1,12       ; if 4kB page size
				; bits 13-31 describe the physical address of the page

; cachemodes

CM_IMPRECISE EQU    ((1<<6)!(1<<5))
CM_PRECISE   EQU    (1<<6)
CM_COPYBACK  EQU    (1<<5)
CM_WRITETHROUGH EQU 0
CM_MASK      EQU    ((1<<6)!(1<<5))

	ENDC                    ; MMU_I
