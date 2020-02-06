workspace(name = "bazel_rules")

load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository", "new_git_repository")

#############################################
git_repository(
    name = "com_google_googletest",
    remote = "git://github.com/google/googletest.git",
    tag = "release-1.10.0",  # current as of 2020/1/25
)

#############################################
git_repository(
    name = "com_google_absl",
    commit = "44427702614d7b86b064ba06a390f5eb2f85dbf6",  # current as of 2020/1/25
    remote = "git://github.com/abseil/abseil-cpp.git",
)

#############################################
new_git_repository(
    name = "com_github_etr_libhttpserver",
    build_file = "@bazel_rules//http:BUILD.libhttpserver",
    commit = "e0fd7a27568caf82fad9cbe2e4dd3ce7a7532fc0",  # current as of 2020/02/03
    remote = "git://github.com/etr/libhttpserver.git",
    #tag = "v0.11.1",  # old
)

#############################################
new_local_repository(
    name = "org_gnu_microhttpd",
    build_file = "@bazel_rules//http:BUILD.microhttpd",
    path = "/home/bcs/Documents/git_work/libmicrohttpd",
)
