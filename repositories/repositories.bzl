"""
Misc. imported libs.
"""

load("@bazel_tools//tools/build_defs/repo:git.bzl", "new_git_repository")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

#############################################
def eigen():
    new_git_repository(
        name = "eigen",
        commit = "8f8c2ba2fe19c6c2e47bbe2fbaf87594642e523d",  # current as of 2021/11/01
        remote = "https://gitlab.com/libeigen/eigen.git",
        build_file = "@bazel_rules//repositories:BUILD.eigen",
        shallow_since = "1635786281 +0000",
    )

#############################################
def libcurl():
    new_git_repository(
        name = "com_github_curl_curl",
        commit = "a06ce29482e422e623acbc84d4e72b4f9ac99904",  # current as of 2021/11/01
        remote = "https://github.com/curl/curl.git",
        build_file = "@bazel_rules//repositories:BUILD.libcurl",
        shallow_since = "1635803917 +0100",
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
        commit = "fa747b1ae34338e764ede2d104803eae5af0a4a0",  # current as of 2021/11/01
        remote = "https://github.com/open-source-parsers/jsoncpp.git",
        build_file = "@bazel_rules//repositories:BUILD.jsoncpp",
        shallow_since = "1635446333 -0500",
    )

#############################################
def libgnutls():
    new_git_repository(
        name = "com_gitlab_gnutls",
        commit = "fe9d2be0d251bc7a3e1fd7d7b59e1dbf23bae8a1",  # current as of 2021/11/01
        remote = "https://gitlab.com/gnutls/gnutls.git",
        recursive_init_submodules = True,
        build_file = "@bazel_rules//repositories:BUILD.gnutls",
        shallow_since = "1635607727 +0000",
    )

#############################################
def libhttpserver():
    new_git_repository(
        name = "com_github_etr_libhttpserver",
        build_file = "@bazel_rules//repositories:BUILD.libhttpserver",
        commit = "c5cf5eaa89830ad2aa706a161a647705661bd671",  # current as of 2021/06/09
        remote = "https://github.com/etr/libhttpserver.git",
        shallow_since = "1623266851 -0700",
    )

#############################################
def libnettle():
    new_git_repository(
        name = "se_liu_lysator_nettle_nettle",
        commit = "5bce126f229b8130aa530520acb5a700a8f7d689",  # current as of 2021/11/01
        remote = "https://git.lysator.liu.se/nettle/nettle.git",
        recursive_init_submodules = True,
        build_file = "@bazel_rules//repositories:BUILD.nettle",
        shallow_since = "1635665719 +0000",
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
        commit = "d60e719c2d158a2998412d45c52df25375e10b74",  # current as of 2021/07/01
        remote = "https://github.com/openssl/openssl.git",
        #recursive_init_submodules = True,
        build_file = "@bazel_rules//repositories:BUILD.openssl",
        shallow_since = "1625148253 +0200",
    )
