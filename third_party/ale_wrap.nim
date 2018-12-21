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
  Action*{.importc, size: sizeof(int32),
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
proc newALEInterface*(): ALEInterface {.h_ale_interface, importcpp:"new ALEInterface()", constructor.}
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
proc getScreen*(this: ALEInterface): ALEScreen {.h_ale_interface, importcpp:"#.getScreen()".}
# proc getScreenGrayscale*(
#       this: ALEInterface;
#       grayscale_output_buffer: CppVector[byte])
proc getScreenRGB*(
        this: ALEInterface;
        output_rgb_buffer: var CppVector[byte]) {.h_ale_interface, importcpp:"#.getScreenRGB(#)".}
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
#                       End Wrapper
#
# ############################################################

# OpenAI alternative palette for image conversion

const OpenAI_Palette: array[256, uint32] = [
      0x000000'u32, 0, 0x4a4a4a, 0, 0x6f6f6f, 0, 0x8e8e8e, 0,
      0xaaaaaa, 0, 0xc0c0c0, 0, 0xd6d6d6, 0, 0xececec, 0,
      0x484800, 0, 0x69690f, 0, 0x86861d, 0, 0xa2a22a, 0,
      0xbbbb35, 0, 0xd2d240, 0, 0xe8e84a, 0, 0xfcfc54, 0,
      0x7c2c00, 0, 0x904811, 0, 0xa26221, 0, 0xb47a30, 0,
      0xc3903d, 0, 0xd2a44a, 0, 0xdfb755, 0, 0xecc860, 0,
      0x901c00, 0, 0xa33915, 0, 0xb55328, 0, 0xc66c3a, 0,
      0xd5824a, 0, 0xe39759, 0, 0xf0aa67, 0, 0xfcbc74, 0,
      0x940000, 0, 0xa71a1a, 0, 0xb83232, 0, 0xc84848, 0,
      0xd65c5c, 0, 0xe46f6f, 0, 0xf08080, 0, 0xfc9090, 0,
      0x840064, 0, 0x97197a, 0, 0xa8308f, 0, 0xb846a2, 0,
      0xc659b3, 0, 0xd46cc3, 0, 0xe07cd2, 0, 0xec8ce0, 0,
      0x500084, 0, 0x68199a, 0, 0x7d30ad, 0, 0x9246c0, 0,
      0xa459d0, 0, 0xb56ce0, 0, 0xc57cee, 0, 0xd48cfc, 0,
      0x140090, 0, 0x331aa3, 0, 0x4e32b5, 0, 0x6848c6, 0,
      0x7f5cd5, 0, 0x956fe3, 0, 0xa980f0, 0, 0xbc90fc, 0,
      0x000094, 0, 0x181aa7, 0, 0x2d32b8, 0, 0x4248c8, 0,
      0x545cd6, 0, 0x656fe4, 0, 0x7580f0, 0, 0x8490fc, 0,
      0x001c88, 0, 0x183b9d, 0, 0x2d57b0, 0, 0x4272c2, 0,
      0x548ad2, 0, 0x65a0e1, 0, 0x75b5ef, 0, 0x84c8fc, 0,
      0x003064, 0, 0x185080, 0, 0x2d6d98, 0, 0x4288b0, 0,
      0x54a0c5, 0, 0x65b7d9, 0, 0x75cceb, 0, 0x84e0fc, 0,
      0x004030, 0, 0x18624e, 0, 0x2d8169, 0, 0x429e82, 0,
      0x54b899, 0, 0x65d1ae, 0, 0x75e7c2, 0, 0x84fcd4, 0,
      0x004400, 0, 0x1a661a, 0, 0x328432, 0, 0x48a048, 0,
      0x5cba5c, 0, 0x6fd26f, 0, 0x80e880, 0, 0x90fc90, 0,
      0x143c00, 0, 0x355f18, 0, 0x527e2d, 0, 0x6e9c42, 0,
      0x87b754, 0, 0x9ed065, 0, 0xb4e775, 0, 0xc8fc84, 0,
      0x303800, 0, 0x505916, 0, 0x6d762b, 0, 0x88923e, 0,
      0xa0ab4f, 0, 0xb7c25f, 0, 0xccd86e, 0, 0xe0ec7c, 0,
      0x482c00, 0, 0x694d14, 0, 0x866a26, 0, 0xa28638, 0,
      0xbb9f47, 0, 0xd2b656, 0, 0xe8cc63, 0, 0xfce070, 0
]

proc getScreenRGB_OpenAI*(
        ale: ALEInterface;
        output_rgb_buffer: ptr byte, len: int) =
  # The output buffer must be allocated of the proper size

  let w = ale.getScreen.width
  let h = ale.getScreen.height
  let screen_size = w * h
  doAssert len == screen_size * 3

  when not defined(vcc):
    {.pragma: restrict, codegenDecl: "$# __restrict__ $#".}
  else:
    {.pragma: restrict, codegenDecl: "$# __restrict $#".}

  let screen{.restrict.} = cast[ptr UncheckedArray[byte]](ale.getScreen.getArray)
  let output{.restrict.} = cast[ptr UncheckedArray[byte]](output_rgb_buffer)

  var j = 0
  for i in 0 ..< screen_size:
    let zrgb = OpenAI_Palette[screen[i]]
    output[j] = byte(zrgb shr 16)
    j += 1
    output[j] = byte(zrgb shr 8)
    j += 1
    output[j] = byte zrgb
    j += 1
