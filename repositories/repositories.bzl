"""
Misc. imported libs.
"""

load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository", "new_git_repository")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

#############################################
def eigen():
    new_git_repository(
        name = "eigen",
        commit = "c5b896c5a3eb35ed0c08a9be5e6f10cc0a465b81",  # current as of 2022/10/27
        remote = "https://gitlab.com/libeigen/eigen.git",
        build_file = "@bazel_rules//repositories:BUILD.eigen",
        shallow_since = "1666902815 +0000",
    )

#############################################
def libcurl():
    new_git_repository(
        name = "com_github_curl_curl",
        commit = "a3063fe0147e00381d149e1d3a3c57c63343e7fc",  # current as of 2022/10/27
        remote = "https://github.com/curl/curl.git",
        build_file = "@bazel_rules//repositories:BUILD.libcurl",
        shallow_since = "1666906547 +0200",
    )

#############################################
def libidn2():
    new_git_repository(
        name = "com_gitlab_libidn_libidn2",
        commit = "9ab0a0d651c692aee964b8d5dbed89a56669742b",  # current as of 2022/10/25
        remote = "https://gitlab.com/libidn/libidn2.git",
        recursive_init_submodules = True,
        build_file = "@bazel_rules//repositories:BUILD.libidn2",
        shallow_since = "1666599166 +0200",
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
        commit = "8190e061bc2d95da37479a638aa2c9e483e58ec6",  # current as of 2022/10/25
        remote = "https://github.com/open-source-parsers/jsoncpp.git",
        build_file = "@bazel_rules//repositories:BUILD.jsoncpp",
        shallow_since = "1657835857 -0400",
    )

#############################################
def libgnutls():  # WARNING: stuck here. Updateing seems to break too many things.
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
        commit = "8c21c4045c745b4d13b299269fef56d552be741d",  # current as of 2023/04/12
        remote = "https://github.com/etr/libhttpserver.git",
        shallow_since = "1681359603 -0700",
    )

#############################################
def libnettle():
    new_git_repository(
        name = "se_liu_lysator_nettle_nettle",
        commit = "a19abef9c8cdaece67a418e35a23663925ef6b03",  # current as of 2022/10/25
        remote = "https://git.lysator.liu.se/nettle/nettle.git",
        recursive_init_submodules = True,
        build_file = "@bazel_rules//repositories:BUILD.nettle",
        shallow_since = "1666292871 +0000",
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
        commit = "d8eb0e1988aba5d86aa6570357853cad0ab3f532",  # current as of 2022/10/27
        remote = "https://github.com/openssl/openssl.git",
        #recursive_init_submodules = True,
        build_file = "@bazel_rules//repositories:BUILD.openssl",
        shallow_since = "1666888769 +0200",
    )

#############################################
def load_skylib():
    maybe(
        git_repository,
        name = "bazel_skylib",
        commit = "5bfcb1a684550626ce138fe0fe8f5f702b3764c3",  # current as of 2023/01/02
        remote = "https://github.com/bazelbuild/bazel-skylib.git",
        shallow_since = "1668623372 +0100",
    )

#############################################
def load_absl():
    maybe(
        git_repository,
        name = "com_google_absl",
        commit = "827940038258b35a29279d8c65b4b4ca0a676f8d",  # current as of 2022/10/27
        remote = "https://github.com/abseil/abseil-cpp.git",
        shallow_since = "1666903548 -0700",
    )
