# Project: Strife
# Compiler: m68k-Amiga-OS3
# Compiler Type: MingW 3
# Makefile created by wxDev-C++ 6.10.2 on 04/03/13 07:04

CPP       = g++
CC        = gcc
WINDRES   = windres.exe
OBJ       = amiga_m68k/d_event.o amiga_m68k/d_iwad.o amiga_m68k/i_endoom.o amiga_m68k/i_joystick.o amiga_m68k/i_main.o amiga_m68k/i_scale.o amiga_m68k/i_sound.o amiga_m68k/i_system.o amiga_m68k/i_timer.o amiga_m68k/i_video.o amiga_m68k/icon.o amiga_m68k/m_argv.o amiga_m68k/m_bbox.o amiga_m68k/m_cheat.o amiga_m68k/m_config.o amiga_m68k/m_controls.o amiga_m68k/m_fixed.o amiga_m68k/m_misc.o amiga_m68k/md5.o amiga_m68k/memio.o amiga_m68k/mus2mid.o amiga_m68k/net_common.o amiga_m68k/net_io.o amiga_m68k/net_loop.o amiga_m68k/net_packet.o amiga_m68k/net_query.o amiga_m68k/net_structrw.o amiga_m68k/tables.o amiga_m68k/v_video.o amiga_m68k/w_checksum.o amiga_m68k/w_file.o amiga_m68k/w_file_stdc.o amiga_m68k/w_main.o amiga_m68k/w_merge.o amiga_m68k/w_wad.o amiga_m68k/z_zone.o amiga_m68k/d_main.o amiga_m68k/am_map.o amiga_m68k/d_items.o amiga_m68k/d_net.o amiga_m68k/doomdef.o amiga_m68k/doomstat.o amiga_m68k/dstrings.o amiga_m68k/f_finale.o amiga_m68k/f_wipe.o amiga_m68k/g_game.o amiga_m68k/hu_lib.o amiga_m68k/hu_stuff.o amiga_m68k/info.o amiga_m68k/m_menu.o amiga_m68k/m_random.o amiga_m68k/m_saves.o amiga_m68k/p_ceilng.o amiga_m68k/p_dialog.o amiga_m68k/p_doors.o amiga_m68k/p_enemy.o amiga_m68k/p_floor.o amiga_m68k/p_inter.o amiga_m68k/p_lights.o amiga_m68k/p_map.o amiga_m68k/p_maputl.o amiga_m68k/p_mobj.o amiga_m68k/p_plats.o amiga_m68k/p_pspr.o amiga_m68k/p_saveg.o amiga_m68k/p_setup.o amiga_m68k/p_sight.o amiga_m68k/p_spec.o amiga_m68k/p_switch.o amiga_m68k/p_telept.o amiga_m68k/p_tick.o amiga_m68k/p_user.o amiga_m68k/r_bsp.o amiga_m68k/r_data.o amiga_m68k/r_draw.o amiga_m68k/r_main.o amiga_m68k/r_plane.o amiga_m68k/r_segs.o amiga_m68k/r_sky.o amiga_m68k/r_things.o amiga_m68k/s_sound.o amiga_m68k/sounds.o amiga_m68k/st_lib.o amiga_m68k/st_stuff.o amiga_m68k/wi_stuff.o amiga_m68k/net_sdl.o amiga_m68k/d_mode.o amiga_m68k/midifile.o amiga_m68k/i_amigasound.o
LINKOBJ   = amiga_m68k/d_event.o amiga_m68k/d_iwad.o amiga_m68k/i_endoom.o amiga_m68k/i_joystick.o amiga_m68k/i_main.o amiga_m68k/i_scale.o amiga_m68k/i_sound.o amiga_m68k/i_system.o amiga_m68k/i_timer.o amiga_m68k/i_video.o amiga_m68k/icon.o amiga_m68k/m_argv.o amiga_m68k/m_bbox.o amiga_m68k/m_cheat.o amiga_m68k/m_config.o amiga_m68k/m_controls.o amiga_m68k/m_fixed.o amiga_m68k/m_misc.o amiga_m68k/md5.o amiga_m68k/memio.o amiga_m68k/mus2mid.o amiga_m68k/net_common.o amiga_m68k/net_io.o amiga_m68k/net_loop.o amiga_m68k/net_packet.o amiga_m68k/net_query.o amiga_m68k/net_structrw.o amiga_m68k/tables.o amiga_m68k/v_video.o amiga_m68k/w_checksum.o amiga_m68k/w_file.o amiga_m68k/w_file_stdc.o amiga_m68k/w_main.o amiga_m68k/w_merge.o amiga_m68k/w_wad.o amiga_m68k/z_zone.o amiga_m68k/d_main.o amiga_m68k/am_map.o amiga_m68k/d_items.o amiga_m68k/d_net.o amiga_m68k/doomdef.o amiga_m68k/doomstat.o amiga_m68k/dstrings.o amiga_m68k/f_finale.o amiga_m68k/f_wipe.o amiga_m68k/g_game.o amiga_m68k/hu_lib.o amiga_m68k/hu_stuff.o amiga_m68k/info.o amiga_m68k/m_menu.o amiga_m68k/m_random.o amiga_m68k/m_saves.o amiga_m68k/p_ceilng.o amiga_m68k/p_dialog.o amiga_m68k/p_doors.o amiga_m68k/p_enemy.o amiga_m68k/p_floor.o amiga_m68k/p_inter.o amiga_m68k/p_lights.o amiga_m68k/p_map.o amiga_m68k/p_maputl.o amiga_m68k/p_mobj.o amiga_m68k/p_plats.o amiga_m68k/p_pspr.o amiga_m68k/p_saveg.o amiga_m68k/p_setup.o amiga_m68k/p_sight.o amiga_m68k/p_spec.o amiga_m68k/p_switch.o amiga_m68k/p_telept.o amiga_m68k/p_tick.o amiga_m68k/p_user.o amiga_m68k/r_bsp.o amiga_m68k/r_data.o amiga_m68k/r_draw.o amiga_m68k/r_main.o amiga_m68k/r_plane.o amiga_m68k/r_segs.o amiga_m68k/r_sky.o amiga_m68k/r_things.o amiga_m68k/s_sound.o amiga_m68k/sounds.o amiga_m68k/st_lib.o amiga_m68k/st_stuff.o amiga_m68k/wi_stuff.o amiga_m68k/net_sdl.o amiga_m68k/d_mode.o amiga_m68k/midifile.o amiga_m68k/i_amigasound.o
LIBS      = c2p/c2p1x1_8_c5_bm_040.o c2p/m_fixed.o -lauto
LIBDIR    = -L"OS:Development/m68k/Cubic IDE/ide/devkits/compilers/gcc/classic/2.95.3/lib" -L"OS:Development/m68k/Cubic IDE/ide/devkits/compilers/gcc/classic/2.95.3/lib/libb/libnix" -s -noixemul
INCS      = -Istrife -I./ -I"OS:Development/m68k/Cubic IDE/ide/devkits/sdk/classic/ndk_39/include/include_h"
CXXINCS   = -Isrc
BIN       = Release/Strife.exe
DEFINES   =  -DHAVE_CONFIG_H -DAMIGA
CXXFLAGS  = $(CXXINCS) $(DEFINES) -m68060 -s -w -noixemul -fexpensive-optimizations -O3
CFLAGS    = $(INCS) $(DEFINES) -m68060 -s -w -noixemul -fexpensive-optimizations -O3
GPROF     = gprof
RM        = delete
LINK      = g++

.PHONY: all all-before all-after clean clean-custom
all: all-before $(BIN) all-after

clean: clean-custom
	$(RM) $(OBJ) $(BIN)

$(BIN): $(OBJ)
	$(LINK) $(OBJ) -o "Release/Strife.exe" $(LIBDIR) $(LIBS)

amiga_m68k/d_event.o: $(GLOBALDEPS) d_event.c
	$(CC) -c d_event.c -o amiga_m68k/d_event.o $(CFLAGS) 

amiga_m68k/d_iwad.o: $(GLOBALDEPS) d_iwad.c
	$(CC) -c d_iwad.c -o amiga_m68k/d_iwad.o $(CFLAGS)  

amiga_m68k/i_endoom.o: $(GLOBALDEPS) i_endoom.c
	$(CC) -c i_endoom.c -o amiga_m68k/i_endoom.o $(CFLAGS)

amiga_m68k/i_joystick.o: $(GLOBALDEPS) i_joystick.c
	$(CC) -c i_joystick.c -o amiga_m68k/i_joystick.o $(CFLAGS)

amiga_m68k/i_main.o: $(GLOBALDEPS) i_main.c
	$(CC) -c i_main.c -o amiga_m68k/i_main.o $(CFLAGS)

amiga_m68k/i_scale.o: $(GLOBALDEPS) i_scale.c
	$(CC) -c i_scale.c -o amiga_m68k/i_scale.o $(CFLAGS)

amiga_m68k/i_sound.o: $(GLOBALDEPS) i_sound.c
	$(CC) -c i_sound.c -o amiga_m68k/i_sound.o $(CFLAGS)

amiga_m68k/i_system.o: $(GLOBALDEPS) i_system.c
	$(CC) -c i_system.c -o amiga_m68k/i_system.o $(CFLAGS)

amiga_m68k/i_timer.o: $(GLOBALDEPS) i_timer.c
	$(CC) -c i_timer.c -o amiga_m68k/i_timer.o $(CFLAGS)

amiga_m68k/i_video.o: $(GLOBALDEPS) i_video.c
	$(CC) -c i_video.c -o amiga_m68k/i_video.o $(CFLAGS) 

amiga_m68k/icon.o: $(GLOBALDEPS) icon.c
	$(CC) -c icon.c -o amiga_m68k/icon.o $(CFLAGS)

amiga_m68k/m_argv.o: $(GLOBALDEPS) m_argv.c
	$(CC) -c m_argv.c -o amiga_m68k/m_argv.o $(CFLAGS)

amiga_m68k/m_bbox.o: $(GLOBALDEPS) m_bbox.c
	$(CC) -c m_bbox.c -o amiga_m68k/m_bbox.o $(CFLAGS)

amiga_m68k/m_cheat.o: $(GLOBALDEPS) m_cheat.c
	$(CC) -c m_cheat.c -o amiga_m68k/m_cheat.o $(CFLAGS)

amiga_m68k/m_config.o: $(GLOBALDEPS) m_config.c
	$(CC) -c m_config.c -o amiga_m68k/m_config.o $(CFLAGS)

amiga_m68k/m_controls.o: $(GLOBALDEPS) m_controls.c
	$(CC) -c m_controls.c -o amiga_m68k/m_controls.o $(CFLAGS)

amiga_m68k/m_fixed.o: $(GLOBALDEPS) m_fixed.c
	$(CC) -c m_fixed.c -o amiga_m68k/m_fixed.o $(CFLAGS)

amiga_m68k/m_misc.o: $(GLOBALDEPS) m_misc.c
	$(CC) -c m_misc.c -o amiga_m68k/m_misc.o $(CFLAGS)

amiga_m68k/md5.o: $(GLOBALDEPS) md5.c
	$(CC) -c md5.c -o amiga_m68k/md5.o $(CFLAGS)

amiga_m68k/memio.o: $(GLOBALDEPS) memio.c
	$(CC) -c memio.c -o amiga_m68k/memio.o $(CFLAGS)

amiga_m68k/mus2mid.o: $(GLOBALDEPS) mus2mid.c
	$(CC) -c mus2mid.c -o amiga_m68k/mus2mid.o $(CFLAGS)

amiga_m68k/net_common.o: $(GLOBALDEPS) net_common.c
	$(CC) -c net_common.c -o amiga_m68k/net_common.o $(CFLAGS)

amiga_m68k/net_io.o: $(GLOBALDEPS) net_io.c
	$(CC) -c net_io.c -o amiga_m68k/net_io.o $(CFLAGS)

amiga_m68k/net_loop.o: $(GLOBALDEPS) net_loop.c
	$(CC) -c net_loop.c -o amiga_m68k/net_loop.o $(CFLAGS)

amiga_m68k/net_packet.o: $(GLOBALDEPS) net_packet.c
	$(CC) -c net_packet.c -o amiga_m68k/net_packet.o $(CFLAGS)

amiga_m68k/net_query.o: $(GLOBALDEPS) net_query.c
	$(CC) -c net_query.c -o amiga_m68k/net_query.o $(CFLAGS)

amiga_m68k/net_structrw.o: $(GLOBALDEPS) net_structrw.c
	$(CC) -c net_structrw.c -o amiga_m68k/net_structrw.o $(CFLAGS)

amiga_m68k/tables.o: $(GLOBALDEPS) tables.c
	$(CC) -c tables.c -o amiga_m68k/tables.o $(CFLAGS)  

amiga_m68k/v_video.o: $(GLOBALDEPS) v_video.c
	$(CC) -c v_video.c -o amiga_m68k/v_video.o $(CFLAGS) 

amiga_m68k/w_checksum.o: $(GLOBALDEPS) w_checksum.c
	$(CC) -c w_checksum.c -o amiga_m68k/w_checksum.o $(CFLAGS) 

amiga_m68k/w_file.o: $(GLOBALDEPS) w_file.c
	$(CC) -c w_file.c -o amiga_m68k/w_file.o $(CFLAGS) 

amiga_m68k/w_file_stdc.o: $(GLOBALDEPS) w_file_stdc.c
	$(CC) -c w_file_stdc.c -o amiga_m68k/w_file_stdc.o $(CFLAGS) 

amiga_m68k/w_main.o: $(GLOBALDEPS) w_main.c
	$(CC) -c w_main.c -o amiga_m68k/w_main.o $(CFLAGS) 

amiga_m68k/w_merge.o: $(GLOBALDEPS) w_merge.c
	$(CC) -c w_merge.c -o amiga_m68k/w_merge.o $(CFLAGS)  

amiga_m68k/w_wad.o: $(GLOBALDEPS) w_wad.c
	$(CC) -c w_wad.c -o amiga_m68k/w_wad.o $(CFLAGS) 

amiga_m68k/z_zone.o: $(GLOBALDEPS) z_zone.c
	$(CC) -c z_zone.c -o amiga_m68k/z_zone.o $(CFLAGS) 

amiga_m68k/d_main.o: $(GLOBALDEPS) strife/d_main.c
	$(CC) -c strife/d_main.c -o amiga_m68k/d_main.o $(CFLAGS) 

amiga_m68k/am_map.o: $(GLOBALDEPS) strife/am_map.c
	$(CC) -c strife/am_map.c -o amiga_m68k/am_map.o $(CFLAGS) 

amiga_m68k/d_items.o: $(GLOBALDEPS) strife/d_items.c
	$(CC) -c strife/d_items.c -o amiga_m68k/d_items.o $(CFLAGS)  

amiga_m68k/d_net.o: $(GLOBALDEPS) strife/d_net.c
	$(CC) -c strife/d_net.c -o amiga_m68k/d_net.o $(CFLAGS) 

amiga_m68k/doomdef.o: $(GLOBALDEPS) strife/doomdef.c
	$(CC) -c strife/doomdef.c -o amiga_m68k/doomdef.o $(CFLAGS)

amiga_m68k/doomstat.o: $(GLOBALDEPS) strife/doomstat.c
	$(CC) -c strife/doomstat.c -o amiga_m68k/doomstat.o $(CFLAGS)

amiga_m68k/dstrings.o: $(GLOBALDEPS) strife/dstrings.c
	$(CC) -c strife/dstrings.c -o amiga_m68k/dstrings.o $(CFLAGS)

amiga_m68k/f_finale.o: $(GLOBALDEPS) strife/f_finale.c
	$(CC) -c strife/f_finale.c -o amiga_m68k/f_finale.o $(CFLAGS) 

amiga_m68k/f_wipe.o: $(GLOBALDEPS) strife/f_wipe.c
	$(CC) -c strife/f_wipe.c -o amiga_m68k/f_wipe.o $(CFLAGS) 

amiga_m68k/g_game.o: $(GLOBALDEPS) strife/g_game.c
	$(CC) -c strife/g_game.c -o amiga_m68k/g_game.o $(CFLAGS) 

amiga_m68k/hu_lib.o: $(GLOBALDEPS) strife/hu_lib.c
	$(CC) -c strife/hu_lib.c -o amiga_m68k/hu_lib.o $(CFLAGS)

amiga_m68k/hu_stuff.o: $(GLOBALDEPS) strife/hu_stuff.c
	$(CC) -c strife/hu_stuff.c -o amiga_m68k/hu_stuff.o $(CFLAGS)

amiga_m68k/info.o: $(GLOBALDEPS) strife/info.c
	$(CC) -c strife/info.c -o amiga_m68k/info.o $(CFLAGS)

amiga_m68k/m_menu.o: $(GLOBALDEPS) strife/m_menu.c
	$(CC) -c strife/m_menu.c -o amiga_m68k/m_menu.o $(CFLAGS) 

amiga_m68k/m_random.o: $(GLOBALDEPS) strife/m_random.c
	$(CC) -c strife/m_random.c -o amiga_m68k/m_random.o $(CFLAGS)

amiga_m68k/m_saves.o: $(GLOBALDEPS) strife/m_saves.c
	$(CC) -c strife/m_saves.c -o amiga_m68k/m_saves.o $(CFLAGS)

amiga_m68k/p_ceilng.o: $(GLOBALDEPS) strife/p_ceilng.c
	$(CC) -c strife/p_ceilng.c -o amiga_m68k/p_ceilng.o $(CFLAGS)  

amiga_m68k/p_dialog.o: $(GLOBALDEPS) strife/p_dialog.c
	$(CC) -c strife/p_dialog.c -o amiga_m68k/p_dialog.o $(CFLAGS) 

amiga_m68k/p_doors.o: $(GLOBALDEPS) strife/p_doors.c
	$(CC) -c strife/p_doors.c -o amiga_m68k/p_doors.o $(CFLAGS) 

amiga_m68k/p_enemy.o: $(GLOBALDEPS) strife/p_enemy.c
	$(CC) -c strife/p_enemy.c -o amiga_m68k/p_enemy.o $(CFLAGS) 

amiga_m68k/p_floor.o: $(GLOBALDEPS) strife/p_floor.c
	$(CC) -c strife/p_floor.c -o amiga_m68k/p_floor.o $(CFLAGS) 

amiga_m68k/p_inter.o: $(GLOBALDEPS) strife/p_inter.c
	$(CC) -c strife/p_inter.c -o amiga_m68k/p_inter.o $(CFLAGS) 

amiga_m68k/p_lights.o: $(GLOBALDEPS) strife/p_lights.c
	$(CC) -c strife/p_lights.c -o amiga_m68k/p_lights.o $(CFLAGS) 

amiga_m68k/p_map.o: $(GLOBALDEPS) strife/p_map.c
	$(CC) -c strife/p_map.c -o amiga_m68k/p_map.o $(CFLAGS) 

amiga_m68k/p_maputl.o: $(GLOBALDEPS) strife/p_maputl.c
	$(CC) -c strife/p_maputl.c -o amiga_m68k/p_maputl.o $(CFLAGS) 

amiga_m68k/p_mobj.o: $(GLOBALDEPS) strife/p_mobj.c
	$(CC) -c strife/p_mobj.c -o amiga_m68k/p_mobj.o $(CFLAGS) 

amiga_m68k/p_plats.o: $(GLOBALDEPS) strife/p_plats.c
	$(CC) -c strife/p_plats.c -o amiga_m68k/p_plats.o $(CFLAGS) 

amiga_m68k/p_pspr.o: $(GLOBALDEPS) strife/p_pspr.c
	$(CC) -c strife/p_pspr.c -o amiga_m68k/p_pspr.o $(CFLAGS) 

amiga_m68k/p_saveg.o: $(GLOBALDEPS) strife/p_saveg.c
	$(CC) -c strife/p_saveg.c -o amiga_m68k/p_saveg.o $(CFLAGS) 

amiga_m68k/p_setup.o: $(GLOBALDEPS) strife/p_setup.c
	$(CC) -c strife/p_setup.c -o amiga_m68k/p_setup.o $(CFLAGS) 

amiga_m68k/p_sight.o: $(GLOBALDEPS) strife/p_sight.c
	$(CC) -c strife/p_sight.c -o amiga_m68k/p_sight.o $(CFLAGS) 

amiga_m68k/p_spec.o: $(GLOBALDEPS) strife/p_spec.c
	$(CC) -c strife/p_spec.c -o amiga_m68k/p_spec.o $(CFLAGS) 

amiga_m68k/p_switch.o: $(GLOBALDEPS) strife/p_switch.c
	$(CC) -c strife/p_switch.c -o amiga_m68k/p_switch.o $(CFLAGS) 

amiga_m68k/p_telept.o: $(GLOBALDEPS) strife/p_telept.c
	$(CC) -c strife/p_telept.c -o amiga_m68k/p_telept.o $(CFLAGS) 

amiga_m68k/p_tick.o: $(GLOBALDEPS) strife/p_tick.c
	$(CC) -c strife/p_tick.c -o amiga_m68k/p_tick.o $(CFLAGS) 

amiga_m68k/p_user.o: $(GLOBALDEPS) strife/p_user.c
	$(CC) -c strife/p_user.c -o amiga_m68k/p_user.o $(CFLAGS)  

amiga_m68k/r_bsp.o: $(GLOBALDEPS) strife/r_bsp.c
	$(CC) -c strife/r_bsp.c -o amiga_m68k/r_bsp.o $(CFLAGS) 

amiga_m68k/r_data.o: $(GLOBALDEPS) strife/r_data.c
	$(CC) -c strife/r_data.c -o amiga_m68k/r_data.o $(CFLAGS) 

amiga_m68k/r_draw.o: $(GLOBALDEPS) strife/r_draw.c
	$(CC) -c strife/r_draw.c -o amiga_m68k/r_draw.o $(CFLAGS) 

amiga_m68k/r_main.o: $(GLOBALDEPS) strife/r_main.c
	$(CC) -c strife/r_main.c -o amiga_m68k/r_main.o $(CFLAGS) 

amiga_m68k/r_plane.o: $(GLOBALDEPS) strife/r_plane.c
	$(CC) -c strife/r_plane.c -o amiga_m68k/r_plane.o $(CFLAGS)  

amiga_m68k/r_segs.o: $(GLOBALDEPS) strife/r_segs.c
	$(CC) -c strife/r_segs.c -o amiga_m68k/r_segs.o $(CFLAGS) 

amiga_m68k/r_sky.o: $(GLOBALDEPS) strife/r_sky.c
	$(CC) -c strife/r_sky.c -o amiga_m68k/r_sky.o $(CFLAGS) 

amiga_m68k/r_things.o: $(GLOBALDEPS) strife/r_things.c
	$(CC) -c strife/r_things.c -o amiga_m68k/r_things.o $(CFLAGS)  

amiga_m68k/s_sound.o: $(GLOBALDEPS) strife/s_sound.c
	$(CC) -c strife/s_sound.c -o amiga_m68k/s_sound.o $(CFLAGS)  

amiga_m68k/sounds.o: $(GLOBALDEPS) strife/sounds.c
	$(CC) -c strife/sounds.c -o amiga_m68k/sounds.o $(CFLAGS) 

amiga_m68k/st_lib.o: $(GLOBALDEPS) strife/st_lib.c
	$(CC) -c strife/st_lib.c -o amiga_m68k/st_lib.o $(CFLAGS)

amiga_m68k/st_stuff.o: $(GLOBALDEPS) strife/st_stuff.c
	$(CC) -c strife/st_stuff.c -o amiga_m68k/st_stuff.o $(CFLAGS)

amiga_m68k/wi_stuff.o: $(GLOBALDEPS) strife/wi_stuff.c
	$(CC) -c strife/wi_stuff.c -o amiga_m68k/wi_stuff.o $(CFLAGS)

amiga_m68k/net_sdl.o: $(GLOBALDEPS) net_sdl.c
	$(CC) -c net_sdl.c -o amiga_m68k/net_sdl.o $(CFLAGS)

amiga_m68k/d_mode.o: $(GLOBALDEPS) d_mode.c
	$(CC) -c d_mode.c -o amiga_m68k/d_mode.o $(CFLAGS)  

amiga_m68k/midifile.o: $(GLOBALDEPS) midifile.c
	$(CC) -c midifile.c -o amiga_m68k/midifile.o $(CFLAGS)

amiga_m68k/i_amigasound.o: $(GLOBALDEPS) i_amigasound.c
	$(CC) -c i_amigasound.c -o amiga_m68k/i_amigasound.o $(CFLAGS)
