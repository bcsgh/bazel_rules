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

"""Bazle/skylark rule(s) to process GraphViz."""

def _gen_dot_impl(ctx):
    out = ctx.actions.declare_file(ctx.outputs.out.basename)

    args = ctx.actions.args()
    args.add("-T%s" % ctx.attr.format)
    args.add("-o%s" % out.path)
    args.add_all(ctx.files.src)

    ctx.actions.run(
        inputs=ctx.files.src,
        outputs=[out],
        executable="dot",
        arguments = [args]
    )

    return [DefaultInfo(
        runfiles=ctx.runfiles(files = ctx.files.src),
    )]

gen_dot = rule(
    doc = "Process a .dot file.",

    implementation = _gen_dot_impl,
    attrs = {
        "src": attr.label(
            doc="The .dot file.",
            allow_single_file=[".dot"],
            mandatory=True,
        ),
        "out": attr.output(
            doc="The target file name.",
            mandatory=True,
        ),
        "format": attr.string(
            doc="The output file format.",
            default = "png",
        ),
    },
)
