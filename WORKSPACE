workspace(name = "bazel_rules")

load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository", "new_git_repository")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_rules//repositories:repositories.bzl", "jsoncpp", "libcurl", "libev", "libgnutls", "libidn2", "libnettle", "zlib")

git_repository(
    name = "rules_foreign_cc",
    commit = "b136e6c52da63da300b0f588c8a214d97b0d15cd",  # current as of 2021/05/06
    shallow_since = "1620262045 -0700",
    remote = "git://github.com/bazelbuild/rules_foreign_cc.git",
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
new_git_repository(
    name = "com_github_etr_libhttpserver",
    build_file = "@bazel_rules//repositories:BUILD.libhttpserver",
    commit = "ec973dc883b0d33f81c7f69b66dd5770ba14e695",  # current as of 2021/02/17
    remote = "git://github.com/etr/libhttpserver.git",
    shallow_since = "1607724471 -0800",
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
    build_file = "@bazel_rules//repositories:BUILD.microhttpd",
    sha256 = "90d0a3d396f96f9bc41eb0f7e8187796049285fabef82604acd4879590977307",
    strip_prefix = "libmicrohttpd-0.9.70",
    urls = ["https://%s/gnu/libmicrohttpd/libmicrohttpd-0.9.70.tar.gz" % domain for domain in DOMAINS],
)

jsoncpp()
libcurl()
libev()
libgnutls()
libidn2()
libnettle()
zlib()
