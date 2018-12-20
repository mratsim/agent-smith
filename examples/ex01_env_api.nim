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
  os, random, strformat,
  ../third_party/[ale_wrap, std_cpp]

# Compatible ROMs can be found at https://github.com/openai/atari-py/tree/master/atari_py/atari_roms
proc main() =
  if paramCount() != 1:
    raise newException(ValueError, "Only 1 parameter is accepted, the path to an Atari ROM")

  let rom = paramStr(1)

  let ale = newALEInterface(display_screen = true)
    # Note: launching that from VSCode terminal doesn't display anything
  ale.setBool("sound", true)

  ale.setInt("random_seed", 123) # Reproducibility
  ale.setFloat("repeat_action_probability", 25)

  ale.loadROM(rom)
  let legal_actions = ale.getLegalActionSet()

  # Play 10 episodes
  for episode in 0 ..< 10:
    var totalReward = 0
    while not ale.game_over():
      let a = legal_actions[rand(legal_actions.len)]
      let reward = ale.act(a)
      totalReward += reward
    echo &"Episode {episode} ended with score {totalReward}"
    ale.reset_game()

  quit QuitSuccess

main()
