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

"""
A basic test that always passes, as long as everythin in `targets` builds.
This is usefull, for example, with a genrule.

NOTE consider using:
https://github.com/bazelbuild/bazel-skylib/blob/main/docs/build_test_doc.md
"""

def _build_test_impl(ctx):
    executable = ctx.actions.declare_file(ctx.label.name + ".empty.sh")
    ctx.actions.write(output=executable, content="")

    deps = depset([], transitive=[t.files for t in ctx.attr.targets])

    return [DefaultInfo(
        executable=executable,
        runfiles=ctx.runfiles(files = deps.to_list()),
    )]

build_test = rule(
    doc = "A test that depends on arbitary targets.",

    implementation = _build_test_impl,
    test = True,
    attrs = {
        "targets": attr.label_list(
            doc="Targets to check.",
            mandatory=True,
            cfg="target",
            allow_empty=False,
            allow_files=False,
        ),
    },
)