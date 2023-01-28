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

import argparse
import json
import os
import os.path
import shutil
import subprocess
import sys

def Pull(pull):
  print("PULL: <-\n  " + "\n  ".join(str(x) for x in pull.items()), file=debug)
  for d,s in pull.items():
    os.makedirs(os.path.dirname(d), exist_ok=True)
    shutil.copy(s, d)

def Run(runs, pdflatex, reprocess, env={}):
  if env:
    e = dict(os.environ)
    e.update(env)
    env = e

  def Try(cmd, tag, env):
    print("RUN:", tag, [cmd], file=debug)
    task = subprocess.run(
        cmd,
        shell=True,
        env=env,
        stdin=subprocess.DEVNULL,
        stderr=subprocess.STDOUT,
        stdout=subprocess.PIPE,
    )


    if task.returncode != 0:
      raise Exception("%s: %s\n----\n%s\n----" % (
          tag, cmd, task.stdout.decode('utf-8')))

  Try(pdflatex, "pdflatex 1", env)

  for i in range(2, runs+1):
    for r in reprocess:
      Try(r, "reprocess %d" % i, None)
    Try(pdflatex, "pdflatex %d" % i, env)

def Push(push):
  print("PUSH: ->\n  " + "\n  ".join(str(x) for x in push.items()), file=debug)
  for s,d in push.items(): shutil.copy(s, d)

def main(args):
  try:
    with open(args.json, "r") as jsonfile:
      JSON = json.load(jsonfile)
  except IOError:
    print("File not found:", args.json)
    return 1

  # pdflatex seems to assume some tools are in $PWD?
  for t in ["makeindex"]:
    at = shutil.which(t)
    if at: os.symlink(at, t)

  Pull(JSON["pull"])

  Run(JSON["runs"], JSON["pdflatex"], JSON["reprocess"], JSON["env"])

  Push(JSON["push"])

  return 0


if __name__ == "__main__":

  parser = argparse.ArgumentParser()
  parser.add_argument("--json", type=str, help="The JSON config blob.")
  parser.add_argument("--debug",
      default=False, action='store_true',
      help="Output more about ehat's going on.")
  args = parser.parse_args()
  try:
    if args.debug:
      debug = sys.stdout
    else:
      debug = open(os.devnull, "w")

    exit(main(args))
  except Exception as err:
    raise SystemExit(err)
