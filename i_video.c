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
//	DOOM graphics stuff for Amiga OS Native AGA 320x256.
//
//-----------------------------------------------------------------------------


#include <stdlib.h>
#include <ctype.h>
#include <math.h>
#include <string.h>

#ifdef _WIN32
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#endif

#include <exec/exec.h>
#include <dos/dos.h>
#include <graphics/gfx.h>
#include <graphics/gfxbase.h>
#include <graphics/gfxmacros.h>
#include <intuition/intuition.h>
#include <libraries/asl.h>
#include <libraries/lowlevel.h>
#include <devices/gameport.h>
#include <devices/timer.h>
#include <devices/keymap.h>
#include <devices/input.h>
#include <devices/inputevent.h>

#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/graphics.h>
#include <proto/layers.h>
#include <proto/intuition.h>
#include <proto/asl.h>
#include <proto/keymap.h>
#include <proto/lowlevel.h>

#include <cybergraphx/cybergraphics.h>
#include <proto/cybergraphics.h>
#include <inline/cybergraphics.h>

#include "icon.c"

#include "config.h"
#include "deh_str.h"
#include "doomtype.h"
#include "doomkeys.h"
#include "i_joystick.h"
#include "i_system.h"
#include "i_swap.h"
#include "i_timer.h"
#include "i_video.h"
#include "i_scale.h"
#include "m_argv.h"
#include "m_config.h"
#include "tables.h"
#include "v_video.h"
#include "w_wad.h"
#include "z_zone.h"

#include "amiga_mmu.h"

#define REG(xn, parm) parm __asm(#xn)
#define REGARGS __regargs
#define STDARGS __stdargs
#define SAVEDS __saveds
#define ALIGNED __attribute__ ((aligned(4))
#define FAR
#define CHIP
#define INLINE __inline__

int usegamma = 0;
byte *I_VideoBuffer = NULL;
boolean screensaver_mode = false;
static UBYTE *screenpixels;
static boolean initialized = false;
static byte *disk_image = NULL;
static byte *saved_background;
float mouse_acceleration = 2.0;
int mouse_threshold = 10;
static boolean nomouse = false;
int usemouse = 1;
static boolean display_fps_dots;
boolean screenvisible = 1;


extern void REGARGS c2p1x1_8_c5_bm_040(
REG(d0, UWORD chunky_x),
REG(d1, UWORD chunky_y),
REG(d2, UWORD offset_x),
REG(d3, UWORD offset_y),
REG(a0, UBYTE *chunky_buffer),
REG(a1, struct BitMap *bitmap));

extern int cpu_type;
extern void mmu_stuff2(void);
extern void mmu_stuff2_cleanup(void);

int mmu_chunky = 0;
int mmu_active = 0;

static int xlate[0x68] = {
  '`', '1', '2', '3', '4', '5', '6', '7',
  '8', '9', '0', KEY_MINUS, KEY_EQUALS, '\\', 0, '0',
  'q', 'w', 'e', 'r', 't', 'y', 'u', 'i',
  'o', 'p', KEY_F11, KEY_F12, 0, '0', '2', '3',
  'a', 's', 'd', 'f', 'g', 'h', 'j', 'k',
  'l', ';', '\'', KEY_ENTER, 0, '4', '5', '6',
  KEY_RSHIFT, 'z', 'x', 'c', 'v', 'b', 'n', 'm',
  ',', '.', '/', 0, '.', '7', '8', '9',
  ' ', KEY_BACKSPACE, KEY_TAB, KEY_ENTER, KEY_ENTER, KEY_ESCAPE, KEY_F11,
  0, 0, 0, KEY_MINUS, 0, KEY_UPARROW, KEY_DOWNARROW, KEY_RIGHTARROW, KEY_LEFTARROW,
  KEY_F1, KEY_F2, KEY_F3, KEY_F4, KEY_F5, KEY_F6, KEY_F7, KEY_F8,
  KEY_F9, KEY_F10, '(', ')', '/', '*', KEY_EQUALS, KEY_PAUSE,
  KEY_RSHIFT, KEY_RSHIFT, 0, KEY_RCTRL, KEY_LALT, KEY_RALT, 0, KEY_RCTRL
};
 
/** Hardware window */
struct Window *_hardwareWindow;
/** Hardware screen */
struct Screen *_hardwareScreen;
// Hardware double buffering.
struct ScreenBuffer *_hardwareScreenBuffer[2];
byte _currentScreenBuffer;


enum videoMode
{
    VideoModeAGA,
    VideoModeEHB,
    VideoModeRTG,
    VideoModeINDIVISION
};
 
enum videoMode vidMode = VideoModeAGA;

// RTG Stuff

struct Library *CyberGfxBase = NULL;
static APTR video_bitmap_handle = NULL;

static UWORD emptypointer[] = {
  0x0000, 0x0000,    /* reserved, must be NULL */
  0x0000, 0x0000,     /* 1 row of image data */
  0x0000, 0x0000    /* reserved, must be NULL */
};

#define LOADING_DISK_W 16
#define LOADING_DISK_H 16

int xlate_key (UWORD rawkey, UWORD qualifier, APTR eventptr)
{
  char buffer[4], c;
  struct InputEvent ie;
  
  if (rawkey > 0x00 && rawkey < 0x0a) // '1'..'9', no SHIFT French keyboards
      return '0' + rawkey;
    else if (rawkey == 0x0a)            // '0'
      return '0';
    else if (rawkey < 0x40) {
      ie.ie_Class = IECLASS_RAWKEY;
      ie.ie_Code = rawkey;
      ie.ie_Qualifier = qualifier;
      ie.ie_EventAddress = eventptr;
      if (MapRawKey (&ie, buffer, sizeof(buffer), NULL) > 0) {
        c = buffer[0];
        if (c >= '0' && c <= '9')       /* numeric pad */
          switch (c) {
          case '0':
            return ' ';
          case '1':
            return ',';
          case '2':
            return KEY_RCTRL;
          case '3':
            return '.';
          case '4':
            return KEY_LEFTARROW;
          case '5':
            return KEY_DOWNARROW;
          case '6':
            return KEY_RIGHTARROW;
          case '7':
            return ',';
          case '8':
            return KEY_UPARROW;
          case '9':
            return '.';
          }
        else if (c >= 'A' && c <= 'Z')
          return c - 'A' + 'a';
        else if (c == '<')
          return ',';
        else if (c == '>')
          return '.';
        else if (c == '-')
          return KEY_MINUS;
        else if (c == '=')
          return KEY_EQUALS;
        else if (c == '[')
          return KEY_F11;
        else if (c == ']')
          return KEY_F12;
        else if (c == '\r')
          return KEY_ENTER;
        else if (c == '\n')
          return KEY_ENTER;
        else
          return c;
      } else
        return 0;
    } else if (rawkey < 0x68)
      return xlate[rawkey];
    else
      return 0;

}


void I_SetWindowTitle(char *title)
{
    printf("I_SetWindowTitle : %s\n", title);
}

void I_SetGrabMouseCallback(grabmouse_callback_t func)
{
     
}

void I_EnableLoadingDisk(void)
{

    patch_t *disk;
    byte *tmpbuf;
    char *disk_name;
    int y;
    char buf[20];

    if (M_CheckParm("-cdrom") > 0)
        disk_name = DEH_String("STCDROM");
    else
        disk_name = DEH_String("STDISK");

    disk = W_CacheLumpName(disk_name, PU_STATIC);

    // Draw the patch into a temporary buffer

    tmpbuf = Z_Malloc(SCREENWIDTH * (disk->height + 1), PU_STATIC, NULL);
    V_UseBuffer(tmpbuf);

    // Draw the disk to the screen:

    V_DrawPatch(0, 0, disk);

    disk_image = Z_Malloc(LOADING_DISK_W * LOADING_DISK_H, PU_STATIC, NULL);
    saved_background = Z_Malloc(LOADING_DISK_W * LOADING_DISK_H, PU_STATIC, NULL);

    for (y=0; y<LOADING_DISK_H; ++y) 
    {
        memcpy(disk_image + LOADING_DISK_W * y,
               tmpbuf + SCREENWIDTH * y,
               LOADING_DISK_W);
    }

    // All done - free the screen buffer and restore the normal 
    // video buffer.

    W_ReleaseLumpName(disk_name);
    V_RestoreBuffer();
    Z_Free(tmpbuf);
    
}

void I_StartTic (void)
{    
    event_t event;
    ULONG class;
    UWORD code;
    WORD mousex, mousey;
    struct IntuiMessage *msg;
    static ULONG previous = 0;
    static event_t joyevent = {0}, mouseevent = {0};
    int doomkey;      
    
  if (_hardwareWindow != NULL && _hardwareWindow->UserPort != NULL) {
    while ((msg = (struct IntuiMessage *)GetMsg (_hardwareWindow->UserPort)) != NULL) {
      class = msg->Class;
      code = msg->Code;
      mousex = msg->MouseX;
      mousey = msg->MouseY;
      if (class == IDCMP_RAWKEY) {
        if ((code & 0x80) != 0) {
          code &= ~0x80;
      event.type = ev_keyup;
        } else {
          event.type = ev_keydown;
        }
        if (code < 0x68)
          doomkey = xlate_key (code, msg->Qualifier, msg->IAddress);
      }
      ReplyMsg ((struct Message *)msg);  /* reply after xlating key */
      if (class == IDCMP_RAWKEY) {
        if (code < 0x68 && doomkey != 0) {
          event.data1 = doomkey;
          D_PostEvent (&event);
          /* printf ("key %02x -> %02x\n", code, doomkey); */
        }
      } else if (class == IDCMP_MOUSEMOVE) {
        mouseevent.type = ev_mouse;
        mouseevent.data2 = (mousex << 3);
      //  mouseevent.data3 = -(mousey << 5);
        D_PostEvent (&mouseevent);
      } else if (class == IDCMP_MOUSEBUTTONS) {
        mouseevent.type = ev_mouse;
        switch (code) {
          case SELECTDOWN:
            mouseevent.data1 |= 1;
            break;
          case SELECTUP:
            mouseevent.data1 &= ~1;
            break;
          case MENUDOWN:
            mouseevent.data1 |= 2;
            break;
          case MENUUP:
            mouseevent.data1 &= ~2;
            break;
          case MIDDLEDOWN:
            mouseevent.data1 |= 4;
            break;
          case MIDDLEUP:
            mouseevent.data1 &= ~4;
            break;
          default:
            break;
        }
        D_PostEvent (&mouseevent); 
      }
    }
  }
      
}


void I_BeginRead(void)
{   
    byte *screenloc = I_VideoBuffer
                    + (SCREENHEIGHT - LOADING_DISK_H) * SCREENWIDTH
                    + (SCREENWIDTH - LOADING_DISK_W);
    int y;

    if (!initialized || disk_image == NULL)
        return;

    // save background and copy the disk image in

    for (y=0; y<LOADING_DISK_H; ++y)
    {
        memcpy(saved_background + y * LOADING_DISK_W,
               screenloc,
               LOADING_DISK_W);
        memcpy(screenloc,
               disk_image + y * LOADING_DISK_W,
               LOADING_DISK_W);

        screenloc += SCREENWIDTH;
    }
 
}

void I_EndRead(void)
{
           
    byte *screenloc = I_VideoBuffer
                    + (SCREENHEIGHT - LOADING_DISK_H) * SCREENWIDTH
                    + (SCREENWIDTH - LOADING_DISK_W);
    int y;

    if (!initialized || disk_image == NULL)
        return;

    // save background and copy the disk image in

    for (y=0; y<LOADING_DISK_H; ++y)
    {
        memcpy(screenloc,
               saved_background + y * LOADING_DISK_W,
               LOADING_DISK_W);

        screenloc += SCREENWIDTH;
    }
 
}

//
// I_StartFrame
//
void I_StartFrame (void)
{
}

//
// I_InitInputs
//

static void I_InitInputs(void)
{
  I_InitJoystick();
}
 
static  ULONG colorsAGA[770];
///////////////////////////////////////////////////////////
// Palette stuff.
//
 

//////////////////////////////////////////////////////////////////////////////
// Graphics API

void I_ShutdownGraphics(void)
{
    
   if (_hardwareWindow) {
        ClearPointer(_hardwareWindow);
        CloseWindow(_hardwareWindow);
        _hardwareWindow = NULL;
    }
 
    if (_hardwareScreenBuffer[0]) { 
        WaitBlit();
        FreeScreenBuffer(_hardwareScreen, _hardwareScreenBuffer[0]);
    }

    if (_hardwareScreenBuffer[1]) { 
        WaitBlit();
        FreeScreenBuffer(_hardwareScreen, _hardwareScreenBuffer[1]);
    }

    if (_hardwareScreen) { 
        CloseScreen(_hardwareScreen);
        _hardwareScreen = NULL;
    }    
    
    if (mmu_active)
    {
        WaitBlit();
		mmu_mark(screenpixels,(320 * 200 + 4095) & (~0xFFF),mmu_chunky,SysBase);
		mmu_active = 0;
    }    
        
    if (screenpixels)
    {
        free(screenpixels);
        screenpixels = NULL;
    }   
    
    if (CyberGfxBase)
    {
        CloseLibrary(CyberGfxBase);
        CyberGfxBase = NULL;
    }    
}

//
// I_UpdateNoBlit
//
void I_UpdateNoBlit (void)
{
}

//
// I_FinishUpdate
//

void I_FinishUpdate (void)
{
    static int	lasttic;
    int		tics;
    int		i;    
    UBYTE *base_address;    
 
    if (vidMode == VideoModeAGA)
    {
        c2p1x1_8_c5_bm_040(320,200,0,0,screenpixels,_hardwareScreenBuffer[_currentScreenBuffer]->sb_BitMap);
        ChangeScreenBuffer(_hardwareScreen, _hardwareScreenBuffer[_currentScreenBuffer]); 
        _currentScreenBuffer = _currentScreenBuffer ^ 1;	 
    }
    else
    {
        video_bitmap_handle = LockBitMapTags (_hardwareScreen->ViewPort.RasInfo->BitMap,
                                              LBMI_BASEADDRESS, &base_address,
                                              TAG_DONE);
        if (video_bitmap_handle) {
            CopyMemQuick (screenpixels, base_address, 320 * 200);
            UnLockBitMap (video_bitmap_handle);
            video_bitmap_handle = NULL;
        }
    }    
    
}

void I_CheckIsScreensaver(void)
{
 
}

 
void I_DisplayFPSDots(boolean dots_on)
{
    display_fps_dots = dots_on;
}


//
// I_ReadScreen
//
void I_ReadScreen (byte* scr)
{
   memcpy(scr, I_VideoBuffer, SCREENWIDTH*SCREENHEIGHT);
}

//
// I_SetPalette
//
void I_SetPalette (byte *doompalette)
{
 
    int i;   
    int j = 1;

   
    
    for (i=0; i<256; ++i) 
    {
        colorsAGA[j]   = gammatable[usegamma][*doompalette++] << 24;
        colorsAGA[j+1] = gammatable[usegamma][*doompalette++] << 24;
        colorsAGA[j+2] = gammatable[usegamma][*doompalette++] << 24;
        
        j+=3;
    } 
    
    colorsAGA[0]=((256)<<16) ;
    colorsAGA[((256*3)+1)]=0x00000000;
    LoadRGB32(&_hardwareScreen->ViewPort, &colorsAGA);
 
}

// I_PreInitGraphics

 

void I_PreInitGraphics(void)
{
 
}
 

void I_InitGraphics(void)
{
    byte *doompal;
    char titlebuffer[256];
    static int    firsttime=1;
    uint i = 0;
    ULONG modeId = INVALID_ID;
  
    _hardwareWindow = NULL;
    _hardwareScreenBuffer[0] = NULL;
    _hardwareScreenBuffer[1] = NULL;
    _currentScreenBuffer = 0;
    _hardwareScreen = NULL;

    if (firsttime)
    {
      
        firsttime = 0;
        screenpixels = (unsigned char *)malloc(320*200);
        
        if (M_CheckParm ("-ntsc"))
        {
            printf("I_InitGraphics: NTSC mode set \n");
            modeId = NTSC_MONITOR_ID;
        }
        else
            modeId = PAL_MONITOR_ID;
        
        printf("I_InitGraphics: CPU : %d\n", cpu_type); 
        
      
	    
	    if (M_CheckParm ("-aga"))
        {
                
        vidMode = VideoModeAGA;                    
        modeId = BestModeID(BIDTAG_NominalWidth, 320,
                            BIDTAG_NominalHeight, 200,
                	        BIDTAG_DesiredWidth, 320,
                	        BIDTAG_DesiredHeight, 200,
                	        BIDTAG_Depth, 8,
                	        BIDTAG_MonitorID, modeId,
                	        TAG_END);
                	        
        }
        
        if (M_CheckParm ("-cgx") || M_CheckParm ("CGX"))
        {

            printf("RTG mode set \n");
            vidMode = VideoModeRTG;    
          
            
            CyberGfxBase = OpenLibrary ("cybergraphics.library", 0);
        	if (CyberGfxBase == NULL) {
		      I_Error("Cannot open cybergraphics.library");
        	}            
        	
            if (CyberGfxBase != NULL)
            {
                modeId = BestCModeIDTags(CYBRBIDTG_NominalWidth, 320,
                                         CYBRBIDTG_NominalHeight, 240,
                                         CYBRBIDTG_Depth,8,
                                         TAG_DONE);        	
            }

        }
        
        if (M_CheckParm ("-mmu") && cpu_type >= 68040 && vidMode != VideoModeRTG)
    	{
    		mmu_chunky = mmu_mark(screenpixels,(320 * 200 + 4095) & (~0xFFF),CM_WRITETHROUGH,SysBase);
    		mmu_active = 1;

            printf("I_InitGraphics: MMU Active\n", cpu_type);
	    }        
        
        
        if(modeId == INVALID_ID) {
          I_Error("Could not find a valid screen mode");
        }
        
         _hardwareScreen = OpenScreenTags(NULL,
                         SA_Depth, 8,
                         SA_DisplayID, modeId,
                         SA_Width, 320,
                         SA_Height,200,
                         SA_Type, CUSTOMSCREEN,
                         SA_Overscan, OSCAN_TEXT,
                         SA_Quiet,TRUE,
                         SA_ShowTitle, FALSE,
                         SA_Draggable, FALSE,
                         SA_Exclusive, TRUE,
                         SA_AutoScroll, FALSE,
                         TAG_END);
        
        
        // Create the hardware screen.
        
        
        _hardwareScreenBuffer[0] = AllocScreenBuffer(_hardwareScreen, NULL, SB_SCREEN_BITMAP);
        _hardwareScreenBuffer[1] = AllocScreenBuffer(_hardwareScreen, NULL, 0);
 
        _currentScreenBuffer = 1;
        
        _hardwareWindow = OpenWindowTags(NULL,
                      	    WA_Left, 0,
                			WA_Top, 0,
                			WA_Width, 320,
                			WA_Height, 200,
                			WA_Title, NULL,
        					SA_AutoScroll, FALSE,
                			WA_CustomScreen, (ULONG)_hardwareScreen,
                			WA_Backdrop, TRUE,
                			WA_Borderless, TRUE,
                			WA_DragBar, FALSE,
                			WA_Activate, TRUE,
                			WA_SimpleRefresh, TRUE,
                			WA_NoCareRefresh, TRUE,
                			WA_ReportMouse, TRUE,
                			WA_RMBTrap, TRUE,
                      	    WA_IDCMP,  IDCMP_RAWKEY | IDCMP_MOUSEMOVE | IDCMP_DELTAMOVE | IDCMP_MOUSEBUTTONS,
                      	    TAG_END);
        
        SetPointer (_hardwareWindow, emptypointer, 1, 16, 0, 0);
 
        printf("I_InitGraphics: %dx%d\n", SCREENWIDTH, SCREENHEIGHT); 
        
        doompal = W_CacheLumpName(DEH_String("PLAYPAL"), PU_CACHE);
        I_SetPalette(doompal);
            
        I_VideoBuffer = (unsigned char *) (screenpixels);
        
        
        /* Initialize the input system */
        I_InitInputs();
        
        V_RestoreBuffer();
    
        // Clear the screen to black.

        memset(I_VideoBuffer, 0, SCREENWIDTH * SCREENHEIGHT);
        
        initialized = true;

        // Call I_ShutdownGraphics on quit

        I_AtExit(I_ShutdownGraphics, true);        
            
    }
}
 

// Bind all variables controlling video options into the configuration
// file system.


void I_BindVideoVariables(void)
{
/*    M_BindVariable("use_mouse",                 &usemouse);
    M_BindVariable("autoadjust_video_settings", &autoadjust_video_settings);
    M_BindVariable("fullscreen",                &fullscreen);
    M_BindVariable("aspect_ratio_correct",      &aspect_ratio_correct);
    M_BindVariable("startup_delay",             &startup_delay);
    M_BindVariable("screen_width",              &screen_width);
    M_BindVariable("screen_height",             &screen_height);
    M_BindVariable("screen_bpp",                &screen_bpp);
    M_BindVariable("grabmouse",                 &grabmouse);
    M_BindVariable("mouse_acceleration",        &mouse_acceleration);
    M_BindVariable("mouse_threshold",           &mouse_threshold);
    M_BindVariable("video_driver",              &video_driver);
    M_BindVariable("usegamma",                  &usegamma);
    M_BindVariable("vanilla_keyboard_mapping",  &vanilla_keyboard_mapping);
    M_BindVariable("novert",                    &novert); */
 
}

