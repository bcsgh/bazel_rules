load("@bazel_tools//tools/build_defs/repo:git.bzl", "new_git_repository")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

#############################################
def libcurl():
    new_git_repository(
        name = "com_github_curl_curl",
        build_file = "@bazel_rules//repositories:BUILD.libcurl",
        commit = "781864bedbc57e2e2532bde7cf64db9af7b80d05",
        shallow_since = "1620211916 +0200",
        remote = "git://github.com/curl/curl.git",
    )

#############################################
def libidn2():
    new_git_repository(
        name = "com_gitlab_libidn_libidn2",
        build_file = "@bazel_rules//repositories:BUILD.libidn2",
        recursive_init_submodules = True,
        commit = "b8b4a90c04f84971b64bc2a2935c95543937f26a",
        shallow_since = "1617128657 +0200",
        remote = "https://gitlab.com/libidn/libidn2.git",
    )

#############################################
def zlib():
    http_archive(
        name = "zlib",
        build_file = "@bazel_rules//repositories:BUILD.zlib",
        sha256 = "c3e5e9fdd5004dcb542feda5ee4f0ff0744628baf8ed2dd5d66f8ca1197cb1a1",
        strip_prefix = "zlib-1.2.11",
        urls = [
            "https://mirror.bazel.build/zlib.net/zlib-1.2.11.tar.gz",
            "https://zlib.net/zlib-1.2.11.tar.gz",
        ],
    )

#############################################
def jsoncpp():
    new_git_repository(
        name = "com_github_open_source_parsers_jsoncpp",
        commit = "fda274ddd297a53110d43189c2d69fee8f748da9",  # current as of 2021/02/17
        shallow_since = "1612932637 -0500",
        remote = "git://github.com/open-source-parsers/jsoncpp.git",
        build_file = "@bazel_rules//repositories:BUILD.jsoncpp",
    )

#############################################
def libgnutls():
    new_git_repository(
        name = "com_gitlab_gnutls",
        remote = "https://gitlab.com/gnutls/gnutls.git",
        commit = "5dd9a55040da54371807471bf3169d7a9a1f527e",
        shallow_since = "1599201540 +0200",
        recursive_init_submodules = True,
        build_file = "@bazel_rules//repositories:BUILD.gnutls",
        patch_cmds = [
            "rm devel/libtasn1/gtk-doc.make",  # broken symlink in some builds.
        ],
    )

#############################################
def libnettle():
    new_git_repository(
        name = "se_liu_lysator_nettle_nettle",
        remote = "https://git.lysator.liu.se/nettle/nettle.git",
        commit = "8247fa21f0f2a7d1b2ff0fbbe61cb058e5edffbe",
        shallow_since = "1618305807 +0200",
        recursive_init_submodules = True,
        build_file = "@bazel_rules//repositories:BUILD.nettle",
    )

def libev():
    new_git_repository(
        name = "com_github_enki_libev",
        remote = "git://github.com/enki/libev.git",
        commit = "93823e6ca699df195a6c7b8bfa6006ec40ee0003",
        shallow_since = "1463172876 -0700",
        build_file = "@bazel_rules//repositories:BUILD.libev",
        patch_cmds = [
            "chmod 755 autogen.sh",
        ],
    )
