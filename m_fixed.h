// Emacs style mode select   -*- C++ -*- 
//-----------------------------------------------------------------------------
//
// Copyright(C) 1993-1996 Id Software, Inc.
// Copyright(C) 2005 Simon Howard
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA
// 02111-1307, USA.
//
// DESCRIPTION:
//	Fixed point arithemtics, implementation.
//
//-----------------------------------------------------------------------------


#ifndef __M_FIXED__
#define __M_FIXED__




//
// Fixed point, 32bit as 16.16.
//
#define FRACBITS		16
#define FRACUNIT		(1<<FRACBITS)

typedef int fixed_t;

#ifdef AMIGA
#define REG(xn, parm) parm __asm(#xn)
extern __regargs fixed_t (*FixedMul)	(REG( d0,fixed_t a),REG( d1,fixed_t b));
extern __regargs fixed_t (*FixedDiv)	(REG( d0,fixed_t a),REG( d1,fixed_t b));
void __regargs SetFPMode (void);
fixed_t __regargs FixedMul_040	  (REG( d0,fixed_t a),REG( d1,fixed_t b));
fixed_t __regargs FixedMul_060fpu (REG( d0,fixed_t a),REG( d1,fixed_t b));
fixed_t __regargs FixedMul_060	  (REG( d0,fixed_t a),REG( d1,fixed_t b));
fixed_t __regargs FixedDiv_040	  (REG( d0,fixed_t a),REG( d1,fixed_t b));
fixed_t __regargs FixedDiv_060fpu (REG( d0,fixed_t a),REG( d1,fixed_t b));

static __inline int LongDiv(int eins,int zwei)
{
	__asm __volatile
	(
		"divsl.l %2,%0:%0\n\t"
		
		: "=d" (eins)
		: "0" (eins), "d" (zwei)
	);

	return eins;
}

static __inline int ULongDiv(int eins,int zwei)
{
	__asm __volatile
	(
		"divul.l %2,%0:%0\n\t"
		
		: "=d" (eins)
		: "0" (eins), "d" (zwei)
	);

	return eins;
}

extern __inline int LongRest(int eins,int zwei)
{
	__asm __volatile
	(
		"divsl.l	%2,d2:%0\n\t"
		"move.l 	d2,%0\n\t"
		
		: "=d" (eins)
		: "0" (eins), "d" (zwei)
		: "d2"
	);

	return eins;
}

extern __inline int ULongRest(int eins,int zwei)
{
	__asm __volatile
	(
		"divul.l %2,d2:%0\n\t"
		"move.l d2,%0\n\t"
		
		: "=d" (eins)
		: "0" (eins), "d" (zwei)
		: "d2"
	);

	return eins;
}

#else
fixed_t FixedMul	(fixed_t a, fixed_t b);
fixed_t FixedDiv	(fixed_t a, fixed_t b);
#endif


#endif
