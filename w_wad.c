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
//	Handles WAD file header, directory, lump I/O.
//
//-----------------------------------------------------------------------------




#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "doomtype.h"

#include "i_swap.h"
#include "i_system.h"
#include "i_video.h"
#include "m_misc.h"
#include "z_zone.h"

#include "w_wad.h"

typedef struct
{
    // Should be "IWAD" or "PWAD".
    char		identification[4];		
    int			numlumps;
    int			infotableofs;
} PACKEDATTR wadinfo_t;


typedef struct
{
    int			filepos;
    int			size;
    char		name[8];
} PACKEDATTR filelump_t;

//
// GLOBALS
//

#ifdef DOOMATTACK_ASM
void **			lumpcache;
#endif
// Location of each lump on disk.

lumpinfo_t *lumpinfo;		
unsigned int numlumps = 0;

// Hash table for fast lookups

static lumpinfo_t **lumphash;

// Hash function used for lump names.

unsigned W_LumpNameHash(const char *s)
{
  unsigned hash;
  (void) ((hash =        toupper(s[0]), s[1]) &&
          (hash = hash*3+toupper(s[1]), s[2]) &&
          (hash = hash*2+toupper(s[2]), s[3]) &&
          (hash = hash*2+toupper(s[3]), s[4]) &&
          (hash = hash*2+toupper(s[4]), s[5]) &&
          (hash = hash*2+toupper(s[5]), s[6]) &&
          (hash = hash*2+toupper(s[6]),
           hash = hash*2+toupper(s[7]))
         );
  return hash;
}


//
// LUMP BASED ROUTINES.
//

//
// W_AddFile
// All files are optional, but at least one file must be
//  found (PWAD, if all required lumps are present).
// Files with a .wad extension are wadlink files
//  with multiple lumps.
// Other files are single lumps with the base filename
//  for the lump name.

wad_file_t *W_AddFile (char *filename)
{
    wadinfo_t header;
    lumpinfo_t *lump_p;
    unsigned int i;
    wad_file_t *wad_file;
    int length;
    int startlump;
    filelump_t *fileinfo;
    filelump_t *filerover;
    
    // open the file and add to directory

    wad_file = W_OpenFile(filename);
		
    if (wad_file == NULL)
    {
	printf (" couldn't open %s\n", filename);
	return NULL;
    }

    startlump = numlumps;
	
    if (strcasecmp(filename+strlen(filename)-3 , "wad" ) )
    {
	// single lump file

        // fraggle: Swap the filepos and size here.  The WAD directory
        // parsing code expects a little-endian directory, so will swap
        // them back.  Effectively we're constructing a "fake WAD directory"
        // here, as it would appear on disk.

	fileinfo = Z_Malloc(sizeof(filelump_t), PU_STATIC, 0);
	fileinfo->filepos = LONG(0);
	fileinfo->size = LONG(wad_file->length);

        // Name the lump after the base of the filename (without the
        // extension).

	M_ExtractFileBase (filename, fileinfo->name);
	numlumps++;
    }
    else 
    {
	// WAD file
        W_Read(wad_file, 0, &header, sizeof(header));

	if (strncmp(header.identification,"IWAD",4))
	{
	    // Homebrew levels?
	    if (strncmp(header.identification,"PWAD",4))
	    {
		I_Error ("Wad file %s doesn't have IWAD "
			 "or PWAD id\n", filename);
	    }
	    
	    // ???modifiedgame = true;		
	}

	header.numlumps = LONG(header.numlumps);
	header.infotableofs = LONG(header.infotableofs);
	length = header.numlumps*sizeof(filelump_t);
	fileinfo = Z_Malloc(length, PU_STATIC, 0);

        W_Read(wad_file, header.infotableofs, fileinfo, length);
	numlumps += header.numlumps;
    }

    // Fill in lumpinfo
    lumpinfo = realloc(lumpinfo, numlumps * sizeof(lumpinfo_t));

    if (lumpinfo == NULL)
    {
	I_Error ("Couldn't realloc lumpinfo");
    }

    lump_p = &lumpinfo[startlump];
	
    filerover = fileinfo;

    for (i=startlump; i<numlumps; ++i)
    {
	lump_p->wad_file = wad_file;
	lump_p->position = LONG(filerover->filepos);
	lump_p->size = LONG(filerover->size);
    lump_p->cache = NULL;
	strncpy(lump_p->name, filerover->name, 8);

        ++lump_p;
        ++filerover;
    }
	
    Z_Free(fileinfo);

    if (lumphash != NULL)
    {
        Z_Free(lumphash);
        lumphash = NULL;
    }
    
#ifdef DOOMATTACK_ASM
    i = numlumps * sizeof(*lumpcache);
    lumpcache = malloc (i);
    
    if (!lumpcache)
	I_Error ("Couldn't allocate lumpcache");

    memset (lumpcache,0, i);
#endif    
    
    W_GenerateHashTable();
    return wad_file;
}


#ifdef DOOMATTACK_ASM
void* WW_CacheLumpNum
( int		lump,
  int		tag )
{
    byte*	ptr;

    
    if ((unsigned)lump >= numlumps)
	I_Error ("W_CacheLumpNum: %i >= numlumps (%d)",lump, numlumps);
		
    if (!lumpcache[lump])
    {
	/* read the lump in*/
	
	/*printf ("cache miss on lump %i\n",lump);*/
	ptr = Z_Malloc (W_LumpLength (lump), tag, &lumpcache[lump]);
	W_ReadLump (lump, lumpcache[lump]);
    }
    else
    {
	/*printf ("cache hit on lump %i\n",lump);*/
	Z_ChangeTag (lumpcache[lump],tag);
    }
	
    return lumpcache[lump];
}
#endif
//
// W_NumLumps
//
int W_NumLumps (void)
{
    return numlumps;
}



//
// W_CheckNumForName
// Returns -1 if name not found.
//

int W_CheckNumForName (char* name)
{
  // Hash function maps the name to one of possibly numlump chains.
  // It has been tuned so that the average chain length never exceeds 2.

 
  register int i = lumpinfo[W_LumpNameHash(name) % (unsigned) numlumps].index;

 
  // We search along the chain until end, looking for case-insensitive
  // matches which also match a namespace tag. Separate hash tables are
  // not used for each namespace, because the performance benefit is not
  // worth the overhead, considering namespace collisions are rare in
  // Doom wads.

  while (i >= 0 && (strncasecmp(lumpinfo[i].name, name, 8)))
  {
 
    i = lumpinfo[i].next;

}

  // Return the matching lump, or -1 if none found.

  return i;
}




//
// W_GetNumForName
// Calls W_CheckNumForName, but bombs out if not found.
//
int W_GetNumForName (char* name)
{
    int	i;
 
    i = W_CheckNumForName (name);
 
    //if (i < 0)
    //{
    //    I_Error ("W_GetNumForName: %s not found!", name);
    //}
 
    return i;
}


//
// W_LumpLength
// Returns the buffer size needed to load the given lump.
//
int W_LumpLength (unsigned int lump)
{
    if (lump >= numlumps)
    {
	I_Error ("W_LumpLength: %i >= numlumps", lump);
    }

    return lumpinfo[lump].size;
}



//
// W_ReadLump
// Loads the lump into the given buffer,
//  which must be >= W_LumpLength().
//
void W_ReadLump(unsigned int lump, void *dest)
{
    int c;
    lumpinfo_t *l;

    if (lump >= numlumps)
    {
	I_Error ("W_ReadLump: %i >= numlumps", lump);
    }

    l = lumpinfo+lump;

    I_BeginRead ();

    c = W_Read(l->wad_file, l->position, dest, l->size);

    if (c < l->size)
    {
	I_Error ("W_ReadLump: only read %i of %i on lump %i",
		 c, l->size, lump);
    }

    I_EndRead ();
}




//
// W_CacheLumpNum
//
// Load a lump into memory and return a pointer to a buffer containing
// the lump data.
//
// 'tag' is the type of zone memory buffer to allocate for the lump
// (usually PU_STATIC or PU_CACHE).  If the lump is loaded as 
// PU_STATIC, it should be released back using W_ReleaseLumpNum
// when no longer needed (do not use Z_ChangeTag).
//

void *W_CacheLumpNum(int lumpnum, int tag)
{
    byte *result;
    lumpinfo_t *lump;

    if ((unsigned)lumpnum >= numlumps)
    {
	I_Error ("W_CacheLumpNum: %i >= numlumps", lumpnum);
    }


  if (!lumpcache[lumpnum])      // read the lump in
    W_ReadLump(lumpnum, Z_Malloc(W_LumpLength(lumpnum), PU_CACHE, &lumpcache[lumpnum]));
    
    lump = &lumpinfo[lumpnum];

    // Get the pointer to return.  If the lump is in a memory-mapped
    // file, we can just return a pointer to within the memory-mapped
    // region.  If the lump is in an ordinary file, we may already
    // have it cached; otherwise, load it into memory.

    if (lump->wad_file->mapped != NULL)
    {
        // Memory mapped file, return from the mmapped region.

        result = lump->wad_file->mapped + lump->position;
    }
    else if (lump->cache != NULL)
    {
        // Already cached, so just switch the zone tag.

        result = lump->cache;
        Z_ChangeTag(lump->cache, tag);
    }
    else
    {
        // Not yet loaded, so load it now

        lump->cache = Z_Malloc(W_LumpLength(lumpnum), tag, &lump->cache);
	W_ReadLump (lumpnum, lump->cache);
        result = lump->cache;
    }

    return result;
}



//
// W_CacheLumpName
//
void *W_CacheLumpName(char *name, int tag)
{
   
    return W_CacheLumpNum(W_GetNumForName(name), tag);
}

// 
// Release a lump back to the cache, so that it can be reused later 
// without having to read from disk again, or alternatively, discarded
// if we run out of memory.
//
// Back in Vanilla Doom, this was just done using Z_ChangeTag 
// directly, but now that we have WAD mmap, things are a bit more
// complicated ...
//

void W_ReleaseLumpNum(int lumpnum)
{
    lumpinfo_t *lump;

    if ((unsigned)lumpnum >= numlumps)
    {
	I_Error ("W_ReleaseLumpNum: %i >= numlumps", lumpnum);
    }

    lump = &lumpinfo[lumpnum];

    if (lump->wad_file->mapped != NULL)
    {
        // Memory-mapped file, so nothing needs to be done here.
    }
    else
    {
        Z_ChangeTag(lump->cache, PU_CACHE);
    }
}

void W_ReleaseLumpName(char *name)
{
    W_ReleaseLumpNum(W_GetNumForName(name));
}

#if 0

//
// W_Profile
//
int		info[2500][10];
int		profilecount;

void W_Profile (void)
{
    int		i;
    memblock_t*	block;
    void*	ptr;
    char	ch;
    FILE*	f;
    int		j;
    char	name[9];
	
	
    for (i=0 ; i<numlumps ; i++)
    {	
	ptr = lumpinfo[i].cache;
	if (!ptr)
	{
	    ch = ' ';
	    continue;
	}
	else
	{
	    block = (memblock_t *) ( (byte *)ptr - sizeof(memblock_t));
	    if (block->tag < PU_PURGELEVEL)
		ch = 'S';
	    else
		ch = 'P';
	}
	info[i][profilecount] = ch;
    }
    profilecount++;
	
    f = fopen ("waddump.txt","w");
    name[8] = 0;

    for (i=0 ; i<numlumps ; i++)
    {
	memcpy (name,lumpinfo[i].name,8);

	for (j=0 ; j<8 ; j++)
	    if (!name[j])
		break;

	for ( ; j<8 ; j++)
	    name[j] = ' ';

	fprintf (f,"%s ",name);

	for (j=0 ; j<profilecount ; j++)
	    fprintf (f,"    %c",info[i][j]);

	fprintf (f,"\n");
    }
    fclose (f);
}


#endif

// Generate a hash table for fast lookups

void W_GenerateHashTable(void)
{
  int i;

  for (i=0; i<numlumps; i++)
    lumpinfo[i].index = -1;                     // mark slots empty

  // Insert nodes to the beginning of each chain, in first-to-last
  // lump order, so that the last lump of a given name appears first
  // in any chain, observing pwad ordering rules. killough

    for (i=0; i<numlumps; i++)
    {                    
      // hash function:
      int j = W_LumpNameHash(lumpinfo[i].name) % (unsigned) numlumps;
       
      lumpinfo[i].next = lumpinfo[j].index;     // Prepend to list     
      lumpinfo[j].index = i;
            
    }
}

