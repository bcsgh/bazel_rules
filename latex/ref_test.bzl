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

"""Bazle/skylark rule(s) to test LaTeX builds."""

def _latex_ref_test_impl(ctx):
    _PYTHON = ctx.toolchains["@bazel_tools//tools/python:toolchain_type"].py3_runtime

    args = [_PYTHON.interpreter.path, ctx.file._tool.path]
    runs = [ctx.file._tool, _PYTHON.interpreter] + _PYTHON.files.to_list()

    # Try to find what we need.
    bits = [
        (f.extension, f)
        for f in ctx.attr.src[DefaultInfo].files.to_list()
        if f.extension in ["aux", "log"]
    ]

    # Check to see if we got what we need.
    fmt = "Expected %s to have exactly one each of .aux and .log outputs. Found %s"
    if len(bits) != 2: fail(fmt % (ctx.attr.src.label, [f.short_path for e,f in bits]))
    bits = dict(bits)
    if len(bits) != 2: fail(fmt % (ctx.attr.src.label, [f.short_path for f in bits.values()]))

    # Yield it
    aux = bits["aux"]
    log = bits["log"]

    args += ["--aux=%s" % aux.short_path,"--log=%s" % log.short_path]
    runs += [aux, log]

    # Tack on some options.
    if ctx.attr.ignore_dups: args += ["--ignore_dups"]

    args += ["--extern=%s" %i for i in ctx.attr.externs]

    executable = ctx.actions.declare_file(ctx.label.name + ".sh")
    ctx.actions.write(
        output=executable,
        content="\n".join([
            " ".join(args),
            "",
        ]),
    )

    return [DefaultInfo(
        executable=executable,
        runfiles=ctx.runfiles(files=runs),
    )]

latex_ref_test = rule(
    doc = "Test for missing label references.",

    implementation = _latex_ref_test_impl,
    test = True,
    attrs = {
        "src": attr.label(
            doc="The tex_to_pdf to get the .log and .aux files from.",
            mandatory=True,
        ),
        "ignore_dups": attr.bool(
            doc="Suppress check for duplicate labels.",
            default=False,
        ),
        "externs": attr.string_list(
            doc="Lables to ignore missing refernces to.",
            default=[],
        ),
        "_tool": attr.label(
            doc="The test script.",
            allow_single_file=True,
            default="@bazel_rules//latex:ref_test.py",
        ),
    },
    toolchains = ["@bazel_tools//tools/python:toolchain_type"],
)
