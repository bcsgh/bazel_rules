workspace(name = "bazel_rules")

load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository", "new_git_repository")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

git_repository(
    name = "rules_foreign_cc",
    commit = "d54c78ab86b40770ee19f0949db9d74a831ab9f0",  # current as of 2020/11/28
    shallow_since = "1603722361 +0100",
    remote = "git://github.com/bazelbuild/rules_foreign_cc.git",
)

load("@rules_foreign_cc//:workspace_definitions.bzl", "rules_foreign_cc_dependencies")
rules_foreign_cc_dependencies([])

#############################################
git_repository(
    name = "com_google_googletest",
    commit = "b1fbd33c06cdb0024c67733c6fdec2009d17b384",  # current as of 2020/11/28
    shallow_since = "1606207587 -0500",
    remote = "git://github.com/google/googletest.git",
)

#############################################
git_repository(
    name = "com_google_absl",
    commit = "5d8fc9192245f0ea67094af57399d7931d6bd53f",  # current as of 2020/11/28
    shallow_since = "1606203805 -0500",
    remote = "git://github.com/abseil/abseil-cpp.git",
)

#############################################
new_git_repository(
    name = "com_github_etr_libhttpserver",
    build_file = "@bazel_rules//http:BUILD.libhttpserver",
    commit = "7cb4eb8454ab936fcf2c54a61cc4d71a65f14680",  # current as of 2020/11/28
    shallow_since = "1605998057 -0800",
    remote = "git://github.com/etr/libhttpserver.git",
    #tag = "v0.11.1",  # old
)

#############################################
DOMAINS = [
    # GNU mirrors
    "ftp.wayne.edu",
    "mirrors.tripadvisor.com",
    "mirrors.kernel.org",
    "mirror.clarkson.edu",
    "mirrors.syringanetworks.net",
    "mirror.us-midwest-1.nexcess.net",
    "mirrors.ocf.berkeley.edu",
    # primary
    "ftp.gnu.org",
]

http_archive(
    name = "org_gnu_microhttpd",
    build_file = "@bazel_rules//http:BUILD.microhttpd",
    sha256 = "90d0a3d396f96f9bc41eb0f7e8187796049285fabef82604acd4879590977307",
    strip_prefix = "libmicrohttpd-0.9.70",
    urls = ["https://%s/gnu/libmicrohttpd/libmicrohttpd-0.9.70.tar.gz" % domain for domain in DOMAINS],
)
