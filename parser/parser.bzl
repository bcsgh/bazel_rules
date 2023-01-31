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

def _genlex_impl(ctx):
    _PARSER = ctx.toolchains[":toolchain_type"].parser_gen_info

    cc = ctx.actions.declare_file(ctx.attr.cc.name)
    h  = ctx.actions.declare_file(ctx.attr.h.name)

    args = ctx.actions.args()
    args.add("--outfile=%s" % cc.path)
    args.add("--header-file=%s" % h.path)
    args.add_all(ctx.files.src)

    ctx.actions.run(
        inputs=depset(ctx.files.src + ctx.files.data),
        outputs=[cc, h],
        executable=_PARSER.lex_gen,
        arguments = [args],
    )

    return [DefaultInfo(
        runfiles=ctx.runfiles(files=ctx.files.src + ctx.files.data),
    )]

genlex = rule(
    doc = "Generate a lexer using flex.",

    implementation = _genlex_impl,
    attrs = {
        "src": attr.label(
            doc="The root source file.",
            allow_single_file=[".l"],
            mandatory=True,
        ),
        "data": attr.label_list(
            doc="Other files needed.",
            allow_files=True,
            default=[],
        ),

        "cc": attr.output(
            doc="The generated C++ source file.",
            mandatory=True,
        ),
        "h": attr.output(
            doc="The generated C++ header file.",
            mandatory=True,
        ),
    },
    toolchains = [":toolchain_type"],
)

def _genyacc_impl(ctx):
    _PARSER = ctx.toolchains[":toolchain_type"].parser_gen_info

    if ctx.attr.graph:
        print("genyacc.graph is deprecated. " +
              'Use genyacc.graph_file = "%s.dot"' % ctx.label.name)
    if ctx.attr.report:
        print("genyacc.report is deprecated. " +
              'Use genyacc.report_file = "%s.output"' % ctx.label.name)

    # Default setup.
    cc = ctx.actions.declare_file(ctx.attr.cc.name)
    h = ctx.actions.declare_file(ctx.attr.h.name)
    outs = [cc, h]

    if ctx.attr.loc:
        loc = ctx.actions.declare_file(ctx.attr.loc.name)
        outs += [loc]

    args = ctx.actions.args()
    args.add("--output=%s" % cc.path)
    args.add("--defines=%s" % h.path)
    args.add_all(ctx.files.src)

    # Optional features.
    if ctx.attr.graph or ctx.attr.graph_file:
        gf = ctx.actions.declare_file(ctx.attr.graph_file.name
                                      if ctx.attr.graph_file
                                      else "%s.dot" % ctx.label.name)
        outs += [gf]
        args.add("--graph=%s" % gf.path)

    if ctx.attr.report or ctx.attr.report_file:
        rf = ctx.actions.declare_file(ctx.attr.report_file.name
                                      if ctx.attr.report_file
                                      else "%s.output" % ctx.label.name)
        outs += [rf]
        args.add("--verbose")
        args.add("--report=all")
        args.add("--report-file=%s" % rf.path)

    # Do it.
    ctx.actions.run(
        inputs=depset(ctx.files.src + ctx.files.data),
        outputs=outs,
        executable=_PARSER.parse_gen,
        arguments = [args],
    )

    return [DefaultInfo(
        runfiles=ctx.runfiles(files=ctx.files.src + ctx.files.data),
    )]

genyacc = rule(
    doc = "Generate a paser using bison.",

    implementation = _genyacc_impl,
    attrs = {
        "src": attr.label(
            doc="The root source file.",
            allow_single_file=[".y"],
            mandatory=True,
        ),
        "data": attr.label_list(
            doc="Other files needed.",
            allow_files=True,
            default=[],
        ),

        "cc": attr.output(
            doc="The generated C++ source file.",
            mandatory=True,
        ),
        "h": attr.output(
            doc="The generated C++ header file.",
            mandatory=True,
        ),
        "loc": attr.output(
            doc="""The generated location header (if used).
              This can be manipulated in the .y file via `%define api.location.file`.""",
        ),

        "graph": attr.bool(
            doc="Generate a state machine graph. (Depricated, use graph_file.)",
            default=False,
        ),
        "report": attr.bool(
            doc='Generate a "report" (`--verbose --report=all`). (Depricated, use report_file.)',
            default=False,
        ),

        "graph_file": attr.output(
            doc="Generate a state machine graph.",
        ),
        "report_file": attr.output(
            doc='Generate a "report" (`--verbose --report=all`).',
        ),
    },
    toolchains = [":toolchain_type"],
)

## Parser generator Toolchain
ParserGenInfo = provider(
    doc = "Information about how to invoke lexer and parser generators tools.",

    fields = [
        "lex_gen",
        "parse_gen",
    ],
)

def _parser_toolchain_impl(ctx):
    return [platform_common.ToolchainInfo(
        parser_gen_info = ParserGenInfo(
            lex_gen = ctx.attr.lex_gen,
            parse_gen = ctx.attr.parse_gen,
        ),
    )]

parser_toolchain = rule(
    implementation = _parser_toolchain_impl,
    attrs = {
        "lex_gen": attr.string(mandatory=True),
        "parse_gen": attr.string(mandatory=True),
    },
)
