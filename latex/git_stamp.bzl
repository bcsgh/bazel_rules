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

def git_stamp(name = None):
  """Generate a .tex file defining the command \\GitCommit to give the current git commit hash.

  Note: for this to work the build must be built using the equivlent of the flag:
    --workspace_status_command=.git_hooks/bazel_stamp.sh

  - Copy .git_hooks/bazel_stamp.sh from this repo into your workspace
  - copy the --workspace_status_command= line from this repo's .bazelrc into yours.
  """
  if not name:
      print("git_stamp.name should be explicitly set;\n" +
            '    name = "git_stamp",\n'+
            "This will be reqiered at some point.")

  native.genrule(
      name = name or "git_stamp",
      srcs = ["@bazel_rules//latex:git_stamp.tpl"],
      outs = ["%s.tex" % name],
      cmd = " ; ".join([
          "COMMIT=$$(sed -n bazel-out/stable-status.txt -e '/STABLE_GIT_COMMIT/s/^[^ ]* //p')",
          "sed -e s/COMMIT/$$COMMIT/ $(location @bazel_rules//latex:git_stamp.tpl) > $@",
      ]),
      stamp = True,
      visibility = ["//visibility:public"],
  )
