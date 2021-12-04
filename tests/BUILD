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
load("//cc_embed_data:cc_embed_data.bzl", "cc_embed_data")
load("//graphviz:graphviz.bzl", "gen_dot")
load("//parser:parser.bzl", "genlex", "genyacc")

test_suite(name = "ci")

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

######## cc_embed_data

SRCS = glob(["*"])

cc_embed_data(
    name = "cc_embed_data_example",
    srcs = SRCS,
    namespace = "test_ns",
)

build_test(
    name = "cc_embed_data_build_test",
    targets = [":cc_embed_data_example"],
)

cc_test(
    name = "cc_embed_data_test",
    srcs = ["cc_embed_data_test.cc"],
    data = SRCS,
    deps = [
        ":cc_embed_data_example",
        "@com_google_googletest//:gtest_main",
    ],
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
        ":lexer",
        ":parser",
    ],
    hdrs = [
        "gen.lexer.h",
        ":lexer",
        ":parser",
    ],
    copts = [
        # because bison
        "-fexceptions",
        "-Wno-sign-compare",
    ],
)

build_test(
    name = "parser_test",
    targets = [
        ":parser_build",
    ],
)

######## gen_dot

gen_dot(
    name = "gen_dot_png",
    src = ":gen_dot_test.dot",
    out = ":gen_dot_test.png",
)

build_test(
    name = "gen_dot_test",
    targets = [
        ":gen_dot_png",
    ],
)

######## http

build_test(
    name = "http",
    tags = ["manual"],
    targets = [
        "@com_github_etr_libhttpserver//:libhttpserver",
        "@org_gnu_microhttpd//:microhttpd",
    ],
)

######## repositories

cc_library(
    name = "eigen_static_test",
    srcs = ["eigen_static_test.cc"],
    visibility = ["@eigen//:eigen_visibility"],
)

build_test(
    name = "eigen_test",
    targets = [
        "@eigen//:eigen",
    ],
)

cc_test(
    name = "libcurl_tls_test",
    srcs = ["libcurl_tls_test.cc"],
    tags = ["manual"],
    deps = [
        "@com_github_curl_curl//:curl",
        "@com_google_absl//absl/cleanup",
        "@com_google_absl//absl/strings",
    ],
)

