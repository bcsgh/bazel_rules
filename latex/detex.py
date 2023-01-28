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
import re

def main(args):
  with open(args.input, "r") as inp:
    lines = inp.readlines()

  patterns = []
  for j in args.json:
    with open(j, "r") as j:
      JSON = json.load(j)
    patterns += JSON
  patterns = [(re.compile(x["re"]), x["sub"]) for x in patterns]

  again = True
  while again:
    again = 0
    for i in range(len(lines)):
      for p,r in patterns:
        lines[i], n = p.subn(r, lines[i])
        again += n

  with open(args.output, "w") as outp:
    outp.writelines(lines)
  return 0


if __name__ == "__main__":

  parser = argparse.ArgumentParser()
  parser.add_argument("--input", type=str, required=True,
                      help="the file to process.")
  parser.add_argument("--output", type=str, required=True,
                      help="the processed file.")
  parser.add_argument("json", type=str, nargs="*",
                      help="JSON pattern files to use to process the input")
  args = parser.parse_args()
  try:
    exit(main(args))
  except Exception as err:
    raise SystemExit(err)
