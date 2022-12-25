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

# implementation from:
# https://stackoverflow.com/a/7779766/1343
# http://www.math.utah.edu/docs/info/ld_2.html
# https://gcc.gnu.org/onlinedocs/gcc/Link-Options.html

"""
A Bazel/skylark rule for embedding files from the build environment into the
data section of a binary and making them accessible as a library.

This allows placing large test or binary artifacts to come from faw files (or
other build artifacts) rather than deal with escaping them into string literals.
"""

load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain", "use_cpp_toolchain")

_ALLOWED = ("0123456789" +
            "ABCDEFGHIJKLMNOPQRSTUVWXYZ" +
            "abcdefghijklmnopqrstuvwxyz")

def _Clean(p):
    return "".join([
        p[c] if p[c] in _ALLOWED else "_"
        for c in range(len(p))
    ])

def _cc_embed_data_impl(ctx):
    cc = ctx.actions.declare_file(ctx.outputs.cc.basename)
    h = ctx.actions.declare_file(ctx.outputs.h.basename)

    prefix = "%s_%s" % (_Clean(ctx.label.package), _Clean(ctx.attr.lib_name))

    args = ctx.actions.args()
    args.add("--h=%s" % h.path)
    args.add("--cc=%s" % cc.path)
    args.add("--gendir=%s" % ctx.genfiles_dir.path)
    args.add("--workspace=%s" % ctx.workspace_name) ##(native.repository_name().lstrip("@"))
    if ctx.attr.namespace: args.add("--namespace=%s" % ctx.attr.namespace)
    args.add("--symbol_prefix=%s" % prefix)
    args.add_all(ctx.files.srcs)

    ctx.actions.run(
        inputs=ctx.files.srcs,
        outputs=[cc, h],
        executable=ctx.file._make_emebed_data,
        arguments=[args]
    )

    o = ctx.actions.declare_file(ctx.outputs.o.basename)

    args = ctx.actions.args()
    args.add("-o%s" % o.path)   # Output file name
    args.add("-r")              # Make relocatable output (don't resolve stuff).
    args.add("--format=binary") # Just read in the files.

    links = []
    for i, f in enumerate(ctx.files.srcs):
        links += [f]
        args.add(f.path)

    ctx.actions.run(
        inputs=depset(links),
        outputs=[o],
        executable=find_cpp_toolchain(ctx).ld_executable,
        arguments=[args]
    )

    return [DefaultInfo(
        runfiles=ctx.runfiles(files = ctx.files.srcs + ctx.files._make_emebed_data),
    )]

_cc_embed_data = rule(
    doc = "Generate (bits of) a library containing the contents of srcs.",

    implementation = _cc_embed_data_impl,
    attrs = {
        "lib_name": attr.string(
            doc="The bazel name of the generated C++ library rule.",
            mandatory=True,
        ),
        "namespace": attr.string(
            doc="If given, the C++ namespace to generate in.",
        ),
        "cc": attr.output(
            doc="The generated C++ source file.",
            mandatory=True,
        ),
        "h": attr.output(
            doc="The generated C++ header file.",
            mandatory=True,
        ),
        "o": attr.output(
            doc="The generated object file.",
            mandatory=True,
        ),
        "srcs": attr.label_list(
            doc="The files to embed.",
            allow_files=True,
            allow_empty=False,
        ),
        "_make_emebed_data": attr.label(
            doc="The C++ file generater.",
            allow_single_file=True,
            default="@bazel_rules//cc_embed_data:make_emebed_data",
        ),
        "_cc_toolchain": attr.label(  # used by find_cpp_toolchain()
            default = Label("@bazel_tools//tools/cpp:current_cc_toolchain")
        ),
    },
    toolchains = use_cpp_toolchain(),
)

def cc_embed_data(name = None, srcs = None, namespace = None, visibility = None):
    """Generate a library containing the contents of srcs.

    Args:
      name: The target name.
      srcs: The files to embed.
      namespace: If given, the C++ namespace to generate in.
    """
    cc = name + "_emebed_data.cc"
    h = name + "_emebed_data.h"
    o = name + "_emebed_data.o"

    _cc_embed_data(
        name = name + "_make_emebed_src",
        cc = cc,
        h = h,
        o = o,
        srcs = srcs,
        lib_name = name,
        namespace = namespace,
    )

    native.cc_library(
        name = name,
        srcs = [cc, o],
        hdrs = [h],
        deps = [
            "@com_google_absl//absl/strings",
            "@com_google_absl//absl/types:span",
        ],
        visibility = visibility,
    )
