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
    args = [ctx.file.file.short_path]
    runs = [ctx.file.file]

    # Must we merge/prep a dictionary?
    if ctx.attr.dict:
      # Merge everything with some filtering.
      udict = ctx.actions.declare_file(ctx.label.name + ".working.dict")

      dict_args = ctx.actions.args()
      dict_args.add("-vpath=%s" % udict.path)
      dict_args.add('BEGIN{print ""> path}!/ /{gsub(/[0-9]/,"");print > path}')
      dict_args.add_all(ctx.files.dict)

      ctx.actions.run(
          inputs=ctx.files.dict,
          outputs=[udict],
          executable="awk",
          arguments = [dict_args]
      )

      # Sort it.
      sdict = ctx.actions.declare_file(ctx.label.name + ".sorted.dict")

      sort_args = ctx.actions.args()
      sort_args.add(udict.path)
      sort_args.add("--output=" + sdict.path)

      ctx.actions.run(
          inputs=[udict],
          outputs=[sdict],
          executable="sort",
          arguments = [sort_args]
      )

      # Use that generated dictionary.
      args += ["--dictionary=" + sdict.short_path]
      runs += [sdict]

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
    },
)
