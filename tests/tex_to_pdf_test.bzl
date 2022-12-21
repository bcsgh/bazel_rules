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
load("//latex:latex.bzl", "tex_to_pdf")

##### SUCCESS case

def _tex_to_pdf_contents_test_impl(ctx):
    env = analysistest.begin(ctx)

    target_under_test = analysistest.target_under_test(env)
    asserts.equals(env,
      ["gen_latex." + e for e in sorted(["aux", "dict", "log", "pdf", "test"])],
      sorted([f.basename for f in target_under_test[DefaultInfo].files.to_list()]))
    return analysistest.end(env)

tex_to_pdf_contents_test = analysistest.make(_tex_to_pdf_contents_test_impl)

def _tex_to_pdf_failure_test_impl(ctx):
    env = analysistest.begin(ctx)
    asserts.expect_failure(env, ctx.attr.error_msg)
    return analysistest.end(env)

tex_to_pdf_failure_test = analysistest.make(
    _tex_to_pdf_failure_test_impl,
    expect_failure = True,
    attrs = {
        "error_msg": attr.string(
          doc="The output file name.",
          mandatory=True,
      ),
    }
)
##### Go

def tex_to_pdf_suite(name):
    # Success
    tex_to_pdf(
        name = "gen_tex_to_pdf",
        jobname = "gen_latex",
        src = "gen_latex_test.tex",
        data = [
            "//latex:spelling.tex",
            ":fixed.tex",
            ":git_stamp.tex",
        ],
        extra_outs = ["aux", "dict", "log", "test"],
        reprocess = ["echo foo >> gen_latex.test"],
        pdf = "gen_latex.pdf",
        runs = 3,
    )

    diff_test(
        name = "latex_gold_test",
        file1 = ":gen_latex.test",
        file2 = ":gen_latex.gold",
    )

    build_test(
        name = "tex_to_pdf_test",
        targets = [
            ":gen_tex_to_pdf",
        ],
    )

    tex_to_pdf_contents_test(
        name = "tex_to_pdf_contents_test",
        target_under_test = ":gen_tex_to_pdf",
    )

    tex_to_pdf(
        name = "tex_to_pdf_failure1",

        runs = 0,

        src = "gen_latex_test.tex",
        pdf = "failure1.pdf",
        tags = ["manual"],
    )

    tex_to_pdf_failure_test(
        name = "tex_to_pdf_failure1_test",
        error_msg = "At least 1 run requiered.",
        target_under_test = ":tex_to_pdf_failure1",
    )

    tex_to_pdf(
        name = "tex_to_pdf_failure2",

        runs = 1,
        reprocess = ["true"],

        src = "gen_latex_test.tex",
        pdf = "failure2.pdf",
        tags = ["manual"],
    )

    tex_to_pdf_failure_test(
        name = "tex_to_pdf_failure2_test",
        error_msg = "Reprocess does nothing without mutiple runs.",
        target_under_test = ":tex_to_pdf_failure2",
    )

    # Suit
    native.test_suite(
        name = name,
        tests = [
            ":tex_to_pdf_test",
            ":latex_gold_test",
            ":tex_to_pdf_contents_test",
            ":tex_to_pdf_failure1_test",
            ":tex_to_pdf_failure2_test",
        ],
    )
