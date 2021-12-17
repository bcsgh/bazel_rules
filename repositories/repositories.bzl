"""
Misc. imported libs.
"""

load("@bazel_tools//tools/build_defs/repo:git.bzl", "new_git_repository")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

#############################################
def eigen():
    new_git_repository(
        name = "eigen",
        commit = "d0b4b75fbbe5f99254e031cbfe204c3e2bb7c83f",  # current as of 2021/12/17
        remote = "https://gitlab.com/libeigen/eigen.git",
        build_file = "@bazel_rules//repositories:BUILD.eigen",
        shallow_since = "1639686047 +0000",
    )

#############################################
def libcurl():
    new_git_repository(
        name = "com_github_curl_curl",
        commit = "ed0bc61e31a90d284b2686df1d48fd697e3ebbc4",  # current as of 2021/12/17
        remote = "https://github.com/curl/curl.git",
        build_file = "@bazel_rules//repositories:BUILD.libcurl",
        shallow_since = "1639729029 +0100",
    )

#############################################
def libidn2():
    new_git_repository(
        name = "com_gitlab_libidn_libidn2",
        commit = "49fe79c77f6013356920b46bd07f95bcb609f541",  # current as of 2021/11/01
        remote = "https://gitlab.com/libidn/libidn2.git",
        recursive_init_submodules = True,
        build_file = "@bazel_rules//repositories:BUILD.libidn2",
        shallow_since = "1632651379 +0200",
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
        commit = "a1f1613bdd81bf28289e8d3fbeb4eb78b82fb203",  # current as of 2021/12/17
        remote = "https://github.com/open-source-parsers/jsoncpp.git",
        build_file = "@bazel_rules//repositories:BUILD.jsoncpp",
        shallow_since = "1639533887 -0800",
    )

#############################################
def libgnutls():
    new_git_repository(
        name = "com_gitlab_gnutls",
        commit = "18cf560c5518771f3d909a2a32c2c84d8cff1d9a",  # current as of 2021/12/17
        remote = "https://gitlab.com/gnutls/gnutls.git",
        recursive_init_submodules = True,
        build_file = "@bazel_rules//repositories:BUILD.gnutls",
        shallow_since = "1639757659 +0000",
    )

#############################################
def libhttpserver():
    new_git_repository(
        name = "com_github_etr_libhttpserver",
        build_file = "@bazel_rules//repositories:BUILD.libhttpserver",
        commit = "6718e0a634f4570ac24b9b91063555ca9774a1c6",  # current as of 2021/12/17
        remote = "https://github.com/etr/libhttpserver.git",
        shallow_since = "1639347380 -0800",
    )

#############################################
def libnettle():
    new_git_repository(
        name = "se_liu_lysator_nettle_nettle",
        commit = "dd65a63e7453750506144e5caeb6e159165e1bc2",  # current as of 2021/12/17
        remote = "https://git.lysator.liu.se/nettle/nettle.git",
        recursive_init_submodules = True,
        build_file = "@bazel_rules//repositories:BUILD.nettle",
        shallow_since = "1639081884 +0100",
    )

#############################################
def libev():
    new_git_repository(
        name = "com_github_enki_libev",
        remote = "https://github.com/enki/libev.git",
        commit = "93823e6ca699df195a6c7b8bfa6006ec40ee0003",
        shallow_since = "1463172876 -0700",
        build_file = "@bazel_rules//repositories:BUILD.libev",
        patch_cmds = [
            "chmod 755 autogen.sh",
            'sed -ie "s/\\bpod2man.*/true/" Makefile.*',  # This isn't needed and doesn't build.
        ],
    )

#############################################
def microhttpd():
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
        sha256 = "e8f445e85faf727b89e9f9590daea4473ae00ead38b237cf1eda55172b89b182",
        strip_prefix = "libmicrohttpd-0.9.71",
        urls = ["https://%s/gnu/libmicrohttpd/libmicrohttpd-0.9.71.tar.gz" % domain for domain in DOMAINS],
    )

#############################################
def openssl():
    new_git_repository(
        name = "com_github_openssl_openssl",
        commit = "7ca3bf792a4a085e6f2426ad51a41fca4d0b1b8c",  # current as of 2021/12/17
        remote = "https://github.com/openssl/openssl.git",
        #recursive_init_submodules = True,
        build_file = "@bazel_rules//repositories:BUILD.openssl",
        shallow_since = "1639760376 +0100",
    )
