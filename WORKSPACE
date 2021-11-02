workspace(name = "bazel_rules")

load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
load("@bazel_rules//repositories:repositories.bzl", "eigen", "jsoncpp", "libcurl", "libev", "libgnutls", "libhttpserver", "libidn2", "libnettle", "microhttpd", "openssl", "zlib")

git_repository(
    name = "rules_foreign_cc",
    commit = "e97f24e701cc33c0e4aa360d59b83eca0aa46111",  # current as of 2021/11/01
    remote = "https://github.com/bazelbuild/rules_foreign_cc.git",
    shallow_since = "1634660901 +0000",
)

load("@rules_foreign_cc//foreign_cc:repositories.bzl", "rules_foreign_cc_dependencies")

rules_foreign_cc_dependencies([])

#############################################
git_repository(
    name = "com_google_googletest",
    commit = "16f637fbf4ffc3f7a01fa4eceb7906634565242f",  # current as of 2021/11/01
    remote = "https://github.com/google/googletest.git",
    shallow_since = "1634142500 -0400",
)

#############################################
git_repository(
    name = "com_google_absl",
    commit = "022527c50e0e2bc937f9fa3c516e3e36cbba0845",  # current as of 2021/11/01
    remote = "https://github.com/abseil/abseil-cpp.git",
    shallow_since = "1635537114 -0400",
)

#############################################
eigen()

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
