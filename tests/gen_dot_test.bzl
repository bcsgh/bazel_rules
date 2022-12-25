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
load("@bazel_skylib//lib:sets.bzl", "sets")
load("//build_test:build.bzl", "build_test")
load("//graphviz:graphviz.bzl", "gen_dot")

##### SUCCESS case

def _gen_dot_contents_test_impl(ctx):
    env = analysistest.begin(ctx)

    target_under_test = analysistest.target_under_test(env)
    asserts.set_equals(env,
      sets.make(["gen_dot_test.png"]),
      sets.make([f.basename for f in target_under_test[DefaultInfo].files.to_list()]))
    return analysistest.end(env)

gen_dot_contents_test = analysistest.make(_gen_dot_contents_test_impl)

##### Go

def gen_dot_suite(name):
    # Success
    gen_dot(
        name = "gen_dot_success",
        src = ":gen_dot_test.dot",
        out = ":gen_dot_test.png",
        tags = ["manual"],
    )

    build_test(
        name = "gen_dot_builds_test",
        targets = [
            ":gen_dot_success",
        ],
    )

    gen_dot_contents_test(
        name = "gen_dot_contents_test",
        target_under_test = ":gen_dot_success",
    )

    # Suit
    native.test_suite(
        name = name,
        tests = [
            ":gen_dot_builds_test",
            ":gen_dot_contents_test",
        ],
    )
