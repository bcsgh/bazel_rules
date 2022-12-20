# Copyright (c) 2022, Benjamin Shropshire,
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

load("@bazel_skylib//lib:unittest.bzl", "asserts", "analysistest")
load("@bazel_skylib//rules:diff_test.bzl", "diff_test")
load("//build_test:build.bzl", "build_test")
load("//latex:latex.bzl", "detex")

##### SUCCESS case

def _detex_contents_test_impl(ctx):
    env = analysistest.begin(ctx)

    target_under_test = analysistest.target_under_test(env)
    asserts.equals(env,
      ["gen_detex.txt"],
      [f.basename for f in target_under_test[DefaultInfo].files.to_list()])
    return analysistest.end(env)

detex_contents_test = analysistest.make(_detex_contents_test_impl)

##### Go

def detex_suite(name):
    # Success
    detex(
        name = "gen_detex",
        src = "gen_latex_test.tex",
        post_sed = ":detex_test.sed"
    )

    diff_test(
        name = "detex_gold_test",
        file1 = ":gen_detex",
        file2 = ":gen_latex_test_detex.gold",
    )

    build_test(
        name = "detex_build_test",
        targets = [
            ":gen_detex",
        ],
    )

    detex_contents_test(
        name = "detex_contents_test",
        target_under_test = ":gen_detex",
    )

    # Suit
    native.test_suite(
        name = name,
        tests = [
            ":detex_build_test",
            ":detex_contents_test",
            ":detex_gold_test",
        ],
    )
