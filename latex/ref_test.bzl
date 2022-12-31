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

"""Bazle/skylark rule(s) to test LaTeX builds."""

def latex_ref_test(name = "ref_test", jobname = None, ignore_dups = False,
                   externs = []):
    """Test for missing label references.

    Args:
      name: The target name.
      jobname: The assumed basename for the .log and .aux files to read in.
      ignore_dups: Suppress check for duplicate labels.
      externs: Lables to ignore missing refernces to.
    """
    if not jobname: fail("jobname is requred")

    args = []
    if ignore_dups: args += ["--ignore_dups"]

    args += ["--extern=%s" %i for i in externs]


    native.py_test(
        name = name,
        srcs = ["@bazel_rules//latex:ref_test.py"],
        main = "@bazel_rules//latex:ref_test.py",
        args = args + ["$(location :%s.log)" % jobname],
        data = [
            ":%s.aux" % jobname,
            ":%s.log" % jobname,
        ],
    )
