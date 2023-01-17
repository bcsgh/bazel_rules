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

def _spell_test_impl(ctx):
    _PYTHON = ctx.toolchains["@bazel_tools//tools/python:toolchain_type"].py3_runtime

    args = [ctx.file.file.short_path]
    runs = [ctx.file.file]

    # Must we merge/prep a dictionary?
    if ctx.attr.dict:
      # Merge everything with some filtering and sort.
      gen_dict = ctx.actions.declare_file(ctx.label.name + ".generated.dict")

      dict_args = ctx.actions.args()
      dict_args.add(ctx.file._tool.path)
      dict_args.add("--output=" + gen_dict.path)
      dict_args.add_all(ctx.files.dict)

      ctx.actions.run(
          inputs=_PYTHON.files.to_list() + ctx.files.dict + [
              _PYTHON.interpreter,
              ctx.file._tool,
          ],
          outputs=[gen_dict],
          executable=_PYTHON.interpreter.path,
          arguments = [dict_args]
      )

      # Use that generated dictionary.
      args += ["--dictionary=" + gen_dict.short_path]
      runs += [gen_dict]

    executable = ctx.actions.declare_file(ctx.label.name + ".sh")

    log = ctx.label.name + ".log"
    ctx.actions.write(
        output=executable,
        content="\n".join([
            "spell %s &> %s" % (" ".join(args), log),
            "cat >&2 %s" % (log),   # Noop on success
            "[ ! -s %s ]" % (log),  # Must be last
        ]),
    )

    return [DefaultInfo(
        executable=executable,
        runfiles=ctx.runfiles(files=runs),
    )]

spell_test = rule(
    doc = """Spell check a text file.

    NOTE: this requiers that 'spell' be installed on the build system:

    sudo apt install spell  # or the equivlent.
    """,

    implementation = _spell_test_impl,
    test = True,
    attrs = {
        "file": attr.label(
            doc="The file to spell check.",
            allow_single_file=True,
            mandatory=True,
        ),
        "dict": attr.label_list(
            doc="A list of supplemental dictionaries to merge and use.",
            default=[],
            allow_files=True,
            mandatory=False,
        ),
        "_tool": attr.label(
            doc="The test script.",
            allow_single_file=True,
            default="@bazel_rules//text:prep_dict.py",
        ),
    },
    toolchains = ["@bazel_tools//tools/python:toolchain_type"],
)
