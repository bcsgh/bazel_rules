workspace(name = "bazel_rules")

load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
load("@bazel_rules//repositories:repositories.bzl", "eigen", "jsoncpp", "libcurl", "libev", "libgnutls", "libhttpserver", "libidn2", "libnettle", "microhttpd", "openssl", "zlib")

git_repository(
    name = "rules_foreign_cc",
    commit = "6d1d16d3bb1c09a5154b483de902755ce1f05746",  # current as of 2021/07/01
    remote = "git://github.com/bazelbuild/rules_foreign_cc.git",
    shallow_since = "1625108995 -0700",
)

load("@rules_foreign_cc//foreign_cc:repositories.bzl", "rules_foreign_cc_dependencies")

rules_foreign_cc_dependencies([])

#############################################
git_repository(
    name = "com_google_googletest",
    commit = "4ec4cd23f486bf70efcc5d2caa40f24368f752e3",  # current as of 2021/07/01
    remote = "git://github.com/google/googletest.git",
    shallow_since = "1625074437 -0400",
)

#############################################
git_repository(
    name = "com_google_absl",
    commit = "9a7e447c511dae7276ab65fde4d04f6ed52b39c9",  # current as of 2021/07/01
    remote = "git://github.com/abseil/abseil-cpp.git",
    shallow_since = "1624810227 -0400",
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
