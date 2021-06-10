"""
Misc. imported libs.
"""

load("@bazel_tools//tools/build_defs/repo:git.bzl", "new_git_repository")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

#############################################
def eigen():
    new_git_repository(
        name = "eigen",
        build_file = "@bazel_rules//repositories:BUILD.eigen",
        commit = "9b51dc7972c9f64727e9c8e8db0c60aaf9aae532",  # current as of 2021/02/17
        remote = "https://gitlab.com/libeigen/eigen.git",
        shallow_since = "1613584163 +0000",
    )

#############################################
def libcurl():
    new_git_repository(
        name = "com_github_curl_curl",
        commit = "23eef2394cb810294a669d4bb4862bbdb2f5ced6",  # current as of 2021/06/10
        remote = "git://github.com/curl/curl.git",
        build_file = "@bazel_rules//repositories:BUILD.libcurl",
        shallow_since = "1623334393 +0200",
    )

#############################################
def libidn2():
    new_git_repository(
        name = "com_gitlab_libidn_libidn2",
        commit = "807b5dfef35a1aad0e0ebc5360af0accff1325ab",  # current as of 2021/06/10
        remote = "https://gitlab.com/libidn/libidn2.git",
        recursive_init_submodules = True,
        build_file = "@bazel_rules//repositories:BUILD.libidn2",
        shallow_since = "1621340058 +0200",
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
        commit = "375a1119f8bbbf42e5275f31b281b5d87f2e17f2",  # current as of 2021/06/10
        remote = "git://github.com/open-source-parsers/jsoncpp.git",
        build_file = "@bazel_rules//repositories:BUILD.jsoncpp",
        shallow_since = "1620266582 -0500",
    )

#############################################
def libgnutls():
    new_git_repository(
        name = "com_gitlab_gnutls",
        commit = "1b83d881938b4e37d2bb6475ade716b22364b6cb",  # current as of 2021/06/10
        remote = "https://gitlab.com/gnutls/gnutls.git",
        recursive_init_submodules = True,
        patch_cmds = [
            "rm devel/libtasn1/gtk-doc.make",  # broken symlink in some builds.
        ],
        build_file = '@bazel_rules//repositories:BUILD.gnutls',
        shallow_since = '1622274106 +0000',
    )

#############################################
def libhttpserver():
    new_git_repository(
        name = "com_github_etr_libhttpserver",
        build_file = "@bazel_rules//repositories:BUILD.libhttpserver",
        commit = "c5cf5eaa89830ad2aa706a161a647705661bd671",  # current as of 2021/06/09
        remote = "git://github.com/etr/libhttpserver.git",
        shallow_since = "1623266851 -0700",
    )

#############################################
def libnettle():
    new_git_repository(
        name = "se_liu_lysator_nettle_nettle",
        commit = "a46a17e9f57c64984d5246aa3475e45f8c562ec7",  # current as of 2021/06/10
        remote = "https://git.lysator.liu.se/nettle/nettle.git",
        recursive_init_submodules = True,
        build_file = "@bazel_rules//repositories:BUILD.nettle",
        shallow_since = "1621875492 +0200",
    )

#############################################
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
        commit = "7afef721ff93018a66f8e2e6b9e1ce3d48321bdf",  # current as of 2021/06/10
        remote = "https://github.com/openssl/openssl.git",
        shallow_since = "1623340794 +0200",
        #recursive_init_submodules = True,
        build_file = "@bazel_rules//repositories:BUILD.openssl",
    )
