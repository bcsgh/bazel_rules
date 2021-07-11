"""
Misc. imported libs.
"""

load("@bazel_tools//tools/build_defs/repo:git.bzl", "new_git_repository")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

#############################################
def eigen():
    new_git_repository(
        name = "eigen",
        commit = "9312a5bf5cd72f45558f402077b0c95683ee0fea",  # current as of 2021/07/01
        remote = "https://gitlab.com/libeigen/eigen.git",
        build_file = "@bazel_rules//repositories:BUILD.eigen",
        shallow_since = "1625182272 +0000",
    )

#############################################
def libcurl():
    new_git_repository(
        name = "com_github_curl_curl",
        commit = "a37fc62e8bf90bf09d2556003235a4a11b5acf4e",  # current as of 2021/07/01
        remote = "git://github.com/curl/curl.git",
        build_file = "@bazel_rules//repositories:BUILD.libcurl",
        shallow_since = "1625142432 +0200",
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
        commit = "65bb1b1c1d8019dc72279c12bb74df92925dfd5e",  # current as of 2021/07/01
        remote = "git://github.com/open-source-parsers/jsoncpp.git",
        build_file = "@bazel_rules//repositories:BUILD.jsoncpp",
        shallow_since = "1624471424 -0700",
    )

#############################################
def libgnutls():
    new_git_repository(
        name = "com_gitlab_gnutls",
        commit = "c70941cea73cb38e0d27395e63aafca12dac9a72",  # current as of 2021/07/01
        remote = "https://gitlab.com/gnutls/gnutls.git",
        recursive_init_submodules = True,
        patch_cmds = [
            "rm devel/libtasn1/gtk-doc.make",  # broken symlink in some builds.
        ],
        build_file = "@bazel_rules//repositories:BUILD.gnutls",
        shallow_since = "1624864051 +0000",
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
        commit = "20fedc0155a8cd08ed81179ac72d5bdc187bf3d0",  # current as of 2021/07/01
        remote = "https://git.lysator.liu.se/nettle/nettle.git",
        recursive_init_submodules = True,
        build_file = "@bazel_rules//repositories:BUILD.nettle",
        shallow_since = "1623180848 +0200",
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
