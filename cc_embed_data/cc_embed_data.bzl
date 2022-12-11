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

def cc_embed_data(name = None, srcs = None, namespace = None, visibility = None):
    """Generate a library containing the contents of srcs.

    Args:
      name: The target name.
      srcs: The files to embed.
      namespace: If given, the C++ namespace to generate in.
    """
    if not srcs:
        fail("srcs must be provided")
    if not name:
        fail("name must be provided")

    cc = name + "_emebed_data.cc"
    h = name + "_emebed_data.h"
    o = name + "_emebed_data.o"

    PREFIX = "$$(dirname $(rootpath %s) | sed 's|[^0-9A-Za-z]|_|g')_%s" % (cc, name)

    native.genrule(
        name = name + "_make_emebed_src",
        outs = [cc, h],
        srcs = srcs,
        tools = ["@bazel_rules//cc_embed_data:make_emebed_data"],
        cmd = " ".join([
            "$(location @bazel_rules//cc_embed_data:make_emebed_data)",
            "--h=$(location %s)" % (h),
            "--cc=$(location %s)" % (cc),
            "--gendir=$(GENDIR)",
            "--workspace=%s" % (native.repository_name().lstrip("@")),
            "--namespace=%s" % (namespace or ""),
            "--symbol_prefix=%s" % PREFIX,
            "$(SRCS)",
        ]),
    )

    native.genrule(
        name = name + "_make_embed_obj",
        outs = [o],
        srcs = srcs + [cc],  # include `cc` just to ask about its path.
        cmd = " ; ".join([
            "PREFIX=%s" % PREFIX,
        ] + [
            # Copy the inputs to fixed locations
            "cp $(location %s) $${PREFIX}_%d" % (srcs[i], i)
            for i in range(len(srcs))
        ]) + " ; " + " ".join([
            "$(CC) $(CC_FLAGS)",  # Compiler and default flags.
            "-nostdlib",  # This is just data, no libs needed.
            "-o $(location %s)" % (o),  # Output file name
            "-no-pie",  # Avoid position independent executable.
            "-Wl,-r",  # Make relocatable output (don't resolve stuff).
            "-Wl,--format=binary",  # Just read in the files.
        ] + [
            # The files need to be passed via `-Wl,...` so that the
            # compiler won't try to handle file of know type itself.
            "-Wl,$${PREFIX}_%d" % i
            for i in range(len(srcs))
        ]),
        toolchains = [
            "@bazel_tools//tools/cpp:current_cc_toolchain",
            "@bazel_rules//cc_embed_data:cc_flags",
        ],
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
