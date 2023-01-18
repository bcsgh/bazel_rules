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

"""Bazle/skylark rule(s) to process LaTeX."""

LaTeXInfo = provider(
    doc = "Information about how to invoke LaTeX tools.",

    fields = [
        "pdflatex",
        "detex",
    ],
)

# If nothing else is found, blindly use these hard coded values.
# (They at least work on my machine.)
_last_chance_toolchain = struct(
    latex_toolchain = LaTeXInfo(
        pdflatex = "/usr/bin/pdflatex",
        detex = "/usr/bin/detex",
    )
)

def _tex_to_pdf_impl(ctx):
    _LATEX = ctx.toolchains["@bazel_rules//latex:toolchain_type"] or _last_chance_toolchain
    _LATEX = _LATEX.latex_toolchain

    if ctx.attr.runs < 1:
        fail("At least 1 run requiered.")
    if ctx.attr.reprocess and ctx.attr.runs < 2:
        fail("Reprocess does nothing without mutiple runs.")

    steps = []

    ##### Set up pulling everything into where pdflatex expects it.
    def Munge(f):
        # construct the expected path based on the type of the target, etc.
        path = f.path if f.is_source else f.short_path
        if f.owner.workspace_root: path = path[len(f.owner.workspace_root) + 1:]
        return path

    paths = [(f.path, Munge(f)) for f in ctx.files.data]
    paths = [(f, t) for f, t in paths if f != t]

    pull = ctx.actions.declare_file(ctx.label.name + ".pull.sh")
    steps += [pull]
    ctx.actions.write(output=pull, content="set -e\n%s\n" % "\n".join([
        "mkdir -p $(dirname %s)\ncp %s %s" % (t, f, t) for f, t in paths
    ]))

    ##### Set up the pdflatex command.
    if ctx.attr.jobname:
        jobname = ctx.attr.jobname
        extra = "-jobname=%s " % ctx.attr.jobname
    else:
        jobname = ctx.file.src.basename.replace(".tex", "")
        extra = ""

    cmd = "max_print_line=1000 %s %s%s" % (_LATEX.pdflatex, extra, ctx.file.src.path)

    pdflatex = ctx.actions.declare_file(ctx.label.name + ".pdflatex.sh")
    steps += [pdflatex]
    ctx.actions.write(output=pdflatex, content="set -e\n%s\n" % cmd)

    ##### Set up the reprocess commands.
    rp_steps = []
    for i, r in enumerate(ctx.attr.reprocess):
        reprocess = ctx.expand_location(r, targets=ctx.attr.reprocess_tools)

        rf = ctx.actions.declare_file(ctx.label.name + ".reprocess_%d.sh" % i)
        rp_steps += [rf]
        ctx.actions.write(output=rf, content="set -e\n%s\n" % reprocess)

    ##### Setup generation of outputs.
    if ctx.attr.extra_outs:
        print("WARNING",
              "%s: Use of tex_to_pdf.extra_outs is depricated." % ctx.label,
              "Add outs = ",
              ["%s.%s" % (jobname, o) for o in ctx.attr.extra_outs])

    pdf = ctx.actions.declare_file(ctx.attr.pdf.name)

    outs = [pdf] + [
        ctx.actions.declare_file("%s.%s" % (jobname, o))
        for o in ctx.attr.extra_outs
    ] + [
        ctx.actions.declare_file(o.name)
        for o in ctx.attr.outs
    ]

    ##### Set up pushing everything to where Bazel expects it. (TODO can this use symlinks?)
    copy = ctx.actions.declare_file(ctx.label.name + ".copy.sh")
    steps += [copy]
    cp = ["cp %s %s" % (f.basename, f.path) for f in outs]
    ctx.actions.write(output=copy, content="set -e\n%s\n" % "\n".join(cp))

    # Setup the full run.
    rerun = [r.path for r in rp_steps] + [pdflatex.path]
    script_body = [pdflatex.path] + (rerun * (ctx.attr.runs - 1))

    script = ctx.actions.declare_file(ctx.label.name + ".full.sh")
    ctx.actions.expand_template(
        output=script,
        template = ctx.file._full_template,
        substitutions={
          "{PULL}": pull.path,
          "{BODY}": "\n".join([
              "%s &> LOG" % l
              for l in script_body
          ]),
          "{COPY}": copy.path,
        }
    )

    # Do the full run
    srcs = (ctx.files.src + ctx.files.data + ctx.files.reprocess_tools)
    ctx.actions.run(
        inputs=depset(srcs + steps + rp_steps),
        outputs=outs,
        executable=script,
        arguments = []
    )

    return [DefaultInfo(runfiles=ctx.runfiles(files=srcs))]

tex_to_pdf = rule(
    doc = "Process a .tex file into a .pdf file.",

    implementation = _tex_to_pdf_impl,
    attrs = {
      "src": attr.label(
          doc="The root source file.",
          allow_single_file=[".tex"],
          mandatory=True,
      ),
      "pdf": attr.output(
          doc="The output file name.",
          mandatory=True,
      ),
      "runs": attr.int(
          doc="How many times to run. (Yes, re-running latex mutiple times is still a thing.)",
          default=2,
      ),
      "data": attr.label_list(
          doc="Other input files needed by pdflatex.",
          allow_files=True,
          default=[],
      ),
      "reprocess_tools": attr.label_list(
          doc="Other input files needed by the reprocessing steps.",
          allow_files=True,
          default=[],
      ),
      "extra_outs": attr.string_list( # TODO remove
          doc="DEPRECATED: Aditional filename extention to include in the result set.",
          default=[],
      ),
      "outs": attr.output_list(
          doc="Arbitrary aditional filenames to include in the result set.",
      ),
      "reprocess": attr.string_list(
          doc="Extra shell commands to run between invocation of pdflatex.",
          default=[],
      ),
      "jobname": attr.string(
          doc="The value for \\jobname.",
          default="",
      ),
      "_full_template": attr.label(
          doc="A template for the full processing.",
          allow_single_file=True,
          default="@bazel_rules//latex:full.sh.tpl",
      ),
    },
    toolchains = [
        config_common.toolchain_type(
            "@bazel_rules//latex:toolchain_type",
            mandatory = False,
        ),
    ],
)

def _detex_impl(ctx):
    _LATEX = ctx.toolchains["@bazel_rules//latex:toolchain_type"] or _last_chance_toolchain
    _LATEX = _LATEX.latex_toolchain

    processed_1 = ctx.actions.declare_file(ctx.label.name + ".processed_1")

    sed1_args = ctx.actions.args()
    sed1_args.add(ctx.file.src.path)           # input
    sed1_args.add("-n")                        # No stdout
    sed1_args.add("-f%s" % ctx.file._sed.path) # process
    sed1_args.add("-ew %s" % processed_1.path) # write to output

    ctx.actions.run(
        inputs=depset(ctx.files.src + ctx.files._sed),
        outputs=[processed_1],
        executable="sed",
        arguments = [sed1_args]
    )

    if ctx.file.post_sed:
      processed_2 = ctx.actions.declare_file(ctx.label.name + ".processed_2")
      processed = processed_2

      sed2_args = ctx.actions.args()
      sed2_args.add(processed_1.path)                # input
      sed2_args.add("-n")                            # No stdout
      sed2_args.add("-f%s" % ctx.file.post_sed.path) # process
      sed2_args.add("-ew %s" % processed_2.path)     # write to output

      ctx.actions.run(
          inputs=depset([processed_1, ctx.file.post_sed]),
          outputs=[processed_2],
          executable="sed",
          arguments = [sed2_args]
      )
    else:
      processed = processed_1

    if ctx.attr.out:
      result = ctx.actions.declare_file(ctx.attr.out.name)
    else:
      result = ctx.actions.declare_file("%s.txt" % ctx.label.name)
      print("WARNING",
            "%s: Use of detex() without `out` depricated." % ctx.label,
            'Add out = "%s".' % result.basename)

    ctx.actions.run_shell(
        inputs=depset([processed]),
        outputs=[result],
        command = "%s -l %s >%s"  % (_LATEX.detex, processed.path, result.path)
    )

    return [DefaultInfo(
        runfiles=ctx.runfiles(files=(ctx.files.src + ctx.files.post_sed + ctx.files._sed)),
    )]

detex = rule(
    doc = """Process a .tex file into a text file that approximates the text from the input.

    This can be usefull as a pre-processing step for tests like spell checking.
    Note, the input doesn't need to be a complete tex document.
    """,

    implementation = _detex_impl,
    attrs = {
        "src": attr.label(
            doc="The root source file.",
            allow_single_file=True,
            mandatory=True,
        ),
        "post_sed": attr.label(
            doc="A sed script applied to remove or process custom markup.",
            default=None,
            allow_single_file=True,
            mandatory=False,
        ),
        "_sed": attr.label(
            default="@bazel_rules//latex:detex.sed",
            allow_single_file=True,
        ),
        "out": attr.output(
            doc="The output file name.",
            # TODO mandatory=True,
        ),
    },
    toolchains = [config_common.toolchain_type(
            "@bazel_rules//latex:toolchain_type",
            mandatory = False,
        ),
    ],
)
