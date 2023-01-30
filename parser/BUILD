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

load(":parser.bzl", "parser_toolchain")

test_suite(name = "ci")

cc_library(
    name = "parser_support",
    srcs = ["parser_support.cc"],
    hdrs = ["parser_support.h"],
    visibility = ["//visibility:public"],
    deps = [
        "@com_google_absl//absl/strings:str_format",
    ],
)

cc_test(
    name = "parser_support_test",
    timeout = "short",
    srcs = ["parser_support_test.cc"],
    deps = [
        ":parser_support",
        "@com_google_googletest//:gtest_main",
    ],
)

toolchain_type(name = "toolchain_type")

parser_toolchain(
    name = "linux_local_flex_bison_toolchain",
    lex_gen = "/usr/bin/flex",
    parse_gen = "/usr/bin/bison",
)

toolchain(
    name = "linux_flex_bison",
    # Blindly asssume this is avalable if registered.
    # exec_compatible_with = ["@platforms//os:linux"], # TODO Would this be more correct?
    target_compatible_with = [], # Output is OS/CPU agnostic
    toolchain = ":linux_local_flex_bison_toolchain",
    toolchain_type = ":toolchain_type",
)
