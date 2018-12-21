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
#                   C++ standard types wrapper
#
# ############################################################

type
  # UniquePtr* {.importcpp: "std::unique_ptr<'*0, std::default_delete<'*0>>",
  #             header: "<memory>".} [T] = object
  CppUniquePtr* {.importcpp: "std::unique_ptr", header: "<memory>", byref.} [T] = object
  CppVector* {.importcpp"std::vector", header: "<vector>", byref.} [T] = object
  CppString* {.importcpp: "std::string", header: "<string>", byref.} = object

proc newCppVector*[T](): CppVector[T] {.importcpp: "std::vector<'0>()", header: "<vector>", constructor.}
proc newCppVector*[T](size: int): CppVector[T] {.importcpp: "std::vector<'0>(#)", header: "<vector>", constructor.}
proc len*(v: CppVector): int {.importcpp: "#.size()", header: "<vector>".}
proc add*[T](v: var CppVector[T], elem: T){.importcpp: "#.push_back(#)", header: "<vector>".}
proc `[]`*[T](v: CppVector[T], idx: int): T{.importcpp: "#[#]", header: "<vector>".}
proc `[]`*[T](v: var CppVector[T], idx: int): var T{.importcpp: "#[#]", header: "<vector>".}
