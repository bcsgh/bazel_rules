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

# implementation from:
# https://stackoverflow.com/a/7779766/1343
# http://www.math.utah.edu/docs/info/ld_2.html
# https://gcc.gnu.org/onlinedocs/gcc/Link-Options.html
load("//repositories:repositories.bzl", "load_skylib", "load_absl")

def get_deps():
    load_skylib()
    load_absl()

def _gen_proto_api_impl(ctx):
    args = ctx.actions.args()
    args.add("--src=%s" % ctx.attr.proto[ProtoInfo].direct_descriptor_set.path)

    if ctx.outputs.js:
        js = ctx.actions.declare_file(ctx.outputs.js.basename)
        args.add("--js=%s" % js.path)

    if ctx.outputs.h:
        h = ctx.actions.declare_file(ctx.outputs.h.basename)
        args.add("--h=%s" % h.path)

    ctx.actions.run(
        inputs=[ctx.file.proto],
        outputs=[js, h],
        executable=ctx.file._tool,
        arguments=[args],
    )
    return


gen_proto_api = rule(
    doc = "Generate JS and C++ code that exposes the same string constants.",

    implementation = _gen_proto_api_impl,
    attrs = {
        "proto": attr.label(
            doc = "A proto_pimrary rule to generate from.",
            allow_single_file=True,
            mandatory=True,
            providers=[ProtoInfo]
        ),
        "js": attr.output(
            doc="The generated JavaScript file.",
        ),
        "h": attr.output(
            doc="The generated C++ header file.",
        ),
        "_tool": attr.label(
            doc="The generater.",
            allow_single_file=True,
            default="@bazel_rules//proto_api:gen_metadata_tool",
        ),
    },
)
