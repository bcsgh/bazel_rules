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
load("//graphviz:graphviz.bzl", "gen_dot")
load("//latex:git_stamp.bzl", "git_stamp")
load("//latex:ref_test.bzl", "latex_ref_test")
load("//latex:role_call_test.bzl", "role_call_test")
load("@bazel_skylib//rules:diff_test.bzl", "diff_test")
load(":build_test_test.bzl", "build_test_suite")
load(":cc_embed_data_test.bzl", "cc_embed_data_suite")
load(":detex_test.bzl", "detex_suite")
load(":gen_dot_test.bzl", "gen_dot_suite")
load(":parser_test.bzl", "parser_suite")
load(":spell_test_test.bzl", "spell_test_suite")
load(":tex_to_pdf_test.bzl", "tex_to_pdf_suite")

test_suite(
    name = "ci",
    tests = [
        ":build_test_test",
        ":cc_embed_data_test",
        ":detex_test",
        ":dictionary_gold_test",
        ":eigen_test",
        ":gen_dot_test",
        ":gen_latex_test",
        ":parser_test",
        ":ref_test",
        ":role_call_test",
        ":spell_test_test",
    ],
)

######## build_test
build_test_suite(
    name = "build_test_test",
)

######## cc_embed_data

cc_embed_data_suite(
    name = "cc_embed_data_test",
)
######## genlex/genyacc

parser_suite(
    name = "parser_test"
)

######## gen_dot

gen_dot_suite(
    name = "gen_dot_test",
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

######## latex

git_stamp()

tex_to_pdf_suite(
    name = "gen_latex_test",
)

detex_suite(
    name = "detex_test",
)

latex_ref_test(
    name = "ref_test",
    jobname = "gen_latex",
)

role_call_test(
    name = "role_call_test",
    root = "gen_latex_test.tex",
    inputs = [
        "//latex:spelling.tex",
        ":fixed.tex",
    ],
    extra = [":git_stamp.tex"],
)

diff_test(
    name = "dictionary_gold_test",
    file1 = ":gen_latex.dict",
    file2 = ":spell_test.dict",
)

######## spelling

spell_test_suite(
    name = "spell_test_test",
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


