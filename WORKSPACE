workspace(name = "bazel_rules")

load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
load("@bazel_rules//repositories:repositories.bzl", "eigen", "jsoncpp", "libcurl", "libev", "libgnutls", "libhttpserver", "libidn2", "libnettle", "microhttpd", "openssl", "zlib")

git_repository(
    name = "rules_foreign_cc",
    commit = "c923238c6dc5a35c233a4acca28d90a0b1816836",  # current as of 2022/10/27
    remote = "https://github.com/bazelbuild/rules_foreign_cc.git",
    shallow_since = "1666910343 +0100",
)

load("@rules_foreign_cc//foreign_cc:repositories.bzl", "rules_foreign_cc_dependencies")

rules_foreign_cc_dependencies([])

#############################################
git_repository(
    name = "rules_python",
    commit = "17a1573ecb960f0ed839fc8581cb015737b6241d",  # current as of 2022/12/31
    remote = "https://github.com/bazelbuild/rules_python.git",
    shallow_since = "1669672701 -0800",
)

load("@rules_python//python:repositories.bzl", "python_register_multi_toolchains")
load("@rules_python//python:versions.bzl", "MINOR_MAPPING")

python_register_multi_toolchains(
    name = "python",
    default_version = MINOR_MAPPING.values()[-1],
    python_versions = MINOR_MAPPING.values(),
)

#############################################
git_repository(
    name = "bazel_skylib",
    commit = "5bfcb1a684550626ce138fe0fe8f5f702b3764c3",
    remote = "https://github.com/bazelbuild/bazel-skylib.git",
    shallow_since = "1668623372 +0100",
)

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

#############################################
git_repository(
    name = "com_google_googletest",
    commit = "3026483ae575e2de942db5e760cf95e973308dd5",  # current as of 2022/10/25
    remote = "https://github.com/google/googletest.git",
    shallow_since = "1666712359 -0700",
)

#############################################
git_repository(
    name = "com_googlesource_code_re2",
    commit = "7a65faf439295e941baa6640a717d89c1f13e9cd",  # current as of 2022/10/27
    remote = "https://github.com/google/re2.git",
    shallow_since = "1666860568 +0000",
)

#############################################
git_repository(
    name = "com_google_absl",
    commit = "827940038258b35a29279d8c65b4b4ca0a676f8d",  # current as of 2022/10/27
    remote = "https://github.com/abseil/abseil-cpp.git",
    shallow_since = "1666903548 -0700",
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
