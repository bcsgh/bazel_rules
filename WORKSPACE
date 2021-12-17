workspace(name = "bazel_rules")

load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
load("@bazel_rules//repositories:repositories.bzl", "eigen", "jsoncpp", "libcurl", "libev", "libgnutls", "libhttpserver", "libidn2", "libnettle", "microhttpd", "openssl", "zlib")

git_repository(
    name = "rules_foreign_cc",
    commit = "f76d9281bd7ae1f36179740ba20db3d58cd3b7a3",  # current as of 2021/12/17
    remote = "https://github.com/bazelbuild/rules_foreign_cc.git",
    shallow_since = "1639486112 +0000",
)

load("@rules_foreign_cc//foreign_cc:repositories.bzl", "rules_foreign_cc_dependencies")

rules_foreign_cc_dependencies([])

#############################################
git_repository(
    name = "com_google_googletest",
    commit = "97a467571a0f615a4d96e79e4399c43221ca1232",  # current as of 2021/12/17
    remote = "https://github.com/google/googletest.git",
    shallow_since = "1639586168 -0800",
)

#############################################
git_repository(
    name = "com_google_absl",
    commit = "52d41a9ec23e39db7e2cbce5c9449506cf2d3a5c",  # current as of 2021/12/17
    remote = "https://github.com/abseil/abseil-cpp.git",
    shallow_since = "1639580175 -0500",
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
