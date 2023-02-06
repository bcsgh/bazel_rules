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

_REPO_BUILD_TPL = """
load("@bazel_rules//latex:latex.bzl", "latex_toolchain")


latex_toolchain(
    name = "local_latex_toolchain",
    pdflatex = "{pdflatex}",
    detex = "{detex}",
)

toolchain(
    name = "local_latex",
    toolchain = ":local_latex_toolchain",
    toolchain_type = "@bazel_rules//latex:toolchain_type",
    visibility = ["//visibility:public"],
)
"""
def _latex_toolchain_repository_impl(ctx):
    pdflatex = ctx.which("pdflatex")
    detex = ctx.which("detex")
    if not pdflatex: print("Could not find pdflatex")
    if not detex: print("Could not find detex")
    if pdflatex and detex:
        ctx.file("BUILD", _REPO_BUILD_TPL.format(pdflatex=pdflatex, detex=detex))
    else:
        ctx.file("BUILD", "### Nothing implemented here.\n")

    return


latex_toolchain_repository = repository_rule(
    doc = "Build a @bazel_rules//latex:toolchain_type based on the current PATH.",

    implementation = _latex_toolchain_repository_impl,
    local = True,
    configure = True,

    attrs = {
    }
)
