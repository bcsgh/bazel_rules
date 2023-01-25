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
  def removesuffix(f, s):
    if f[-len(s):] != s:
        return f
    else:
        return f[:-len(s)]

  try:
    with open(args.json, "r") as jsonfile:
      JSON = json.load(jsonfile)
  except IOError:
    print("File not found:", args.json)
    return 1

  extra = set(JSON["extra"] + [removesuffix(f, ".tex") for f in JSON["extra"]])

  ignore = [re.compile(r) for r in JSON["ignore_re"]]

  mapping = {}

  ESCAPED_BACKSLASH = re.compile("\\\\\\\\")
  ESCAPED_PERCENT = re.compile("\\\\%")
  COMMENT = re.compile("\\\\%")
  INPUTS = re.compile("\\\\input{([^}]*)}")

  err = 0
  # Process in all files.
  for f in [JSON["root"]] + JSON["inputs"]:
    new = set()
    try:
      with open(f, "r") as tf:
        tex = tf.readlines()
    except IOError:
      print("File not found:", f)
      err = 1
      continue

    for l in tex:
      # process to remove comments.
      l = re.sub(ESCAPED_BACKSLASH, " ", l)
      l = re.sub(ESCAPED_PERCENT, " ", l)
      l = re.sub(COMMENT, "", l)

      new.update(
        f.group(1)
        for f in INPUTS.finditer(l)
        if f.group(1) not in extra
          and not [1 for r in ignore if r.fullmatch(f.group(1))]
      )

    assert removesuffix(f, ".tex") not in mapping
    mapping[removesuffix(f, ".tex")] = new

  ##### Check that all files input are expected, and the same the other way:
  found = set(x for y in mapping.values() for x in y)
  expected = set(removesuffix(x, ".tex") for x in JSON["inputs"])

  missing = set()
  if found != expected:
    err = 1
    missing = expected.difference(found)
    for x in missing: print("Missing \\input{%s}" % x)
    for x in found.difference(expected): print("Missing file %s.tex" % x)

  ##### Check that all expected files are reachable from root:
  todo = [removesuffix(JSON["root"], ".tex")]
  seen = set()

  expected.update(todo)

  while todo:
    current, todo = todo[0], todo[1:]
    if current not in seen:
      seen.add(current)
      todo += mapping.get(current, [])

  if seen != expected:
    for x in expected.difference(seen, missing):
      print("%s unreachable from root (%s)" % (x, JSON["root"]))

  ##### Check for cycles:
  # deep copy.
  work = dict((k, v.copy()) for k,v in mapping.items())

  while True:
    leaf = set(k for k,v in work.items() if not v)
    if not leaf: break # util there are no leaf nodes

    for k in leaf: work.pop(k)
    for v in work.values(): v.difference_update(leaf)

  while True: # Prune parents not in a loop.
    parent = set(work.keys()) - set(x for y in work.values() for x in y)
    if not parent: break
    for k in parent: work.pop(k)

  if work:
    err = 1

    print("Found cycle(s) in \\input{}s.")
    print("Files include:\n%s.tex" % ".tex\n".join(work.keys()))

  return err


if __name__ == "__main__":

  parser = argparse.ArgumentParser()
  parser.add_argument("--json", type=str, help="A JSON file with the test case data.")
  args = parser.parse_args()
  exit(main(args))
