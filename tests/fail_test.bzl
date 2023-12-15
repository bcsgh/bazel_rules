# Switch to using //fail_test/...

load("//fail_test:fail_test.bzl", _dep="get_deps", _test="fail_test")
get_deps = _dep
fail_test = _test
