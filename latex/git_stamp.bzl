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

load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

def _fit_stamp_impl(ctx):
    if ctx.outputs.tex:
        tex = ctx.actions.declare_file(ctx.outputs.tex.basename)
    else:
        print("git_stamp.tex should be explicitly set;\n" +
              '    tex = "' + ctx.label.name + '.tex",\n'+
              "This will be reqiered at some point.")
        tex = ctx.actions.declare_file(ctx.label.name + ".tex")

    ctx.actions.expand_template(
        template=ctx.file._tpl,
        output=tex,
        substitutions={"COMMIT": ctx.attr._git[BuildSettingInfo].value},
    )
    return [DefaultInfo(files=depset([tex]))]


git_stamp = rule(
    doc = """Generate a .tex file defining the command \\GitCommit to give the current git commit hash.

Note: for this to work the WORKSPACE must include a few repositories:

  load("@bazel_rules//latex:git_stamp_deps.bzl", git_stamp_deps = "get_deps")
  git_stamp_deps()
""",

    implementation = _fit_stamp_impl,
    attrs = {
        "tex": attr.output(),
        "_tpl": attr.label(default="//latex:git_stamp.tpl", allow_single_file=True),
        "_git": attr.label(default="@workspace_status//:git-commit"),
    },
)
