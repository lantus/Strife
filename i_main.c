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
//	Main program, simply calls D_DoomMain high level loop.
//
//-----------------------------------------------------------------------------

#include "config.h"

#include <stdio.h>

#include <exec/exec.h>
#include <workbench/startup.h>
#include <workbench/workbench.h>
#include <workbench/icon.h>

#include <proto/exec.h>
#include <proto/icon.h>

#include "doomtype.h"
#include "i_system.h"
#include "m_argv.h"
#include "m_fixed.h" 

int cpu_type;
int broken_pipe;
extern struct ExecBase *SysBase;

//
// D_DoomMain()
// Not a globally visible function, just included for source reference,
// calls all startup code, parses command line options.
//

void D_DoomMain (void);

#if defined(_WIN32_WCE)

// Windows CE?  I doubt it even supports SMP..

static void LockCPUAffinity(void)
{
}

#elif defined(_WIN32)

#define WIN32_LEAN_AND_MEAN
#include <windows.h>

typedef BOOL (WINAPI *SetAffinityFunc)(HANDLE hProcess, DWORD mask);

// This is a bit more complicated than it really needs to be.  We really
// just need to call the SetProcessAffinityMask function, but that
// function doesn't exist on systems before Windows 2000.  Instead,
// dynamically look up the function and call the pointer to it.  This
// way, the program will run on older versions of Windows (Win9x, etc.)

static void LockCPUAffinity(void)
{
    HMODULE kernel32_dll;
    SetAffinityFunc SetAffinity;

    // Find the kernel interface DLL.

    kernel32_dll = LoadLibrary("kernel32.dll");

    if (kernel32_dll == NULL)
    {
        // This should never happen...

        fprintf(stderr, "Failed to load kernel32.dll\n");
        return;
    }
    // Find the SetProcessAffinityMask function.

    SetAffinity = (SetAffinityFunc)GetProcAddress(kernel32_dll, "SetProcessAffinityMask");

    // If the function was not found, we are on an old (Win9x) system
    // that doesn't have this function.  That's no problem, because
    // those systems don't support SMP anyway.

    if (SetAffinity != NULL)
    {
        if (!SetAffinity(GetCurrentProcess(), 1))
        {
            fprintf(stderr, "Failed to set process affinity (%d)\n",
                            (int) GetLastError());
        }
    }
}

#elif defined(HAVE_SCHED_SETAFFINITY)

#include <unistd.h>
#include <sched.h>

// Unix (Linux) version:

static void LockCPUAffinity(void)
{
#ifdef CPU_SET
    cpu_set_t set;

    CPU_ZERO(&set);
    CPU_SET(0, &set);

    sched_setaffinity(getpid(), sizeof(set), &set);
#else
    unsigned long mask = 1;
    sched_setaffinity(getpid(), sizeof(mask), &mask);
#endif
}

#else

#warning No known way to set processor affinity on this platform.
#warning You may experience crashes due to SDL_mixer.

static void LockCPUAffinity(void)
{
    fprintf(stderr,
    "WARNING: No known way to set processor affinity on this platform.\n"
    "         You may experience crashes due to SDL_mixer.\n");
}

#endif

#define MAXARGVS        100

/* these command line arguments are flags */
  static char *flags[] = {
    "CGX",
    "AGA",
    "NTSC"
  };
  
int main(int argc, char **argv)
{
    int i, p;
    struct WBStartup *argmsg;
    struct WBArg *wb_arg;
    struct DiskObject *obj;
    char **toolarray, *s;
    
    // save arguments

    myargc = argc;
    myargv = argv;

#ifdef _WIN32_WCE

    // Windows CE has no environment, but SDL provides an implementation.
    // Populate the environment with the values we normally find.

    PopulateEnvironment();

#endif

    // Only schedule on a single core, if we have multiple
    // cores.  This is to work around a bug in SDL_mixer.

    //LockCPUAffinity();

    M_FindResponseFile();
 
         
    /* parse icon tooltypes and convert them to argc/argv format */
    
    if (argc <= 1)
    {
        if (argc == 0) {
            argmsg = (struct WBStartup *)argv;
            wb_arg = argmsg->sm_ArgList;
            if ((myargv[myargc] = malloc(strlen(wb_arg->wa_Name)+1)) == NULL)
              I_Error ("malloc(%d) failed", strlen(wb_arg->wa_Name)+1);
    
            strcpy (myargv[myargc++], wb_arg->wa_Name);
        }
        if ((obj = GetDiskObject (myargv[0])) != NULL) {
            toolarray = obj->do_ToolTypes;
            for (i = 0; i < sizeof(flags)/sizeof(flags[0]); i++) {
              if (FindToolType (toolarray, &flags[i][0]) != NULL) {
                myargv[myargc++] = flags[i];
              }
            }
    
            FreeDiskObject (obj);
        }
    
        if (argc != myargc) {
            printf ("\nIcon tooltypes translated command line to:\n\n    ");
            for (i = 0; i < myargc; i++)
              printf (" %s", myargv[i]);
            printf ("\n\n");
        }
    }
    else
    {
        printf ("\Overriding Icon tooltypes command line with :\n\n    ");
            for (i = 0; i < argc; i++)
              printf (" %s", argv[i]);
            printf ("\n\n");
    }

    // start doom
    
    if ((SysBase->AttnFlags & AFF_68060) != 0)
        cpu_type = 68060;
    else if ((SysBase->AttnFlags & AFF_68040) != 0)
        cpu_type = 68040;
    else if ((SysBase->AttnFlags & AFF_68030) != 0)
        cpu_type = 68030;
    else if ((SysBase->AttnFlags & AFF_68020) != 0)
        cpu_type = 68020;
    else if ((SysBase->AttnFlags & AFF_68010) != 0)
        cpu_type = 68010;
    else
        cpu_type = 68000;
    
    Disable();
    
    if (cpu_type >= 68060) {
        if ((SysBase->AttnFlags & AFF_68881) != 0) {
          SetFPMode ();  /* set FPU rounding mode to "trunc towards -infinity" */
          FixedMul = FixedMul_060fpu;
          FixedDiv = FixedDiv_060fpu;
        } else {
    
    }
    } else {
        FixedMul = FixedMul_040;
        FixedDiv = FixedDiv_040;
    }    
    
    Enable();
    D_DoomMain ();

    Exit(0);
    
    return 0;
}

