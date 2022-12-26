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

##### SUCCESS case

def _build_test_contents_test_impl(ctx):
    env = analysistest.begin(ctx)

    target_under_test = analysistest.target_under_test(env)
    asserts.set_equals(env,
      sets.make(["build_success_test.empty.sh"]),
      sets.make([f.basename for f in target_under_test[DefaultInfo].files.to_list()]))
    return analysistest.end(env)

build_test_contents_test = analysistest.make(_build_test_contents_test_impl)

"""
# This doesn't seem to be possible. It seems that a test failing to even
# try to run is not something that expect_failure can be used to detect.

##### FAILURE case

def _build_test_failure_test_impl(ctx):
    env = analysistest.begin(ctx)
    asserts.expect_failure(env, "This rule should never work")
    return analysistest.end(env)

build_test_failure_test = analysistest.make(
    _build_test_failure_test_impl,
    expect_failure = True,
)
"""

##### Go

def build_test_suite(name):
    # Success
    native.genrule(
        name = "build_test_success_target",
        outs = ["build_test_success_target.txt"],
        cmd = "touch $@",
        tags = ["manual"],
    )

    build_test(
        name = "build_success_test",
        targets = [":build_test_success_target"],
        tags = ["manual"],
    )

    build_test_contents_test(
        name = "build_test_contents_test",
        target_under_test = ":build_success_test",
    )

    # Failure
    native.genrule(
        name = "build_test_failure_target",
        outs = ["build_test_failure_target.txt"],
        cmd = "false",
        tags = ["manual"],
    )

    build_test(
        name = "build_failure_test",
        targets = [":build_test_failure_target"],
        tags = ["manual"],
    )

    """
    # This doesn't work, see above. Check //tests:build_failure_test manualy.
    build_test_failure_test(
        name = "build_test_failure_test",
        target_under_test = ":build_failure_test",
    )
    """

    # Suit
    native.test_suite(
        name = name,
        tests = [
            ":build_success_test",
            ":build_test_contents_test",
            #":build_test_failure_test",
        ],
    )
