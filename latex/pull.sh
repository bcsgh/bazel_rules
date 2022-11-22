for f in $* ;
do
  case $f in
    # Local generated.
    bazel-*/*/*/*)
      T=${f#bazel-*/*/*/}
      mkdir -p $(dirname $T)
      cp $f $T
      #echo >&2 @@@@ $f @@@@ $T
      ;;

    # External generated?

    # External static.
    external/*/*)
      T=${f#external/*/}
      mkdir -p $(dirname $T)
      cp $f $T
      #echo >&2 @@@@ $f @@@@ $T
      ;;

    #*) echo >&2 @@@@ $f @@@@ $f ;;
  esac
done
