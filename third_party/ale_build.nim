#  Agent Smith
#  Copyright (c) 2018-Present, Mamy André-Ratsimbazafy
#
#  This program is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public License version 2
#  as published by the Free Software Foundation.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.

# ############################################################
#
#                      Build system
#
# ############################################################

# This file replaces CMake to build the Arcade Learning Environment DLL
# We use a separate DLL because building the library is really slow (a minute or so)
# Also CMake is much slower than Nim even for compiling + linking
# and a mess to deal with.

import strutils, ospaths
from os import DirSep, walkFiles

const cppSrcPath = currentSourcePath.rsplit(DirSep, 1)[0] &
  "/arcade_learning_environment/src/"

# ############################################################
#
#                      External links
#
# ############################################################

# {.warning: "Execution of a potentially unsafe command \"sdl-config\" to configure SDL".}
# {.passC: "`sdl-config --cflags`".} # SDL 1.2
# {.passL: "`sdl-config --libs`".}   # SDL 1.2

{.passC: "-I\"third_party/sdl/include\"".}
{.passL: "-lSDL".} # {.passL: "-lSDLMain".}
{.passL: "-lz".}   # Zlib

# when defined(osx):
#   {.passL: "-Wl,-framework,Cocoa".}

# ############################################################
#
#                       Compilation
#
# ############################################################

{.passC: "-D__USE_SDL -DSOUND_SUPPORT -std=c++11 -D__STDC_CONSTANT_MACROS".}

{.passC: "-I\"" & cppSrcPath & "\"".}
{.passC: "-I\"" & cppSrcPath & "common\"".}
{.passC: "-I\"" & cppSrcPath & "controllers\"".}
{.passC: "-I\"" & cppSrcPath & "emucore\"".}
{.passC: "-I\"" & cppSrcPath & "emucore/m6502/src\"".}
{.passC: "-I\"" & cppSrcPath & "emucore/m6502/src/bspf/src\"".}
{.passC: "-I\"" & cppSrcPath & "environment\"".}
{.passC: "-I\"" & cppSrcPath & "games\"".}
{.passC: "-I\"" & cppSrcPath & "games/supported\"".}

# Need to use relative paths - https://github.com/nim-lang/Nim/issues/9370
const rel_path = "./arcade_learning_environment/src/"
{.compile: (rel_path & "common/*.cpp", "ale_common_$#.o") .}
{.compile: (rel_path & "common/*.cxx", "ale_common_$#.o") .} # But why?
{.compile: (rel_path & "controllers/*.cpp", "ale_controller_$#.o") .}
{.compile: (rel_path & "emucore/*.cxx", "ale_emucore_$#.o") .}
{.compile: (rel_path & "emucore/m6502/src/*.cxx", "ale_emucore_m6502_$#.o") .}
{.compile: (rel_path & "environment/*.cpp", "ale_environment_$#.o") .}
{.compile: (rel_path & "games/*.cpp", "ale_games_$#.o") .}
{.compile: (rel_path & "games/supported/*.cpp", "ale_games_supported_$#.o") .}
# {.compile: rel_path & "external/TinyMT/tinymt32.c" .} # seems unused
{.compile: rel_path & "ale_interface.cpp" .}

{.passC: "-I\"" & cppSrcPath & "os_dependent\"".}
when defined(windows):
  {.compile: (rel_path & "os_dependent/*Win32.cxx", "ale_os_$#Win32.o") .}
else:
  {.compile: (rel_path & "os_dependent/*UNIX.cxx", "ale_os_$#UNIX.o") .}
  {.compile: (rel_path & "os_dependent/FSNodePOSIX.cxx", "ale_os_FSNodePOSIX.o") .}
