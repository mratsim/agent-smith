##  *****************************************************************************
##
##  Agent Smith
##  Copyright (c) 2018-Present, Mamy André-Ratsimbazafy
##
##  *****************************************************************************
##  *****************************************************************************
##  A.L.E (Arcade Learning Environment)
##  Copyright (c) 2009-2013 by Yavar Naddaf, Joel Veness, Marc G. Bellemare and
##    the Reinforcement Learning and Artificial Intelligence Laboratory
##  Released under the GNU General Public License; see License.txt for details.
##
##  Based on: Stella  --  "An Atari 2600 VCS Emulator"
##  Copyright (c) 1995-2007 by Bradford W. Mott and the Stella team
##
##  *****************************************************************************
##   ale_interface.hpp
##
##   The shared library interface.
## ***************************************************************************

import strutils, ospaths
from os import DirSep, walkFiles

# ############################################################
#
#                   C++ standard types wrapper
#
# ############################################################

type
  # UniquePtr* {.importcpp: "std::unique_ptr<'*0, std::default_delete<'*0>>",
  #             header: "<memory>".} [T] = object
  CppUniquePtr {.importcpp: "std::unique_ptr", header: "<memory>", byref.} [T] = object
  CppVector {.importcpp"std::vector", header"<vector>", byref.} [T] = object
  CppString {.importcpp: "std::string", header: "<string>", byref.} = object

# ############################################################
#
#                          ALE types
#
# ############################################################

const cppSrcPath = currentSourcePath.rsplit(DirSep, 1)[0] &
  "/arcade_learning_environment/src/"

type
  Action* = enum # Constants.h
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

# ##############################
# src/environment/ale_ram.hpp

{.pragma: ale_ram, cdecl, importcpp, header: cppSrcPath & "environment/ale_ram.hpp".}
func get*(this: ALERam; x: uint32): byte {.ale_ram.}
proc mut*(this: ALERam; x: uint32): ptr byte {.cdecl, importcpp:"byte", header: cppSrcPath & "environment/ale_ram.hpp".}
func array*(this: ALERam): ptr byte {.ale_ram.}
func size*(this: ALERam): csize {.ale_ram.}
func equals*(this: ALERam; rhs: ALERam): bool {.ale_ram.}

# ##############################
# src/environment/ale_screen.hpp

{.pragma: ale_screen, cdecl, importcpp, header: cppSrcPath & "environment/ale_screen.hpp".}
func get*(this: ALEScreen; r: int32; c: int32): Pixel {.ale_screen.}
func mut*(this: ALEScreen; r: int32; c: int32): ptr Pixel {.cdecl, importcpp:"pixel", header: cppSrcPath & "environment/ale_screen.hpp".}
func getRow*(this: ALEScreen; r: int32): ptr Pixel {.ale_screen.}
  ## Row-major ordering, increase ptr by 1 for next column
func getArray*(this: ALEScreen): ptr Pixel {.ale_screen.}
func height*(this: ALEScreen): csize {.ale_screen.}
func width*(this: ALEScreen): csize {.ale_screen.}
func arraySize*(this: ALEScreen): csize {.ale_screen.}
func equals*(this: ALEScreen; rhs: ALEScreen): bool {.ale_screen.}

# ##############################
# src/common/ScreenExporter.hpp

{.pragma: screen_exporter, cdecl, importcpp, header: cppSrcPath & "common/ScreenExporter.hpp".}
proc save*(this: ScreenExporter; screen: ALEScreen; filename: CppString) {.screen_exporter.}
proc saveNext*(this: ScreenExporter; screen: ALEScreen) {.screen_exporter.}

# ##############################
# src/ale_interface.hpp

{.pragma: ale_interface, cdecl, importcpp, header: cppSrcPath & "ale_interface.hpp".}
proc constructALEInterface*(): ALEInterface {.ale_interface, constructor.}
proc destroyALEInterface*(this: ALEInterface) {.ale_interface.}
proc constructALEInterface*(display_screen: bool): ALEInterface {.ale_interface, constructor.}
proc getString*(this: ALEInterface; key: CppString): CppString {.ale_interface.}
proc getInt*(this: ALEInterface; key: CppString): int32 {.ale_interface.}
proc getBool*(this: ALEInterface; key: CppString): bool {.ale_interface.}
proc getFloat*(this: ALEInterface; key: CppString): float32 {.ale_interface.}
proc setString*(this: ALEInterface; key: CppString; value: CppString) {.ale_interface.}
proc setInt*(this: ALEInterface; key: CppString; value: int32) {.ale_interface.}
proc setBool*(this: ALEInterface; key: CppString; value: bool) {.ale_interface.}
proc setFloat*(this: ALEInterface; key: CppString; value: float32) {.ale_interface.}
proc loadROM*(this: ALEInterface; rom_file: CppString) {.ale_interface.}
proc act*(this: ALEInterface; action: Action): Reward {.ale_interface.}
proc game_over*(this: ALEInterface): bool {.ale_interface.}
proc reset_game*(this: ALEInterface) {.ale_interface.}
proc getAvailableModes*(this: ALEInterface): ModeVect {.ale_interface.}
proc setMode*(this: ALEInterface; m: GameMode) {.ale_interface.}
proc getAvailableDifficulties*(this: ALEInterface): DifficultyVect {.ale_interface.}
proc setDifficulty*(this: ALEInterface; m: Difficulty) {.ale_interface.}
proc getLegalActionSet*(this: ALEInterface): ActionVect {.ale_interface.}
proc getMinimalActionSet*(this: ALEInterface): ActionVect {.ale_interface.}
proc getFrameNumber*(this: ALEInterface): int32 {.ale_interface.}
proc lives*(this: ALEInterface): int32 {.ale_interface.}
proc getEpisodeFrameNumber*(this: ALEInterface): int32 {.ale_interface.}
proc getScreen*(this: ALEInterface): ALEScreen {.ale_interface.}
proc getScreenGrayscale*(
      this: ALEInterface;
      grayscale_output_buffer: CppVector[byte]) {.ale_interface.}
proc getScreenRGB*(
        this: ALEInterface;
        output_rgb_buffer: CppVector[byte]) {.ale_interface.}
proc getRAM*(this: ALEInterface): ALERam {.ale_interface.}
proc saveState*(this: ALEInterface) {.ale_interface.}
proc loadState*(this: ALEInterface) {.ale_interface.}
proc cloneState*(this: ALEInterface): ALEState {.ale_interface.}
proc restoreState*(this: ALEInterface; state: ALEState) {.ale_interface.}
proc cloneSystemState*(this: ALEInterface): ALEState {.ale_interface.}
proc restoreSystemState*(this: ALEInterface; state: ALEState) {.ale_interface.}
proc saveScreenPNG*(this: ALEInterface; filename: CppString) {.ale_interface.}
proc createScreenExporter*(this: ALEInterface; path: CppString): ptr ScreenExporter {.ale_interface.}
proc welcomeMessage*(): CppString {.ale_interface.}
proc disableBufferedIO*() {.ale_interface.}
proc createOSystem*(theOSystem: CppUniquePtr[OSystem];
                    theSettings: CppUniquePtr[Settings]) {.ale_interface.}
proc loadSettings*(romfile: string; theOSystem: CppUniquePtr[OSystem]) {.ale_interface.}
