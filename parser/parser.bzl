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

"""Bazel/skylark rules for wrapping Flex/Bison builds."""

def genlex(name, src, data = []):
    """Generate a lexer using flex."""
    c = "%s.yy.cc" % name
    h = "%s.yy.h" % name
    cmd = "flex --outfile=$(@D)/%s --header-file=$(@D)/%s $(location %s)" % (c, h, src)
    native.genrule(
        name = name + "_gen",
        outs = [c, h],
        srcs = [src] + data,
        cmd = cmd,
    )
    native.filegroup(
        name = name,
        srcs = [c, h],
    )

def genyacc(name, src, data = [], graph=False, report=False):
    """Generate a paser using bison."""
    c = "%s.tab.cc" % name
    h = "%s.tab.h" % name
    cmd = "bison --output=$(@D)/%s --defines=$(@D)/%s $(location %s)" % (c, h, src)
    outs = [
        c,
        h,
        # TODO: figure out how to not generate these for every invocation.
        "stack.hh",
        "position.hh",
        "location.hh",
    ]

    if graph:
        g = "%s.dot" % name
        cmd += " --graph=$(@D)/%s" % g
        outs.append(g)
    if report:
        r = "%s.output" % name
        cmd += " --verbose --report=all"
        outs.append(r)

    native.genrule(
        name = name + "_gen",
        outs = outs,
        srcs = [src] + data,
        cmd = cmd,
    )
    native.filegroup(
        name = name,
        srcs = outs,
    )
