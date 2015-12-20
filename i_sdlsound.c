// Emacs style mode select   -*- C++ -*- 
//-----------------------------------------------------------------------------
//
// Copyright(C) 1993-1996 Id Software, Inc.
// Copyright(C) 2005-8 Simon Howard
// Copyright(C) 2008 David Flater
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
//	System interface for sound.
//
//-----------------------------------------------------------------------------

#include "config.h"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>

//#include "SDL_mixer.h"

#ifdef HAVE_LIBSAMPLERATE
#include <samplerate.h>
#endif

#include "deh_str.h"
#include "i_sound.h"
#include "i_system.h"
#include "i_swap.h"
#include "m_argv.h"
#include "w_wad.h"
#include "z_zone.h"

#include "doomtype.h"

#define LOW_PASS_FILTER
//#define DEBUG_DUMP_WAVS
#define MAX_SOUND_SLICE_TIME 70 /* ms */
#define NUM_CHANNELS 16

int use_libsamplerate = 0;
static boolean use_sfx_prefix;
#ifdef FEATURE_MULTIPLAYER    
typedef struct allocated_sound_s allocated_sound_t;

struct allocated_sound_s
{
    sfxinfo_t *sfxinfo;
    Mix_Chunk chunk;
    int use_count;
    allocated_sound_t *prev, *next;
};

static boolean setpanning_workaround = false;

static boolean sound_initialized = false;

static sfxinfo_t *channels_playing[NUM_CHANNELS];

static int mixer_freq;
static Uint16 mixer_format;
static int mixer_channels;

static boolean (*ExpandSoundData)(sfxinfo_t *sfxinfo,
                                  byte *data,
                                  int samplerate,
                                  int length) = NULL;

// Doubly-linked list of allocated sounds.
// When a sound is played, it is moved to the head, so that the oldest
// sounds not used recently are at the tail.

static allocated_sound_t *allocated_sounds_head = NULL;
static allocated_sound_t *allocated_sounds_tail = NULL;
static int allocated_sounds_size = 0;



// Hook a sound into the linked list at the head.

static void AllocatedSoundLink(allocated_sound_t *snd)
{
    snd->prev = NULL;

    snd->next = allocated_sounds_head;
    allocated_sounds_head = snd;

    if (allocated_sounds_tail == NULL)
    {
        allocated_sounds_tail = snd;
    }
    else
    {
        snd->next->prev = snd;
    }
}

// Unlink a sound from the linked list.

static void AllocatedSoundUnlink(allocated_sound_t *snd)
{
    if (snd->prev == NULL)
    {
        allocated_sounds_head = snd->next;
    }
    else
    {
        snd->prev->next = snd->next;
    }

    if (snd->next == NULL)
    {
        allocated_sounds_tail = snd->prev;
    }
    else
    {
        snd->next->prev = snd->prev;
    }
}

static void FreeAllocatedSound(allocated_sound_t *snd)
{
    // Unlink from linked list.

    AllocatedSoundUnlink(snd);

    // Unlink from higher-level code.

    snd->sfxinfo->driver_data = NULL;

    // Keep track of the amount of allocated sound data:

    allocated_sounds_size -= snd->chunk.alen;

    free(snd);
}

// Search from the tail backwards along the allocated sounds list, find
// and free a sound that is not in use, to free up memory.  Return true
// for success.

static boolean FindAndFreeSound(void)
{
    allocated_sound_t *snd;

    snd = allocated_sounds_tail;

    while (snd != NULL)
    {
        if (snd->use_count == 0)
        {
            FreeAllocatedSound(snd);
            return true;
        }

        snd = snd->prev;
    }

    // No available sounds to free...

    return false;
}

// Enforce SFX cache size limit.  We are just about to allocate "len"
// bytes on the heap for a new sound effect, so free up some space
// so that we keep allocated_sounds_size < snd_cachesize

static void ReserveCacheSpace(size_t len)
{
    if (snd_cachesize <= 0)
    {
        return;
    }

    // Keep freeing sound effects that aren't currently being played,
    // until there is enough space for the new sound.

    while (allocated_sounds_size + len > snd_cachesize)
    {
        // Free a sound.  If there is nothing more to free, stop.

        if (!FindAndFreeSound())
        {
            break;
        }
    }
}

// Allocate a block for a new sound effect.

 
// Lock a sound, to indicate that it may not be freed.

static void LockAllocatedSound(allocated_sound_t *snd)
{
 
}

// Unlock a sound to indicate that it may now be freed.

static void UnlockAllocatedSound(allocated_sound_t *snd)
{
    if (snd->use_count <= 0)
    {
        I_Error("Sound effect released more times than it was locked...");
    }

    --snd->use_count;

    //printf("-- %s: Use count=%i\n", snd->sfxinfo->name, snd->use_count);
}

// When a sound stops, check if it is still playing.  If it is not, 
// we can mark the sound data as CACHE to be freed back for other
// means.

static void ReleaseSoundOnChannel(int channel)
{
 
}
 

// Returns the conversion mode for libsamplerate to use.

static int SRC_ConversionMode(void)
{
 
}

// libsamplerate-based generic sound expansion function for any sample rate
//   unsigned 8 bits --> signed 16 bits
//   mono --> stereo
//   samplerate --> mixer_freq
// Returns number of clipped samples.
// DWF 2008-02-10 with cleanups by Simon Howard.

static boolean ExpandSoundData_SRC(sfxinfo_t *sfxinfo,
                                   byte *data,
                                   int samplerate,
                                   int length)
{
 

    return true;
}

#endif

static boolean ConvertibleRatio(int freq1, int freq2)
{
 
}

#ifdef DEBUG_DUMP_WAVS

// Debug code to dump resampled sound effects to WAV files for analysis.

static void WriteWAV(char *filename, byte *data,
                     uint32_t length, int samplerate)
{
    FILE *wav;
    unsigned int i;
    unsigned short s;

    wav = fopen(filename, "wb");

    // Header

    fwrite("RIFF", 1, 4, wav);
    i = LONG(36 + samplerate);
    fwrite(&i, 4, 1, wav);
    fwrite("WAVE", 1, 4, wav);

    // Subchunk 1

    fwrite("fmt ", 1, 4, wav);
    i = LONG(16);
    fwrite(&i, 4, 1, wav);           // Length
    s = SHORT(1);
    fwrite(&s, 2, 1, wav);           // Format (PCM)
    s = SHORT(2);
    fwrite(&s, 2, 1, wav);           // Channels (2=stereo)
    i = LONG(samplerate);
    fwrite(&i, 4, 1, wav);           // Sample rate
    i = LONG(samplerate * 2 * 2);
    fwrite(&i, 4, 1, wav);           // Byte rate (samplerate * stereo * 16 bit)
    s = SHORT(2 * 2);
    fwrite(&s, 2, 1, wav);           // Block align (stereo * 16 bit)
    s = SHORT(16);
    fwrite(&s, 2, 1, wav);           // Bits per sample (16 bit)

    // Data subchunk

    fwrite("data", 1, 4, wav);
    i = LONG(length);
    fwrite(&i, 4, 1, wav);           // Data length
    fwrite(data, 1, length, wav);    // Data

    fclose(wav);
}

#endif

// Generic sound expansion function for any sample rate.
// Returns number of clipped samples (always 0).

static boolean ExpandSoundData_SDL(sfxinfo_t *sfxinfo,
                                   byte *data,
                                   int samplerate,
                                   int length)
{
    return true;
}

// Load and convert a sound effect
// Returns true if successful

static boolean CacheSFX(sfxinfo_t *sfxinfo)
{
    int lumpnum;
    unsigned int lumplen;
    int samplerate;
    unsigned int length;
    byte *data;

    // need to load the sound

    lumpnum = sfxinfo->lumpnum;
    data = W_CacheLumpNum(lumpnum, PU_STATIC);
    lumplen = W_LumpLength(lumpnum);

    // Check the header, and ensure this is a valid sound

    if (lumplen < 8
     || data[0] != 0x03 || data[1] != 0x00)
    {
        // Invalid sound

        return false;
    }

    // 16 bit sample rate field, 32 bit length field

    samplerate = (data[3] << 8) | data[2];
    length = (data[7] << 24) | (data[6] << 16) | (data[5] << 8) | data[4];

    // If the header specifies that the length of the sound is greater than
    // the length of the lump itself, this is an invalid sound lump

    // We also discard sound lumps that are less than 49 samples long,
    // as this is how DMX behaves - although the actual cut-off length
    // seems to vary slightly depending on the sample rate.  This needs
    // further investigation to better understand the correct
    // behavior.

    if (length > lumplen - 8 || length <= 48)
    {
        return false;
    }

    // The DMX sound library seems to skip the first 16 and last 16
    // bytes of the lump - reason unknown.

    data += 16;
    length -= 32;

    // Sample rate conversion

    //if (!ExpandSoundData(sfxinfo, data + 8, samplerate, length))
    //{
    //    return false;
    //}

#ifdef DEBUG_DUMP_WAVS
    {
        char filename[16];

        sprintf(filename, "%s.wav", DEH_String(S_sfx[sound].name));
        WriteWAV(filename, sound_chunks[sound].abuf,
                 sound_chunks[sound].alen, mixer_freq);
    }
#endif

    // don't need the original lump any more
  
    W_ReleaseLumpNum(lumpnum);

    return true;
}
static void GetSfxLumpName(sfxinfo_t *sfx, char *buf)
{
    // Linked sfx lumps? Get the lump number for the sound linked to.

    if (sfx->link != NULL)
    {
        sfx = sfx->link;
    }

    // Doom adds a DS* prefix to sound lumps; Heretic and Hexen don't
    // do this.

    if (use_sfx_prefix)
    {
        sprintf(buf, "ds%s", DEH_String(sfx->name));
    }
    else
    {
        strcpy(buf, DEH_String(sfx->name));
    }
}

#ifdef HAVE_LIBSAMPLERATE

// Preload all the sound effects - stops nasty ingame freezes

static void I_SDL_PrecacheSounds(sfxinfo_t *sounds, int num_sounds)
{
 
}

#else

static void I_SDL_PrecacheSounds(sfxinfo_t *sounds, int num_sounds)
{
    // no-op
}

#endif

// Load a SFX chunk into memory and ensure that it is locked.

static boolean LockSound(sfxinfo_t *sfxinfo)
{
 

    return true;
}

//
// Retrieve the raw data lump index
//  for a given SFX name.
//

static int I_SDL_GetSfxLumpNum(sfxinfo_t *sfx)
{
    char namebuf[9];
    printf("I_SDL_GetSfxLumpNum.....");
    GetSfxLumpName(sfx, namebuf);
    printf("I_SDL_GetSfxLumpNum.....%s", namebuf);
    return W_GetNumForName(namebuf);
}

static void I_SDL_UpdateSoundParams(int handle, int vol, int sep)
{
 
}

//
// Starting a sound means adding it
//  to the current list of active sounds
//  in the internal channels.
// As the SFX info struct contains
//  e.g. a pointer to the raw data,
//  it is ignored.
// As our sound handling does not handle
//  priority, it is ignored.
// Pitching (that is, increased speed of playback)
//  is set, but currently not used by mixing.
//

static int I_SDL_StartSound(sfxinfo_t *sfxinfo, int channel, int vol, int sep)
{
    return -1;
}

static void I_SDL_StopSound (int handle)
{

        return;

}


static boolean I_SDL_SoundIsPlaying(int handle)
{

        return false;

}

// 
// Periodically called to update the sound system
//

static void I_SDL_UpdateSound(void)
{

}

static void I_SDL_ShutdownSound(void)
{    


   // sound_initialized = false;
}

// Calculate slice size, based on MAX_SOUND_SLICE_TIME.
// The result must be a power of two.

static int GetSliceSize(void)
{

    return 1024;
}

static boolean I_SDL_InitSound(boolean _use_sfx_prefix)
{
    int i;

  //  sound_initialized = true;

    return true;
}

static snddevice_t sound_sdl_devices[] = 
{
    SNDDEVICE_SB,
    SNDDEVICE_PAS,
    SNDDEVICE_GUS,
    SNDDEVICE_WAVEBLASTER,
    SNDDEVICE_SOUNDCANVAS,
    SNDDEVICE_AWE32,
};

sound_module_t sound_sdl_module = 
{
    sound_sdl_devices,
    arrlen(sound_sdl_devices),
    I_SDL_InitSound,
    I_SDL_ShutdownSound,
    I_SDL_GetSfxLumpNum,
    I_SDL_UpdateSound,
    I_SDL_UpdateSoundParams,
    I_SDL_StartSound,
    I_SDL_StopSound,
    I_SDL_SoundIsPlaying,
    I_SDL_PrecacheSounds,
};

