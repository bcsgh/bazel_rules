# Copyright (c) 2023, Benjamin Shropshire,
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

load("@bazel_skylib//rules:diff_test.bzl", "diff_test")
load("@bazel_rules//css_js:css_js.bzl", "css_class_names_js", "CSS_BINARY_MUNGE_DEFS")
load("@io_bazel_rules_closure//closure/stylesheets:closure_css_binary.bzl", "closure_css_binary")
load("@io_bazel_rules_closure//closure/stylesheets:closure_css_library.bzl", "closure_css_library")

def css_class_names_js_suite(name):
    closure_css_library(
        name = "css_js_lib",
        srcs = ["css_js.css"],
    )

    closure_css_binary(
        name = "css_js_bin",
        deps = [":css_js_lib"],
        defs = CSS_BINARY_MUNGE_DEFS,
    )

    css_class_names_js(
        name = "gen_css_js",
        css_binary = ":css_js_bin",
        module = "Test.Css",
    )

    diff_test(
        name = "css_js_test",
        file1 = "gen_css_js.js",
        file2 = "css_js.gold.js",
    )

    # Suit
    native.test_suite(
        name = name,
        tests = [
            ":css_js_test",
        ],
    )
