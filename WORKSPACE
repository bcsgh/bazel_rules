workspace(name = "bazel_rules")

load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
load("@bazel_rules//repositories:repositories.bzl", "jsoncpp", "libcurl", "libev", "libgnutls", "libhttpserver", "libidn2", "libnettle", "microhttpd", "openssl", "zlib")

git_repository(
    name = "rules_foreign_cc",
    commit = "2407938f22aaf09e5705e726037cf61e2003b291",  # current as of 2021/06/10
    remote = "git://github.com/bazelbuild/rules_foreign_cc.git",
    shallow_since = "1623082150 -0700",
)

load("@rules_foreign_cc//foreign_cc:repositories.bzl", "rules_foreign_cc_dependencies")

rules_foreign_cc_dependencies([])

#############################################
git_repository(
    name = "com_google_googletest",
    commit = "aa533abfd4232b01f9e57041d70114d5a77e6de0",  # current as of 2021/06/10
    remote = "git://github.com/google/googletest.git",
    shallow_since = "1623242719 -0400",
)

#############################################
git_repository(
    name = "com_google_absl",
    commit = "8f92175783c9685045c50f227e7c10f1cddb4d58",  # current as of 2021/06/10
    remote = "git://github.com/abseil/abseil-cpp.git",
    shallow_since = "1623281200 -0400",
)

#############################################
jsoncpp()

libcurl()

libev()

libgnutls()

libhttpserver()

libidn2()

libnettle()

microhttpd()

openssl()

zlib()
