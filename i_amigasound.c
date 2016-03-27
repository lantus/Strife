#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>

#include <exec/exec.h>
#include <dos/dos.h>
#include <graphics/gfxbase.h>
#include <devices/audio.h>

#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/graphics.h>
#include <proto/doomsnd.h>

/* #include <math.h> */

#include "z_zone.h"

#include "i_system.h"
#include "i_sound.h"
#include "m_argv.h"
#include "m_misc.h"
#include "w_wad.h"

#include "doomdef.h"

#include "sounds.h"

#include "doomsound.h"
 
// Any value of numChannels set
// by the defaults code in M_misc is now clobbered by I_InitSound().
// number of channels available for sound effects

int numChannels;
int use_libsamplerate = 0;
/**********************************************************************/
#define MAXSFXVOICES    16   /* max number of Sound Effects with server */
#define MAXNUMCHANNELS   4   /* max number of Amiga sound channels */


struct channel_info {
  struct MsgPort *audio_mp;
  struct IOAudio *audio_io;
  BOOL sound_in_progress;
};


static struct MsgPort *audio_mp = NULL;
static struct IOAudio *audio_io = NULL;
static BOOL audio_is_open = FALSE;


static struct Library *DoomSndBase = NULL;
 
/**********************************************************************/
//
// This function loads the sound data for sfxname from the WAD lump,
// and returns a ptr to the data in fastmem and its length in len.
//
static void *getsfx (char *sfxname, int *len, int voice)
{
  unsigned char*      sfx;
  unsigned char*      paddedsfx;
  int                 i;
  int                 size;
  int                 paddedsize;
  char                name[20];
  int                 sfxlump;

  // Get the sound data from the WAD, allocate lump
  //  in zone memory.
  
  if (!voice)
    sprintf(name, "ds%s", sfxname);
  else
    sprintf(name, "%s", sfxname);

  // Now, there is a severe problem with the
  //  sound handling, in it is not (yet/anymore)
  //  gamemode aware. That means, sounds from
  //  DOOM II will be requested even with DOOM
  //  shareware.
  // The sound list is wired into sounds.c,
  //  which sets the external variable.
  // I do not do runtime patches to that
  //  variable. Instead, we will use a
  //  default sound for replacement.

  sfxlump = W_GetNumForName (name);

  size = W_LumpLength (sfxlump);

  // Debug.
  // fprintf( stderr, "." );
  // fprintf( stderr, " -loading  %s (lump %d, %d bytes)\n",
  //         sfxname, sfxlump, size );
  //fflush( stderr );

  sfx = (unsigned char*)W_CacheLumpNum (sfxlump, PU_STATIC);

  // Allocate from zone memory.
  paddedsfx = (unsigned char*)Z_Malloc (size, PU_STATIC, 0);
  // ddt: (unsigned char *) realloc(sfx, paddedsize+8);
  // This should interfere with zone memory handling,
  //  which does not kick in in the soundserver.

  // Now copy and pad.
  for (i = 0; i < size; i++)
    paddedsfx[i] = sfx[i] ^ 0x80;
  /* memcpy (paddedsfx, sfx, size); */

  // Remove the cached lump.
  Z_Free( sfx );

  // Preserve padded length.
  *len = size;

  // Return allocated padded data.
  return (void *) (paddedsfx /* + 8 */);
} 

/**********************************************************************/
// Init at program start...
void I_Amiga_InitSound(boolean use_sfx_prefix)
{
  int i;
  
  
  
    if (M_CheckParm("-nosfx"))
      return;
    
// Secure and configure sound device first.
  fprintf( stderr, "I_InitSound: ");
  
if ((DoomSndBase = OpenLibrary ("doomsound.library",37)) != NULL) {
      Sfx_SetVol(64);
    Mus_SetVol(64);
    numChannels = 4; }
     else{
  fprintf (stderr, " Cannot open doomsound.library, music not available.\n" );
    fprintf( stderr, "I_InitSound: ");
    }
 
   for (i = 1; i < NUMSFX; i++) {
    // Alias? Example is the chaingun sound linked to pistol.
    if (!S_sfx[i].link) {
      // Load data from WAD file.
      S_sfx[i].driver_data = getsfx (S_sfx[i].name, &S_sfx[i].length, 0);
    } else {
      // Previously loaded already?
      S_sfx[i].driver_data = S_sfx[i].link->driver_data;
      S_sfx[i].length = S_sfx[i].link->length;
//   //   lengths[i] = lengths[(S_sfx[i].link - S_sfx)/sizeof(sfxinfo_t)];
    }
  }
  
  fprintf (stderr, "I_InitSound: sound module ready\n");
                                                        
}
/**********************************************************************/
// ... update sound buffer and audio device at runtime...
void I_Amiga_UpdateSound (void)
{
  /* fprintf (stderr, "I_UpdateSound()\n"); */
}

/**********************************************************************/
// ... update sound buffer and audio device at runtime...
void I_SubmitSound (void)
{
  /* fprintf (stderr, "I_SubmitSound()\n"); */
  // Write it to DSP device.
  // write(audio_fd, mixbuffer, SAMPLECOUNT*BUFMUL);
}

/**********************************************************************/
// ... shut down and relase at program termination.
void I_Amiga_ShutdownSound (void)
{
  int i;

  /* fprintf (stderr, "I_ShutdownSound()\n"); */

  if (DoomSndBase != NULL) {
    CloseLibrary (DoomSndBase);
    DoomSndBase = NULL;
  }

  if (audio_is_open) {
    for (i = 0; i < numChannels; i++)
      I_StopSound (i);
    audio_io->ioa_Request.io_Unit = (struct Unit *)
                     ((1 << numChannels) - 1);  /* free numChannels channels */
    CloseDevice ((struct IORequest *)audio_io);
    audio_is_open = FALSE;
  }

  if (audio_io != NULL) {
    FreeMem (audio_io, sizeof(struct IOAudio));
    audio_io = NULL;
  }
  if (audio_mp != NULL) {
    DeletePort (audio_mp);
    audio_mp = NULL;
  }
}

/**********************************************************************/
/**********************************************************************/
//
//  SFX I/O
//

/**********************************************************************/
// Initialize number of channels
void I_SetChannels (void)
{
}

/**********************************************************************/
// Get raw data lump index for sound descriptor.
int I_Amiga_GetSfxLumpNum (sfxinfo_t *sfx)
{
  char namebuf[9];

  /* fprintf (stderr, "I_GetSfxLumpNum()\n"); */
  sprintf(namebuf, "ds%s", sfx->name);
  return W_GetNumForName(namebuf);
}

int I_Amiga_StartSound(sfxinfo_t *sfxinfo, int channel, int vol, int sep)
{
  // HACK : suppress that annoying popping noise. Fix this properly!!
  if (strcmp(sfxinfo->name,"smfire") == 0)
    return;
    
  if (sfxinfo->driver_data == NULL)
  {
        // cache in voices
        sfxinfo->driver_data = getsfx(sfxinfo->name,&sfxinfo->length, 1);
  }
 
  if (DoomSndBase != NULL) {
    I_StopSound(channel);
        
    Sfx_Start (sfxinfo->driver_data, channel, 11025,
               vol, sep, sfxinfo->length );
    return channel;
  }
}
 
void I_Amiga_StopSound(int handle)
{
  /* fprintf (stderr, "I_StopSound(%d)\n", handle); */

  if (DoomSndBase != NULL) {
    Sfx_Stop(handle);
    return;
  }

  if (!audio_is_open)
    return;
  
}

/**********************************************************************/
// Called by S_*() functions
//  to see if a channel is still playing.
// Returns 0 if no longer playing, 1 if playing.
boolean I_Amiga_SoundIsPlaying(int handle)
{
  /* fprintf (stderr, "I_SoundIsPlaying(%d)\n", handle); */

  if (DoomSndBase != NULL) {
    return Sfx_Done(handle) ? 1 : 0;
  }

  if (!audio_is_open)
    return 0;
   
}

static void I_Amiga_PrecacheSounds(sfxinfo_t *sounds, int num_sounds)
{
    // no-op
}

/**********************************************************************/
// Updates the volume, separation,
//  and pitch of a sound channel.

void I_Amiga_UpdateSoundParams(int handle, int vol, int sep)
{
/*
void
I_UpdateSoundParams
( int		handle,
  int		vol,
  int		sep,
  int		pitch )
{ */
/*
  fprintf (stderr, "I_UpdateSoundParams(%d,%d,%d,%d)\n", handle, vol,
           sep, pitch);
*/

  if (DoomSndBase != NULL) {
    Sfx_Update(handle, 11025, vol, sep);
    return;
  }

  if (!audio_is_open)
    return;

}

static snddevice_t sound_amiga_devices[] =
{
    SNDDEVICE_PAULA,
};

sound_module_t sound_amiga_module =
{
    sound_amiga_devices,
    arrlen(sound_amiga_devices),
    I_Amiga_InitSound,
    I_Amiga_ShutdownSound,
    I_Amiga_GetSfxLumpNum,
    I_Amiga_UpdateSound,
    I_Amiga_UpdateSoundParams,
    I_Amiga_StartSound,
    I_Amiga_StopSound,
    I_Amiga_SoundIsPlaying,
    I_Amiga_PrecacheSounds,
};


