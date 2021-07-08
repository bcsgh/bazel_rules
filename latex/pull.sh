for f in $* ;
do
  if [[ $f = bazel-* ]] ;
  then
    T=${f#bazel-*/*/*/}
    mkdir -p $(dirname $T)
    cp $f $T
  fi
done
