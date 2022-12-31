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
load("//latex:latex.bzl", "tex_to_pdf")
load("//latex:ref_test.bzl", "latex_ref_test")

##### SUCCESS case

def _ref_test_contents_test_impl(ctx):
    env = analysistest.begin(ctx)

    target_under_test = analysistest.target_under_test(env)
    asserts.set_equals(env,
        sets.make(["ref_test_pass_test.sh"]),
        sets.make([f.basename for f in target_under_test[DefaultInfo].files.to_list()]))
    return analysistest.end(env)

ref_test_contents_test = analysistest.make(_ref_test_contents_test_impl)

##### Go

def latex_ref_test_suite(name, job):
    # Success
    latex_ref_test(
        name = "ref_test_pass_test",
        src = job,
    )

    ref_test_contents_test(
        name = "ref_test_contents_test",
        target_under_test = ":ref_test_pass_test",
    )

    # Failure
    tex_to_pdf(
        name = "tex_to_pdf_ref_error",
        src = "ref_error.tex",
        outs = [
            "ref_error.aux",
            "ref_error.log",
        ],
        pdf = "ref_error.pdf",
        runs = 1,
    )

    latex_ref_test(
        name = "ref_test_fail_test",
        src = ":tex_to_pdf_ref_error",
        tags = ["manual"],
    )

    # TODO find a better way to do this:
    # https://stackoverflow.com/questions/74844959
    native.sh_test(
        name = "ref_test_failure_test",
        srcs = [":not.sh"],
        args = ["$(location :ref_test_fail_test)"],
        data = [":ref_test_fail_test"],
    )

    # Suit
    native.test_suite(
        name = name,
        tests = [
            ":ref_test_contents_test",
            ":ref_test_failure_test",
        ],
    )
