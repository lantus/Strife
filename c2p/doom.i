;/* doom.i */

	include exec/types.i

MAXNETNODES = 8
BACKUPTICS = 12
DOOMCOM_ID = $12345678

CMD_SEND	= 1
CMD_GET	= 2

 STRUCTURE ticcmd,0
  BYTE	tc_forwardmove
  BYTE	tc_sidemove
  WORD	tc_angleturn
  WORD	tc_consistancy
  BYTE	tc_chatchar
  BYTE	tc_buttons
  LABEL	tc_SIZEOF
  ;// 8

 STRUCTURE doomdata,0
  LONG	dd_checksum
  BYTE	dd_retransmitfrom
  BYTE	dd_starttic
  BYTE	dd_player
  BYTE	dd_numtics
  STRUCT dd_cmds,tc_SIZEOF*BACKUPTICS
  LABEL	dd_SIZEOF
  ;// 104
 
 STRUCTURE doomcom,0
  LONG	dc_id
  WORD	dc_intnum
  WORD	dc_command
  WORD	dc_remotenode
  WORD	dc_datalength
  WORD	dc_numnodes
  WORD	dc_ticdup
  WORD	dc_extratics
  WORD	dc_deathmatch
  WORD	dc_savegame
  WORD	dc_episode
  WORD	dc_map
  WORD	dc_skill
  WORD	dc_consoleplayer
  WORD	dc_numplayers
  WORD	dc_angleoffset
  WORD	dc_drone
  STRUCT dc_data,dd_SIZEOF
  LABEL	dc_SIZEOF


