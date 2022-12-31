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

import argparse
import re
import sys

def EditDistance(a, b):
  if len(a) > len(b): return EditDistance(b, a)

  d = list(range(0, len(a)+1))

  for i,c in enumerate(b):
    D = [i+1] * (len(d))

    for j in range(1, len(d)):
      rem = D[j-1] + 1
      add = d[j  ] + 1
      rep = d[j-1] + (0 if a[j-1] == b[i] else 1)
      D[j] = min(rem, add, rep)

    d = D

  return d[-1]

miss_ref_re = re.compile("[Rr]eference `(.*)' on page [0-9]+ undefined on input line")
dup_ref_re = re.compile("Label `(.*)' multiply defined.")
newlable_re = re.compile('newlabel{([^}]*)}')

def BadRefs(ignore_dups, logfile, ignore):
  """Search a LaTeX log fille for instereing messages."""
  try:
    log = open(logfile, "r")
  except IOError:
    print("File not found:", logfile)
    return (False, set(), set())

  missing_ref = set()
  dup_ref = set()
  for l in log:

    # Check for and collect reports of missing lables.
    s = miss_ref_re.search(l)
    if s and s.group(1) not in ignore:
      print(l.strip())
      missing_ref.add(s.group(1))

    # If not suppressed, check for and collect reports of duplicate lables.
    if not ignore_dups:
      s = dup_ref_re.search(l)
      if s: dup_ref.add(s.group(1))

  return (True, missing_ref, dup_ref)

def FindLabels(auxfile):
  """Search a LaTeX aux file for know lables."""
  try:
    aux = open(auxfile, "r")
  except IOError:
    print("No aux found:", auxfile)
    return set()

  labels = set()
  for l in aux:
    m = newlable_re.search(l)
    if m: labels.add(m.group(1))

  return labels

def BestMatch(t, labels):
  """Find the best matches for t from labels."""
  return [
    x
    for _,x in
    sorted((EditDistance(t, o), o) for o in labels)
  ]

def main(args):
  ignore = set(args.extern or [])

  err, missing_ref, dup_refs = BadRefs(args.ignore_dups, args.log, ignore)

  if not err or not (missing_ref or dup_refs): return 0

  labels = FindLabels(args.aux)

  for t in missing_ref:
    print(t, "-?>", " ".join(BestMatch(t, labels)[:8]), "...")

  for t in dup_refs: print("Duplicate label:", t)

  return 1


if __name__ == "__main__":

  parser = argparse.ArgumentParser()
  parser.add_argument("--ignore_dups",
                      default=False, action="store_true",
                      help="Suppress check for duplicate labels.")
  parser.add_argument("--extern",
                      action='append',
                      help="Lables to ignore missing refernces to.")
  parser.add_argument("--aux", type=str, help="The .aux file from a TeX/LaTeX build.")
  parser.add_argument("--log", type=str, help="The .aux file from a TeX/LaTeX build.")
  args = parser.parse_args()
  exit(main(args))
