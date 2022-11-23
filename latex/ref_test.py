import argparse
import editdistance  # pip install editdistance
import re
import sys

miss_ref_re = re.compile("[Rr]eference `(.*)' on page [0-9]+ undefined on input line")
dup_ref_re = re.compile("Label `(.*)' multiply defined.")
newlable_re = re.compile('newlabel{([^}]*)}')

def BadRefs(ignore_dups, logfile):
  try:
    log = open(logfile, "r")
  except IOError:
    print("File not found:", logfile)
    return (False, set(), set())

  missing_ref = set()
  dup_ref = set()
  for l in log:
    s = miss_ref_re.search(l)
    if s:
      print(l.strip())
      missing_ref.add(s.group(1))
    if not ignore_dups:
      s = dup_ref_re.search(l)
      if s: dup_ref.add(s.group(1))
  return (True, missing_ref, dup_ref)

def FindLabels(auxfile):
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
  return [
    x
    for _,x in
    sorted((editdistance.eval(t, o), o) for o in labels)
  ]

def main(args):
  fails = 0
  for f in args.argv:
    err, missing_ref, dup_refs = BadRefs(args.ignore_dups, f)

    if not err or not (missing_ref or dup_refs): continue
    fails += 1

    labels = FindLabels(f[:-3] + "aux")

    for t in missing_ref:
      print(t, "-?>", " ".join(BestMatch(t, labels)[:8]), "...")

    for t in dup_refs: print("Duplicate label:", t)

  return fails

if __name__ == "__main__":
  parser = argparse.ArgumentParser()
  parser.add_argument("--ignore_dups",
                      default=False, action="store_true",
                      help="Check for cuplicate labels")
  parser.add_argument("argv", type=str, help="Logs to check", nargs="+")
  args = parser.parse_args()
  exit(main(args))
