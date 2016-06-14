CC=gcc

HOST_PLATFORM:=$(shell uname | tr [:upper:] [:lower:] | sed 's/[_-].*//; s:/:_:g; s/32//; s/mingw/mingw32/; s/msys/mingw32/')
HOST_ARCH:=$(shell uname -m | tr [:upper:] [:lower:] | sed 's/i.86/x86/; s/\-pc//')

# fixup host os
ifeq ($(HOST_PLATFORM),sunos)
  # Solaris uname and GNU uname differ
  HOST_ARCH=$(shell uname -p | sed -e s/i.86/x86/)
endif
ifeq ($(HOST_PLATFORM),darwin)
  # Apple does some things a little differently...
  HOST_ARCH=$(shell uname -p | sed -e s/i.86/x86/)
endif

ifeq ($(HOST_PLATFORM),cygwin)
  PLATFORM=mingw32
endif

# target os
ifndef PLATFORM
PLATFORM=$(HOST_PLATFORM)
endif
export PLATFORM

# fixup target os
ifeq ($(PLATFORM),mingw32)
  MINGW=1
endif
ifeq ($(PLATFORM),mingw64)
  MINGW=1
endif

# fixup host arch
ifeq ($(HOST_ARCH),i86pc)
  HOST_ARCH=x86
endif

ifeq ($(HOST_ARCH),amd64)
  HOST_ARCH=x86_64
endif
ifeq ($(HOST_ARCH),x64)
  HOST_ARCH=x86_64
endif

ifeq ($(HOST_ARCH),powerpc)
  HOST_ARCH=ppc
endif
ifeq ($(HOST_ARCH),powerpc64)
  HOST_ARCH=ppc64
endif

ifeq ($(HOST_ARCH),axp)
  HOST_ARCH=alpha
endif

# target arch
ifndef ARCH
ARCH=$(HOST_ARCH)
endif
export ARCH

ifneq ($(PLATFORM),$(HOST_PLATFORM))
  CROSS_COMPILING=1
else
  CROSS_COMPILING=0

  ifneq ($(ARCH),$(HOST_ARCH))
    CROSS_COMPILING=1
  endif
endif
export CROSS_COMPILING

CFLAGS=\
	-Dstricmp=strcasecmp -DCom_Memcpy=memcpy -DCom_Memset=memset \
	-DMAC_STATIC= -DQDECL= -DBSPC -D_FORTIFY_SOURCE=2 \
	-I. -Ideps -Wall -Wno-unknown-pragmas -fno-diagnostics-show-caret -fno-diagnostics-show-option

RELEASE_CFLAGS=-O3 -ffast-math
DEBUG_CFLAGS=-g -O0 -ffast-math
LDFLAGS=-lm

DO_CC=$(CC) $(CFLAGS) -o $@ -c $<

#############################################################################
# SETUP AND BUILD BSPC
#############################################################################

.c.o:
	$(DO_CC)

GAME_OBJS = \
	_files.o\
	aas_areamerging.o\
	aas_cfg.o\
	aas_create.o\
	aas_edgemelting.o\
	aas_facemerging.o\
	aas_file.o\
	aas_gsubdiv.o\
	aas_map.o\
	aas_prunenodes.o\
	aas_store.o\
	be_aas_bspc.o\
	deps/botlib/be_aas_bspq3.o\
	deps/botlib/be_aas_cluster.o\
	deps/botlib/be_aas_move.o\
	deps/botlib/be_aas_optimize.o\
	deps/botlib/be_aas_reach.o\
	deps/botlib/be_aas_sample.o\
	brushbsp.o\
	bspc.o\
	deps/qcommon/cm_load.o\
	deps/qcommon/cm_patch.o\
	deps/qcommon/cm_test.o\
	deps/qcommon/cm_trace.o\
	csg.o\
	glfile.o\
	l_bsp_ent.o\
	l_bsp_hl.o\
	l_bsp_q1.o\
	l_bsp_q2.o\
	l_bsp_q3.o\
	l_bsp_sin.o\
	l_cmd.o\
	deps/botlib/l_libvar.o\
	l_log.o\
	l_math.o\
	l_mem.o\
	l_poly.o\
	deps/botlib/l_precomp.o\
	l_qfiles.o\
	deps/botlib/l_script.o\
	deps/botlib/l_struct.o\
	l_threads.o\
	l_utils.o\
	leakfile.o\
	map.o\
	map_hl.o\
	map_q1.o\
	map_q2.o\
	map_q3.o\
	map_sin.o\
	deps/qcommon/md4.o\
	nodraw.o\
	portals.o\
	textures.o\
	tree.o\
	deps/qcommon/unzip.o

        #tetrahedron.o


#############################################################################
# Windows
#############################################################################

ifdef MINGW
  E=.exe
  CFLAGS += -DWIN32 -D_WIN32
  ifeq ($(CROSS_COMPILING),1)
    # If CC is already set to something generic, we probably want to use
    # something more specific
    ifneq ($(findstring $(strip $(CC)),cc gcc),)
      CC=
    endif

    # We need to figure out the correct gcc and windres
    ifeq ($(ARCH),x86_64)
      MINGW_PREFIXES=amd64-mingw32msvc x86_64-w64-mingw32
    endif
    ifeq ($(ARCH),x86)
      MINGW_PREFIXES=i586-mingw32msvc i686-w64-mingw32 i686-pc-mingw32
    endif

    ifndef CC
      CC=$(firstword $(strip $(foreach MINGW_PREFIX, $(MINGW_PREFIXES), \
         $(call bin_path, $(MINGW_PREFIX)-gcc))))
    endif
  else
    # Some MinGW installations define CC to cc, but don't actually provide cc,
    # so check that CC points to a real binary and use gcc if it doesn't
    ifeq ($(call bin_path, $(CC)),)
      CC=gcc
    endif
  endif

#############################################################################
# Unix
#############################################################################

else    # ifeq MINGW

  CFLAGS += -DLINUX
  LDFLAGS += -lpthread

endif # ifeq MINGW


EXEC = bspc$E

all: release

debug: CFLAGS += $(DEBUG_CFLAGS)
debug: $(EXEC)_g

release: CFLAGS += $(RELEASE_CFLAGS)
release: $(EXEC)

$(EXEC): $(GAME_OBJS)
	$(CC) -o $@ $(GAME_OBJS) $(LDFLAGS)
	strip $@

$(EXEC)_g: $(GAME_OBJS)
	$(CC) -o $@ $(GAME_OBJS) $(LDFLAGS)

#############################################################################
# MISC
#############################################################################
.PHONY: clean depend

clean:
	-rm -f $(GAME_OBJS) $(EXEC) $(EXEC)_g

depend:
	$(CC) $(CFLAGS) -MM $(GAME_OBJS:.o=.c) > .deps

include .deps
