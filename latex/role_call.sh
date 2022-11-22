shopt -s nullglob

ROOT=$1
shift 1

EXIT=0

for f in $*;
do
  if ! grep -xqe '\\input{'${f%\.tex}'}.*' $ROOT $* ;
  then
    echo Missing \\input\{${f%.tex}\}
    EXIT=1
  fi
done

for f in $(sed -n $ROOT $* -e 's/^\\input{\([^}]*\)}.*$/\1.tex/p');
do
  # Look for the file in several places in case it's generated or an external.
  # See also @bazel_rules//latex:pull.sh
  # (The exact name must be checked last.)
  found=({bazel-*/*/*/,external/*/,}$f) 
  if [[ ! -f ${found[0]} ]];
  then
    echo Missing file ${found[@]}
    EXIT=1
  fi
done

exit $EXIT
