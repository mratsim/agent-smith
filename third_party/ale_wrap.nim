
import strutils, ospaths
from os import DirSep, walkFiles

const cppSrcPath = currentSourcePath.rsplit(DirSep, 1)[0] &
  "/arcade_learning_environment/src/"

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
{.pragma: h_ale_interface, header: cppSrcPath & "ale_interface.hpp".}

{.push callConv: cdecl.}
proc disableBufferedIO*() {.h_ale_interface, importcpp:"ALEInterface::disableBufferedIO()".}
{.pop.}

proc main() =
  disableBufferedIO()

main()
