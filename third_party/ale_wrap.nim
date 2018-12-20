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

import
  strutils, ospaths,
  ./std_cpp
from os import DirSep, walkFiles

# ############################################################
#
#                Linking against the shared lib
#
# ############################################################

const buildPath = currentSourcePath.rsplit(DirSep, 1)[0] &
  "/../build/"

# We assume that the dynamic library ends up in the same directory
# as the Nim executable
when defined(windows):
  const libName = "ale.dll"
elif defined(macosx):
  const libName = "libale.dylib"
else:
  const libName* = "libale.so"

{.link: buildPath & libName.}
  # Make sure to build the DLL directly in ./build/libale.ext"
  # It contains a path and while compilation will work
  # runtime search will fail

# ############################################################
#
#                          Includes
#
# ############################################################

const cppSrcPath = currentSourcePath.rsplit(DirSep, 1)[0] &
  "/arcade_learning_environment/src/"

{.passC: "-I\"" & cppSrcPath & "\"".}
{.passC: "-I\"" & cppSrcPath & "common\"".}
{.passC: "-I\"" & cppSrcPath & "controllers\"".}
{.passC: "-I\"" & cppSrcPath & "emucore\"".}
{.passC: "-I\"" & cppSrcPath & "emucore/m6502/src\"".}
{.passC: "-I\"" & cppSrcPath & "emucore/m6502/src/bspf/src\"".}
{.passC: "-I\"" & cppSrcPath & "environment\"".}
{.passC: "-I\"" & cppSrcPath & "games\"".}
{.passC: "-I\"" & cppSrcPath & "games/supported\"".}

# ############################################################
#
#                          ALE types
#
# ############################################################

type
  Action*{.importc,
          header: cppSrcPath & "common/Constants.h".} = enum
    PLAYER_A_NOOP = 0, PLAYER_A_FIRE = 1, PLAYER_A_UP = 2, PLAYER_A_RIGHT = 3,
    PLAYER_A_LEFT = 4, PLAYER_A_DOWN = 5, PLAYER_A_UPRIGHT = 6, PLAYER_A_UPLEFT = 7,
    PLAYER_A_DOWNRIGHT = 8, PLAYER_A_DOWNLEFT = 9, PLAYER_A_UPFIRE = 10,
    PLAYER_A_RIGHTFIRE = 11, PLAYER_A_LEFTFIRE = 12, PLAYER_A_DOWNFIRE = 13,
    PLAYER_A_UPRIGHTFIRE = 14, PLAYER_A_UPLEFTFIRE = 15, PLAYER_A_DOWNRIGHTFIRE = 16,
    PLAYER_A_DOWNLEFTFIRE = 17, PLAYER_B_NOOP = 18, PLAYER_B_FIRE = 19, PLAYER_B_UP = 20,
    PLAYER_B_RIGHT = 21, PLAYER_B_LEFT = 22, PLAYER_B_DOWN = 23, PLAYER_B_UPRIGHT = 24,
    PLAYER_B_UPLEFT = 25, PLAYER_B_DOWNRIGHT = 26, PLAYER_B_DOWNLEFT = 27,
    PLAYER_B_UPFIRE = 28, PLAYER_B_RIGHTFIRE = 29, PLAYER_B_LEFTFIRE = 30,
    PLAYER_B_DOWNFIRE = 31, PLAYER_B_UPRIGHTFIRE = 32, PLAYER_B_UPLEFTFIRE = 33,
    PLAYER_B_DOWNRIGHTFIRE = 34, PLAYER_B_DOWNLEFTFIRE = 35, RESET = 40,
    UNDEFINED = 41, RANDOM = 42, SAVE_STATE = 43, LOAD_STATE = 44, SYSTEM_RESET = 45,
    LAST_ACTION_INDEX = 50

  GameMode*{.importc:"game_mode_t",
            header: cppSrcPath & "common/Constants.h".} = uint32
  Difficulty*{.importc:"difficulty_t",
            header: cppSrcPath & "common/Constants.h".} = uint32
  Reward*{.importc:"reward_t",
            header: cppSrcPath & "common/Constants.h".} = int32
  ActionVect*{.importcpp,
            header: cppSrcPath & "common/Constants.h".} = CppVector[Action]
  ModeVect*{.importcpp,
            header: cppSrcPath & "common/Constants.h".} = CppVector[GameMode]
  DifficultyVect*{.importcpp,
            header: cppSrcPath & "common/Constants.h".} = CppVector[Difficulty]

  ALEInterface* {.importcpp:"ALEInterface",
                  header: cppSrcPath & "ale_interface.hpp",
                  byref.} = object
    theOSystem*{.importcpp.}: CppUniquePtr[OSystem]
    theSettings*{.importcpp.}: CppUniquePtr[Settings]
    romSettings*{.importcpp.}: CppUniquePtr[RomSettings]
    environment*{.importcpp.}: CppUniquePtr[StellaEnvironment]
    max_num_frames*: int32      ##  Maximum number of frames for each episode

  OSystem {.importcpp,
            header: cppSrcPath & "emucore/OSystem.hxx",
            byref.} = object

  Settings {.importcpp,
            header: cppSrcPath & "emucore/Settings.hxx",
            byref.} = object

  RomSettings {.importcpp,
                  header: cppSrcPath & "emucore/games/RomSettings.hxx",
                  byref.} = object

  StellaEnvironment {.importcpp,
                      header: cppSrcPath & "environment/stella_environment.hpp",
                      byref.} = object

  ALEScreen* {.importcpp,
              header: cppSrcPath & "environment/stella_environment.hpp",
              byref.} = object

  Pixel*{.importcpp: "pixel_t",
          header: cppSrcPath & "environment/ale_screen.hpp".} = byte

  ALERam* {.importcpp,
              header: cppSrcPath & "environment/ale_ram.hpp",
              byref.} = object

  ALEState* {.importcpp,
              header: cppSrcPath & "environment/ale_state.hpp",
              byref.} = object

  ScreenExporter*{.importcpp,
                    header: cppSrcPath & "common/ScreenExporter.hpp",
                    byref.} = object

# ############################################################
#
#                  Procedures and methods
#
# ############################################################

{.push callConv: cdecl.}

# ##############################
# src/environment/ale_ram.hpp

{.pragma: ale_ram, importcpp, header: cppSrcPath & "environment/ale_ram.hpp".}
func get*(this: ALERam; x: uint32): byte {.ale_ram.}
proc mut*(this: ALERam; x: uint32): ptr byte {.importcpp:"byte", header: cppSrcPath & "environment/ale_ram.hpp".}
func array*(this: ALERam): ptr byte {.ale_ram.}
func size*(this: ALERam): int {.ale_ram.}
func equals*(this: ALERam; rhs: ALERam): bool {.ale_ram.}

# ##############################
# src/environment/ale_screen.hpp

{.pragma: ale_screen, importcpp, header: cppSrcPath & "environment/ale_screen.hpp".}
func get*(this: ALEScreen; r: int32; c: int32): Pixel {.ale_screen.}
func mut*(this: ALEScreen; r: int32; c: int32): ptr Pixel {.importcpp:"pixel", header: cppSrcPath & "environment/ale_screen.hpp".}
func getRow*(this: ALEScreen; r: int32): ptr Pixel {.ale_screen.}
  ## Row-major ordering, increase ptr by 1 for next column
func getArray*(this: ALEScreen): ptr Pixel {.ale_screen.}
func height*(this: ALEScreen): int {.ale_screen.}
func width*(this: ALEScreen): int {.ale_screen.}
func arraySize*(this: ALEScreen): int {.ale_screen.}
func equals*(this: ALEScreen; rhs: ALEScreen): bool {.ale_screen.}

# ##############################
# src/common/ScreenExporter.hpp

{.pragma: screen_exporter, cdecl, importcpp, header: cppSrcPath & "common/ScreenExporter.hpp".}
proc save*(this: ScreenExporter; screen: ALEScreen; filename: CppString) {.screen_exporter.}
proc saveNext*(this: ScreenExporter; screen: ALEScreen) {.screen_exporter.}

# ##############################
# src/ale_interface.hpp

{.pragma: h_ale_interface, header: cppSrcPath & "ale_interface.hpp".}
proc newALEInterface*(): ptr ALEInterface {.h_ale_interface, importcpp:"new ALEInterface()", constructor.}
# proc destroyALEInterface*(this: ALEInterface)
proc newALEInterface*(display_screen: bool): ALEInterface {.h_ale_interface, importcpp:"new ALEInterface(#)", constructor.}
# proc getString*(this: ALEInterface; key: CppString): CppString
# proc getInt*(this: ALEInterface; key: CppString): int32
# proc getBool*(this: ALEInterface; key: CppString): bool
# proc getFloat*(this: ALEInterface; key: CppString): float32
# proc setString*(this: ALEInterface; key: CppString; value: CppString)
proc setInt*(this: ALEInterface; key: cstring; value: int32) {.h_ale_interface, importcpp:"#.setInt(@)".}
proc setBool*(this: ALEInterface; key: cstring; value: bool) {.h_ale_interface, importcpp:"#.setBool(@)".}
proc setFloat*(this: ALEInterface; key: cstring; value: float32) {.h_ale_interface, importcpp:"#.setFloat(@)".}
proc loadROM*(this: ALEInterface; rom_file: cstring) {.h_ale_interface, importcpp:"#.loadROM(#)".}
proc act*(this: ALEInterface; action: Action): Reward {.h_ale_interface, importcpp:"#.act(#)".}
proc game_over*(this: ALEInterface): bool {.h_ale_interface, importcpp:"#.game_over()".}
proc reset_game*(this: ALEInterface) {.h_ale_interface, importcpp:"#.reset_game()".}
# proc getAvailableModes*(this: ALEInterface): ModeVect
# proc setMode*(this: ALEInterface; m: GameMode)
# proc getAvailableDifficulties*(this: ALEInterface): DifficultyVect
# proc setDifficulty*(this: ALEInterface; m: Difficulty)
proc getLegalActionSet*(this: ALEInterface): ActionVect {.h_ale_interface, importcpp:"#.getLegalActionSet()".}
# proc getMinimalActionSet*(this: ALEInterface): ActionVect
# proc getFrameNumber*(this: ALEInterface): int32
# proc lives*(this: ALEInterface): int32
# proc getEpisodeFrameNumber*(this: ALEInterface): int32
# proc getScreen*(this: ALEInterface): ALEScreen
# proc getScreenGrayscale*(
#       this: ALEInterface;
#       grayscale_output_buffer: CppVector[byte])
# proc getScreenRGB*(
#         this: ALEInterface;
#         output_rgb_buffer: CppVector[byte])
# proc getRAM*(this: ALEInterface): ALERam
# proc saveState*(this: ALEInterface)
# proc loadState*(this: ALEInterface)
# proc cloneState*(this: ALEInterface): ALEState
# proc restoreState*(this: ALEInterface; state: ALEState)
# proc cloneSystemState*(this: ALEInterface): ALEState
# proc restoreSystemState*(this: ALEInterface; state: ALEState)
# proc saveScreenPNG*(this: ALEInterface; filename: CppString)
# proc createScreenExporter*(this: ALEInterface; path: CppString): ptr ScreenExporter
# proc welcomeMessage*(): CppString
proc disableBufferedIO*() {.h_ale_interface, importcpp:"ALEInterface::disableBufferedIO()".}
# proc createOSystem*(theOSystem: CppUniquePtr[OSystem];
#                     theSettings: CppUniquePtr[Settings])
# proc loadSettings*(romfile: string; theOSystem: CppUniquePtr[OSystem])

{.pop.}

# ############################################################
#
#                  End Wrapper
#
# ############################################################
