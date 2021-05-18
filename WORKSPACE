workspace(name = "bazel_rules")

load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
load("@bazel_rules//repositories:repositories.bzl", "jsoncpp", "libcurl", "libev", "libgnutls", "libhttpserver", "libidn2", "libnettle", "microhttpd", "openssl", "zlib")

git_repository(
    name = "rules_foreign_cc",
    commit = "b136e6c52da63da300b0f588c8a214d97b0d15cd",  # current as of 2021/05/06
    remote = "git://github.com/bazelbuild/rules_foreign_cc.git",
    shallow_since = "1620262045 -0700",
)

load("@rules_foreign_cc//foreign_cc:repositories.bzl", "rules_foreign_cc_dependencies")

rules_foreign_cc_dependencies([])

#############################################
git_repository(
    name = "com_google_googletest",
    commit = "609281088cfefc76f9d0ce82e1ff6c30cc3591e5",  # current as of 2021/02/17
    remote = "git://github.com/google/googletest.git",
    shallow_since = "1613065794 -0500",
)

#############################################
git_repository(
    name = "com_google_absl",
    commit = "143a27800eb35f4568b9be51647726281916aac9",  # current as of 2021/02/17
    remote = "git://github.com/abseil/abseil-cpp.git",
    shallow_since = "1613186346 -0500",
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
