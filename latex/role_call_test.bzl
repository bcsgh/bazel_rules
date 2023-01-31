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
load("//repositories:repositories.bzl", "load_skylib")

def get_deps():
    "A WORKSPACE macro to set up the external dependencies of role_call_test()."
    load_skylib()

def _role_call_test_impl(ctx):
    _PYTHON = ctx.toolchains["@bazel_tools//tools/python:toolchain_type"].py3_runtime
    interpreter = _PYTHON.interpreter.path.removeprefix(_PYTHON.interpreter.root.path + "/")

    args = [interpreter, ctx.file._tool.path]
    runs = _PYTHON.files.to_list() + [
        _PYTHON.interpreter,
        ctx.file._tool,
        ctx.file.root,
    ] + ctx.files.inputs

    def Squash(f):
        path = f.short_path.split("/")
        backs = reversed([i for i,x in enumerate(path) if x == ".."])
        for a in backs: path = path[:a] + path[a+2:]
        return "/".join(path)

    _json = ctx.actions.declare_file(ctx.label.name + ".json")
    JSON = struct(
        root=Squash(ctx.file.root),
        inputs=[Squash(f) for f in ctx.files.inputs],
        extra=[Squash(f) for f in ctx.files.extra],
        ignore_re=ctx.attr.ignore_re,
    )

    # Check that each file only shows up once.
    all = JSON.inputs + JSON.extra + [JSON.root]
    if len(all) != len(dict([(k,0) for k in all])):
        fail("Found duplicate inputs.")

    ctx.actions.write(
        output=_json,
        content=json.encode(JSON) + "\n",
    )

    runs += [_json]
    args += ["--json=%s" % _json.short_path]

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

role_call_test = rule(
    doc = "Test that the expected inputs exist and are used.",

    implementation = _role_call_test_impl,
    test = True,
    attrs = {
        "root": attr.label(
            doc="The root file that the inputs should be reachable from.",
            allow_single_file=True,
            mandatory=True,
        ),
        "inputs": attr.label_list(
            doc="The files that should be reachable and can be used.",
            allow_files=True,
        ),
        "extra": attr.label_list(
            doc="Files that might be read but aren't tested for.",
            allow_files=True,
        ),
        "ignore_re": attr.string_list(
            doc="Patterns to ignore as input arguments. (Uses python regex syntax.)",
        ),
        "_tool": attr.label(
            doc="The test script.",
            allow_single_file=True,
            default=":role_call.py",
        ),
    },
    toolchains = ["@bazel_tools//tools/python:toolchain_type"],
)
