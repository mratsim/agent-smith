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

# Pong agent using Cross-Entropy Method
# https://en.wikipedia.org/wiki/Cross-entropy_method
# and
# Learning Tetris Using the Noisy Cross-Entropy Method
#    2006, Szita et al

# The CEM formula is
#
# ActionWeights = Observations * Weight + bias
#
# Observations is of shape [Environment]
# Weight is of shape [Environment, PotentialActions]
# bias is of shape [PotentialActions]
#
# The result is a [PotentialActions] vector.
#
# Similar to NLP text generation softmax it
# and sample it as a probability distribution
# and choose the next action from it.

import
  strformat, random, os,
  ../third_party/[ale_wrap, std_cpp],
  arraymancer # Need Arraymancer from December 2018

randomize(0xDEADBEEF) # Set random seed for reproducibility

# To speed up convergence, we allow only 3 actions
# Note that this is introducing prior knowledge that the agent
# doesn't have to discover. Ideally we shouldn't to have a general
# algorithm
type
  PongAction = enum
    DoNothing
    MoveUp
    MoveDown

func toAction(pa: PongAction): Action {.inline.} =
  case pa
  of DoNothing: PLAYER_A_NOOP
  of MoveUp: PLAYER_A_UP
  of MoveDown: PLAYER_A_DOWN

func screenToTensor(ale: ALEInterface): Tensor[float32] =
  ## The screen is of type byte/uint8 and shape 210x160x3
  ## (The x3 for RGB is handled via an internal color palette)
  ## We need to convert that to a flat [Environment] float32 vector
  ## Also for computational efficiency we should reduce the size.

  let screen = ale.getScreen()
  let height = screen.height
  let width = screen.width
  let size = height * width * 3

  # Directly write into the tensor buffer, with OpenAI color palette.
  var tmp = newTensorUninit[uint8](height, width, 3)
  ale.getScreenRGB_OpenAI(tmp.get_offset_ptr, size)

  # Set background to 0 and everything else to 1
  # This is probably faster to do this before downsampling
  # as memory accesses are contiguous this way.
  for val in tmp.mitems:
    if val in {144, 109}: val = 0 # 2 kinds of background
    else: val = 1

  # Now downsample the screen by skipping 1 every 2 pixel
  # and only keep a single color channel
  tmp = tmp[_.._|2, _.._|2, 0]

  # Convert to float32 and flatten
  result = tmp.astype(float32).reshape(tmp.size)

type
  CEMParams = ref object
    mean: Tensor[float32]
    std: Tensor[float32]
    batchSize: int
    n_epochs: int
    # Ratio of the population kept at the end of the epoch
    eliteRatio: float32
    # Noise to prevent the agent from converging to fast
    noise: float32
    noiseDecay: float32

# proc cem(ale: ALEInterface, params: CEMParams): float32 =
#   ## Return the mean of the final sampling ditribution

#   let n_elites = int(iniState.batchSize.float32 * iniState.eliteRatio)
#   var mean = iniState.mean
#   var std = ones

proc main() =
  const rom = "build/roms/pong.bin"

  let ale = newALEInterface(display_screen = true)
    # Don't display anything for training
  ale.setBool("sound", false)    # Sound of Pong is super annoying
  ale.setInt("random_seed", 123) # Reproducibility

  ale.loadROM(rom)
  let legal_actions = ale.getLegalActionSet()

  for episode in 0 ..< 5:
    echo &"Starting episode {episode}"
    let t = ale.screenToTensor()
    echo t[0 ..< 1000]
    var totalReward = 0
    while not ale.game_over():
      let a = rand([MoveDown, MoveUp, DoNothing]).toAction
      let reward = ale.act(a)
      totalReward += reward
    echo &"Episode {episode} ended with score {totalReward}"
    ale.reset_game()

  ale.loadROM(rom)

  quit QuitSuccess

main()
