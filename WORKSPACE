workspace(name = "bazel_rules")

load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
load("@bazel_rules//repositories:repositories.bzl", "eigen", "jsoncpp", "libcurl", "libev", "libgnutls", "libhttpserver", "libidn2", "libnettle", "microhttpd", "openssl", "zlib")

git_repository(
    name = "rules_foreign_cc",
    commit = "e1f6efeda355208947efb117219af613f7eef712",  # current as of 2021/06/15
    remote = "git://github.com/bazelbuild/rules_foreign_cc.git",
    shallow_since = "1623777319 -0700",
)

load("@rules_foreign_cc//foreign_cc:repositories.bzl", "rules_foreign_cc_dependencies")

rules_foreign_cc_dependencies([])

#############################################
git_repository(
    name = "com_google_googletest",
    commit = "e2239ee6043f73722e7aa812a459f54a28552929",  # current as of 2021/06/15
    remote = "git://github.com/google/googletest.git",
    shallow_since = "1623433346 -0700",
)

#############################################
git_repository(
    name = "com_google_absl",
    commit = "311bbd2e50ea35e921a08186840d3b6ca279e880",  # current as of 2021/06/15
    remote = "git://github.com/abseil/abseil-cpp.git",
    shallow_since = "1623359638 -0400",
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
