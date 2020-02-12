workspace(name = "bazel_rules")

load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository", "new_git_repository")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

git_repository(
    name = "rules_foreign_cc",
    commit = "ed3db61a55c13da311d875460938c42ee8bbc2a5",  # current as of 2020/02/03
    remote = "git://github.com/bazelbuild/rules_foreign_cc.git",
)

load("@rules_foreign_cc//:workspace_definitions.bzl", "rules_foreign_cc_dependencies")
rules_foreign_cc_dependencies([])

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
