	
	include exec/types.i

SCREENWIDTH = 320
MAXWIDTH = 640
MAXHEIGHT = 512

MAXVISPLANES = 200
MAXVISSPRITES = 128
MAXDRAWSEGS = 256
ANGLETOSKYSHIFT = 22
ANGLETOFINESHIFT = 19
LIGHTSEGSHIFT = 4
LIGHTSCALESHIFT = 12
LIGHTLEVELS = 16
MAXLIGHTSCALE = 48
MAXLIGHTZ = 128
HEIGHTBITS = 12
HEIGHTUNIT = 1<<HEIGHTBITS
FRACBITS = 16
FRACUNIT = 1<<FRACBITS
MAXSHORT = $7FFF
MINZ = FRACUNIT*4
SLOPERANGE = 2048

NF_SUBSECTOR = $8000
NFB_SUBSECTOR = 15

MF_SHADOW = $40000

ML_DONTPEGTOP = 8
ML_DONTPEGBOTTOM = 16
ML_DONTDRAW  = 128
MLB_DONTPEGTOP = 3
MLB_DONTPEGBOTTOM = 4
MLB_DONTDRAW = 7

SIL_BOTTOM = 1
SIL_TOP = 2
SIL_BOTH = 3

MF_TRANSLATION = $c000000
MF_TRANSSHIFT = 26

ML_MAPPED = 256

ANG90 = $40000000	
ANG270 = $C0000000
ANG180 = $80000000

FINEANGLES = 8192

BOXTOP = 0
BOXBOTTOM = 1
BOXLEFT = 2
BOXRIGHT = 3

FF_FRAMEMASK = $7FFF
FF_FULLBRIGHT = $8000

PU_STATIC = 1
PU_CACHE = 101
NCMD_CHECKSUM	= $0fffffff

 STRUCTURE visplane,0
 	LONG	vp_height
 	LONG	vp_picnum
 	LONG	vp_lightlevel
 	LONG	vp_minx
 	LONG	vp_maxx
 	WORD	vp_pad1
 	STRUCT vp_top,MAXWIDTH*2
 	WORD	vp_pad2
 	WORD	vp_pad3
 	STRUCT vp_bottom,MAXWIDTH*2
 	WORD	vp_pad4
 	LABEL vp_SIZEOF

 STRUCTURE node,0
   LONG	nd_x
   LONG	nd_y
   LONG	nd_dx
   LONG	nd_dy
   STRUCT nd_bbox,2*4*4
   STRUCT nd_children,2*2
   LABEL	nd_SIZEOF
	;// 52 Bytes

 STRUCTURE thinker,0
   APTR	th_prev
   APTR	th_next
   APTR	th_function
   LABEL	th_SIZEOF

 STRUCTURE degenmobj,0
   STRUCT dm_thinker,th_SIZEOF
   LONG	dm_x
   LONG	dm_y
   LONG	dm_z
   LABEL	dm_SIZEOF

 STRUCTURE sector,0
   LONG	sc_floorheight
   LONG	sc_ceilingheight
   WORD	sc_floorpic
   WORD	sc_ceilingpic
   WORD	sc_lightlevel
   WORD	sc_special
   WORD	sc_tag
	LONG	sc_soundtraversed
	APTR	sc_soundtarget
	STRUCT sc_blockbox,4*4
	STRUCT sc_soundorg,dm_SIZEOF
	LONG	sc_validcount
	APTR	sc_thinglist
	APTR	sc_specialdata
	LONG	sc_linecount
   APTR	sc_lines
	LABEL	sc_SIZEOF

 STRUCTURE seg,0
 	APTR	sg_v1
 	APTR	sg_v2
   LONG	sg_offset
   LONG	sg_angle
	APTR	sg_sidedef
	APTR	sg_linedef
	APTR	sg_frontsector
	APTR	sg_backsector
	LABEL	sg_SIZEOF
	;//32 Bytes

 STRUCTURE subsector,0
 	APTR	ss_sector
 	WORD	ss_numlines
 	WORD	ss_firstline
 	LABEL	ss_SIZEOF
 	;//8 Bytes
 	
 STRUCTURE cliprange,0
 	LONG	cr_first
 	LONG	cr_last
 	LABEL	cr_SIZEOF

 STRUCTURE side,0
   LONG	sd_textureoffset
   LONG	sd_rowoffset
	WORD	sd_toptexture
	WORD	sd_bottomtexture
	WORD	sd_midtexture
	APTR	sd_sector
	LABEL	sd_SIZEOF

 STRUCTURE drawseg,0
 	APTR	ds_curline
 	LONG	ds_x1
 	LONG	ds_x2
 	LONG	ds_scale1
 	LONG	ds_scale2
 	LONG	ds_scalestep
	LONG	ds_silhouette
	LONG	ds_bsilheight
	LONG	ds_tsilheight
 	APTR	ds_sprtopclip
 	APTR	ds_sprbottomclip
 	APTR	ds_maskedtexturecol   
	LABEL ds_SIZEOF
	;// 48 Bytes

 STRUCTURE line,0
 	APTR	ln_v1
 	APTR	ln_v2
	LONG	ln_dx
	LONG	ln_dy
	WORD	ln_flags
	WORD	ln_special
	WORD	ln_tag
	STRUCT ln_sidenum,2*2
	STRUCT ln_bbox,4*4
	LONG	ln_slopetype
	APTR	ln_frontsector
	APTR	ln_backsector
	LONG	ln_validcount
	APTR	ln_specialdata
	LABEL	ln_SIZEOF

 STRUCTURE post,0
 	BYTE	po_topdelta
 	BYTE	po_length
 	LABEL	po_SIZEOF
 	
 STRUCTURE column,0
 	BYTE	cl_topdelta
 	BYTE	cl_length
 	LABEL	cl_SIZEOF
 	
 STRUCTURE vissprite,0
	APTR	vs_prev
	APTR	vs_next
 	LONG	vs_x1
 	LONG	vs_x2
	LONG	vs_gx
	LONG	vs_gy
	LONG	vs_gz
	LONG	vs_gzt
	LONG	vs_startfrac
	LONG	vs_scale
 	LONG	vs_xiscale
 	LONG	vs_texturemid
 	LONG	vs_patch
	LONG	vs_colormap
	LONG	vs_mobjflags
	LABEL	vs_SIZEOF
	;// 60 Bytes

 STRUCTURE patch,0
 	WORD	pa_width
 	WORD	pa_height
 	WORD	pa_leftoffset
 	WORD	pa_topoffset
 	STRUCT pa_columnofs,8*4
 	LABEL	pa_SIZEOF


 STRUCTURE spriteframe,0
 	LONG	sf_rotate
 	STRUCT sf_lump,8*2
 	STRUCT sf_flip,8
 	LABEL sf_SIZEOF
	;// 28 Bytes
	
 STRUCTURE spritedef,0
 	LONG	sp_numframes
 	APTR	sp_spriteframes
 	LABEL	sp_SIZEOF
	;// 8 Bytes

 STRUCTURE mapthing,0
	WORD	mt_x
	WORD	mt_y
	WORD	mt_angle
	WORD	mt_type
	WORD	mt_options
	LABEL	mt_SIZEOF
	
 STRUCTURE mobj,0
 	STRUCT mo_thinker,th_SIZEOF
 	LONG	mo_x
 	LONG	mo_y
 	LONG	mo_z
	APTR	mo_snext
	APTR	mo_sprev
	LONG	mo_angle
	LONG	mo_sprite
	LONG	mo_frame
	APTR	mo_bnext
	APTR	mo_bprev
	APTR	mo_subsector
	LONG	mo_floorz
	LONG	mo_ceilingz
   LONG	mo_radius
   LONG	mo_height
	LONG	mo_momx
	LONG	mo_momy
	LONG	mo_momz   
	LONG	mo_validcount
	LONG	mo_type
	APTR	mo_info
	LONG	mo_tics
	APTR	mo_state
	LONG	mo_flags
	LONG	mo_health
	LONG	mo_movedir
	LONG	mo_movecount
	APTR	mo_target    
	LONG	mo_reactiontime
	LONG	mo_threshold
	LONG	mo_player
	LONG	mo_lastlook
	STRUCT mo_spawnpoint,mt_SIZEOF
	APTR	mo_tracer
	LABEL	mo_SIZEOF


