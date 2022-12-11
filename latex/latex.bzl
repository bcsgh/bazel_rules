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

def tex_to_pdf(name = None, src = None, pdf = None, runs = 2, data = [], extra_outs = [],
               outs = [], reprocess = [], jobname = None, visibility = None):
    """Process a .tex file into a .pdf file.

    Args:
      name: The target name.
      src: The root source file
      pdf: The output file name.
      runs: How many times to run.
        (Yes, re-running latex mutiple times is still a thing.)
      data: Other files needed.
      extra_outs: Aditional filename extention to include in the result set.
      outs: Arbitrary aditional filenames to include in the result set.
      reprocess: Extra shell commands to run between invocation of pdflatex.
      jobname: The value for \\jobname.
    """
    if not name:
        fail("name must be provided")
    if not src:
        fail("src must be provided")
    if not pdf:
        fail("pdf must be provided")
    if reprocess and runs < 2:
        fail("reprocessdoes nothing without mutiple runs")

    args = []
    if jobname:
      args += ["-jobname=%s" % jobname]
    else:
      jobname = src.replace(".tex", "")

    extra_outs = ["%s.%s" % (jobname, o) for o in extra_outs] + outs

    pull = ["$(locations %s)" % s for s in data]
    pull = "$(location @bazel_rules//latex:pull.sh) %s" % " ".join(pull)

    cmd = "(max_print_line=1000 /usr/bin/pdflatex %s $(location %s) &>./%s.LOG)" % (" ".join(args), src, name)
    if reprocess: cmd += "".join([" && (%s)" % r for r in reprocess])
    cp = ["cp %s.pdf $(location :%s)" % (jobname, pdf)]
    cp += ["cp %s $(location :%s)" % (t, t) for t in extra_outs]
    native.genrule(
        name = name,
        outs = [pdf] + extra_outs,
        srcs = [src, "@bazel_rules//latex:pull.sh"] + data,
        cmd = "(%s) && ( %s ) || (cat ./%s.LOG ; false) && %s" % (
            pull,
            " && ".join([cmd] * runs),
            name,
            " && ".join(cp),
        ),
        visibility = visibility,
    )

def detex(name = None, src = None, post_sed = None, visibility = None):
    """Process a .tex file into a text file that approximates the text from the input.

    This can be usefull as a pre-processing step for tests like spell checking.
    Note, the input doesn't need to be a complete tex document.

    Args:
      name: The target name.
      src: The root source file
      post_sed: A sed script applied to remove or process custom markup.
    """

    if not name: fail("name must be provided")
    if not src: fail("src must be provided")

    sed = "@bazel_rules//latex:detex.sed"

    pipe = ["sed $(location %s) -f $(location %s)" % (src, sed)]

    if post_sed:
      pipe += ["sed -f $(location %s)" % post_sed]
      post_seds = [post_sed]
    else:
      post_seds = []

    pipe += ["detex -l >$@"]

    native.genrule(
        name = name,
        srcs = [
            src,
            sed,
        ] + post_seds,
        cmd = "set -o pipefail ; " + " | ".join(pipe),
        outs = [name + ".txt"],
        visibility = visibility,
    )
