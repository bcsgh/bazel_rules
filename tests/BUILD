# Copyright (c) 2018, Benjamin Shropshire,
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
# 3. Neither the name of the copyright holder nor the names of its contributors
#    may be used to endorse or promote products derived from this software
#    without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

load("//build_test:build.bzl", "build_test")
load("//parser:parser.bzl", "genlex", "genyacc")

######## build_test
genrule(
  name = "build_test_target",
  outs = ["build_test_target.txt"],
  cmd = "touch $@",
)

build_test(
  name = "build_test_test",
  targets = [":build_test_target"],
)

######## genlex/genyacc

genyacc(
  name = "parser",
  src = "parser.y",
)

genlex(
  name = "lexer",
  src = "lexer.l",
)

cc_library(
  name = "parser_build",
  srcs = [
    #"parser.cc",
    ":lexer",
    ":parser",
  ],
  hdrs = [
    #"parser.h",
    ":lexer",
    ":parser",
    "gen.lexer.h",
    #"gen.parser.h",
  ],
  copts = [ # because bison
    "-fexceptions",
    "-Wno-sign-compare",
  ],
  deps = [
    #":ast",
    #":parser_support",
    #"@com_google_absl//absl/strings",
    #"@com_github_gflags_gflags//:gflags",
  ],
)

build_test(
  name = "parser_test",
  targets = [
    ":parser_build",
  ],
)