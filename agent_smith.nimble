#  Agent Smith
#  Copyright (c) 2018-Present, Mamy André-Ratsimbazafy
#
#  This program is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation; either version 2
#  of the License, or (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.

packageName   = "agent_smith"
version       = "0.0.1"
author        = "Mamy André-Ratsimbazafy"
description   = "Reinforcement learning on Atari"
license       = "Apache License 2.0"

### Dependencies
requires "nim >= 0.19"

### Config
when defined(windows):
  const libName = "ale.dll"
elif defined(macosx):
  const libName = "libale.dylib"
else:
  const libName = "libale.so"

const sharedLib = "./third_party/ale_build.nim"

### Build
task build_ale, "Build the dependency Arcade Learning Environment shared library":
  if not dirExists "build":
    mkDir "build"
  switch("out", "./build/" & libName)
  switch("define", "release")
  switch("app", "lib")
  switch("noMain")
  setCommand "cpp", sharedLib
