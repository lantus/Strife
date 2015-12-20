#ifndef _INCLUDE_PRAGMA_DOOMSND_LIB_H
#define _INCLUDE_PRAGMA_DOOMSND_LIB_H

 
#pragma amicall(DoomSndBase,0x01e,Sfx_SetVol(d0))
#pragma amicall(DoomSndBase,0x024,Sfx_Start(a0,d0,d1,d2,d3,d4))
#pragma amicall(DoomSndBase,0x02a,Sfx_Update(d0,d1,d2,d3))
#pragma amicall(DoomSndBase,0x030,Sfx_Stop(d0))
#pragma amicall(DoomSndBase,0x036,Sfx_Done(d0))
#pragma amicall(DoomSndBase,0x03c,Mus_SetVol(d0))
#pragma amicall(DoomSndBase,0x042,Mus_Register(a0))
#pragma amicall(DoomSndBase,0x048,Mus_Unregister(d0))
#pragma amicall(DoomSndBase,0x04e,Mus_Play(d0,d1))
#pragma amicall(DoomSndBase,0x054,Mus_Stop(d0))
#pragma amicall(DoomSndBase,0x05a,Mus_Pause(d0))
#pragma amicall(DoomSndBase,0x060,Mus_Resume(d0))
#pragma amicall(DoomSndBase,0x066,Mus_Done(d0))
 
#endif	/*  _INCLUDE_PRAGMA_DOOMSND_LIB_H  */
