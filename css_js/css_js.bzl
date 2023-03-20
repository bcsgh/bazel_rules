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

"""
Bazle/skylark rule(s) to process class names in closure_css_binary()
rules into JS constants.

This consume a closure_css_binary() rule, that include CSS_BINARY_MUNGE_DEFS
in its defs argument, and generates a closure_js_library() rule with constants
that are the renamings of the CSS classes.

NOTE: this is *incompatable* with goog.getCssName().

It trades off some of what goog.getCssName() provides for the
ability to get compile time checking of css class names.

"""

load("@io_bazel_rules_closure//closure:defs.bzl", "closure_js_binary", "closure_js_library")

def _gen_css_class_names_js_impl(ctx):
    out = ctx.actions.declare_file(ctx.outputs.out.basename)

    css_binary = ctx.attr.css_binary[struct]

    args = ctx.actions.args()
    args.add("--json=%s" % css_binary.renaming_map.path)
    args.add("--out=%s" % out.path)
    args.add("--module=%s" % ctx.attr.module)
    if ctx.attr.prefix: args.add("--prefix=%s" % ctx.attr.prefix)

    ctx.actions.run(
        inputs=[css_binary.renaming_map],
        outputs=[out],
        executable=ctx.file._tool,
        arguments = [args]
    )

    return []  ## default outputs are correct

gen_css_class_names_js = rule(
    doc = "Process class names in closure_css_binary rules into JS constants.",

    implementation = _gen_css_class_names_js_impl,
    attrs = {
        "css_binary": attr.label(
            doc="The closure_css_binary() target to process.",
            mandatory=True,
        ),
        "out": attr.output(
            doc="The generated file name.",
            mandatory=True,
        ),
        "module": attr.string(
            doc="The goog module name to provide.",
            mandatory=True,
        ),
        "prefix": attr.string(
            doc="The value (if any) of --css-renaming-prefix provided to the rule passed to css_binary.",
        ),
        "_tool": attr.label(
            allow_single_file=True,
            default=":css_munge",
        ),
    },
)

CSS_BINARY_MUNGE_DEFS = ["--output-renaming-map-format=JSON"]

def css_class_names_js(name, **argv):
    gen = "_%s_jssrc" % name

    gen_css_class_names_js(
        name = gen,
        out = "%s.js" % name,
        **argv,
    )

    closure_js_library(
        name = name,
        srcs = [gen],
    )
