"""
Misc. imported libs.
"""

load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

OOL_BUILD = """
load("{BZL}", "BUILD")
BUILD()
"""

def BUILD(name):
    """
    Any change to git_repository.build_file forces a refetch of the git repo.
    By moving the body of the build into a .bzl file this can be avoided.
    """
    return OOL_BUILD.format(BZL=Label(":%s.bzl" % name))


GNU_DOMAINS = [
    # GNU mirrors
    "ftp.wayne.edu",
    "mirrors.tripadvisor.com",
    "mirrors.kernel.org",
    "mirror.us-midwest-1.nexcess.net",
    "mirrors.ocf.berkeley.edu",
    "mirror.downloadvn.com",
    "mirror.koddos.net",
    "ftp.fau.de",
    "mirror.csclub.uwaterloo.ca",
    # primary
    "ftp.gnu.org",
]
#############################################
def eigen(commit=None):
    git_repository(  # TODO: stuck here. Updateing seems to break something.
        name = "eigen",
        commit = commit or "c5b896c5a3eb35ed0c08a9be5e6f10cc0a465b81",  # current as of 2022/10/27
        remote = "https://gitlab.com/libeigen/eigen.git",
        build_file = "@bazel_rules//repositories:BUILD.eigen",
        shallow_since = "1666902815 +0000",
    )

#############################################
def libcurl(commit=None):  # WARNING: stuck here. Updateing seems to break too many things.
    git_repository(
        name = "com_github_curl_curl",
        commit = commit or "a3063fe0147e00381d149e1d3a3c57c63343e7fc",  # current as of 2023/11/16
        remote = "https://github.com/curl/curl.git",
        build_file = "@bazel_rules//repositories:BUILD.libcurl",
        shallow_since = "1666906547 +0200",
    )

#############################################
def libidn2(ver=None, sha256=None):
    ver = ver or "2.3.4"   # current as of 2022/10/23
    sha256 = sha256 or "93caba72b4e051d1f8d4f5a076ab63c99b77faee019b72b9783b267986dbb45f"

    # See also: https://gitlab.com/libidn/libidn2
    http_archive(
        name = "com_gitlab_libidn_libidn2",
        build_file = "@bazel_rules//repositories:BUILD.libidn2",
        canonical_id = ver,  # cache by default keys on sha256?
        sha256 = sha256,
        strip_prefix = "libidn2-%s" % ver,
        urls = [
            "https://%s/pub/gnu/libidn/libidn2-%s.tar.gz" % (domain, ver)
            for domain in GNU_DOMAINS
        ],
    )

#############################################
def libasn1(ver=None, sha256=None):
    ver = ver or "4.19.0"   # current as of 2022/08/23
    sha256 = sha256 or "1613f0ac1cf484d6ec0ce3b8c06d56263cc7242f1c23b30d82d23de345a63f7a"

    # See also: https://gitlab.com/gnutls/libtasn1/
    http_archive(
        name = "com_gitlab_gnutls_libtasn1",
        build_file = "@bazel_rules//repositories:BUILD.libtasn1",
        canonical_id = ver,  # cache by default keys on sha256?
        sha256 = sha256,
        strip_prefix = "libtasn1-%s" % ver,
        urls = [
            "https://%s/gnu/libtasn1/libtasn1-%s.tar.gz" % (domain, ver)
            for domain in GNU_DOMAINS
        ],
    )

def libp11(ver=None, sha256=None):
    ver = ver or "0.24.1"   # current as of 2022/01/17
    sha256 = sha256 or "d8be783efd5cd4ae534cee4132338e3f40f182c3205d23b200094ec85faaaef8"

    # See also: https://p11-glue.github.io/p11-glue//p11-kit.html
    http_archive(
        name = "com_github_p11glue_p11kit",
        build_file = "@bazel_rules//repositories:BUILD.p11kit",
        canonical_id = ver,  # cache by default keys on sha256?
        sha256 = sha256,
        strip_prefix = "p11-kit-%s" % ver,
        urls = [
            "https://github.com/p11-glue/p11-kit/releases/download/%s/p11-kit-%s.tar.xz" % (ver, ver)
        ],
    )

def libgmp(ver=None, sha256=None):
    ver = ver or "6.2.1"   # current as of 2020/11/14
    sha256 = sha256 or "eae9326beb4158c386e39a356818031bd28f3124cf915f8c5b1dc4c7a36b4d7c"

    # See also: https://gmplib.org/devel/repo-usage
    http_archive(
        name = "org_gmplib_gmp",
        build_file = "@bazel_rules//repositories:BUILD.libgmp",
        canonical_id = ver,  # cache by default keys on sha256?
        sha256 = sha256,
        strip_prefix = "gmp-%s" % ver,
        urls = [
            "https://%s/gnu/gmp/gmp-%s.tar.bz2" % (domain, ver)
            for domain in GNU_DOMAINS + ["gmplib.org"]
        ] + [
            "https://%s/download/gmp/gmp-%s.tar.bz2" % (domain, ver)
            for domain in ["gmplib.org"]
        ],
    )

#############################################
def zlib(ver=None, sha256=None):
    ver = ver or "1.2.13"   # current as of 2022/10/12
    sha256 = sha256 or "b3a24de97a8fdbc835b9833169501030b8977031bcb54b3b3ac13740f846ab30"
    DOMAINS = [
        "https://mirror.bazel.build/zlib.net/zlib-%s.tar.gz",
        "https://github.com/madler/zlib/archive/refs/tags/v%s.tar.gz",
        "https://zlib.net/zlib-%s.tar.gz",
    ]

    http_archive(
        name = "zlib",
        build_file = "@bazel_rules//repositories:BUILD.zlib",
        canonical_id = ver,  # cache by default keys on sha256?
        sha256 = sha256,
        strip_prefix = "zlib-%s" % ver,
        urls = [domain % ver for domain in DOMAINS],
    )

#############################################
def jsoncpp(commit=None):
    git_repository(
        name = "com_github_open_source_parsers_jsoncpp",
        commit = commit or "69098a18b9af0c47549d9a271c054d13ca92b006",  # current as of 2023/11/12
        remote = "https://github.com/open-source-parsers/jsoncpp.git",
        build_file = "@bazel_rules//repositories:BUILD.jsoncpp",
        shallow_since = "1687876958 -0400",
    )

#############################################
def libgnutls(commit=None):  # WARNING: stuck here. Updateing seems to break too many things.
    git_repository(
        name = "com_gitlab_gnutls",
        commit = commit or "f2fbef2c50952270eeeadebfacbf718da845fadc",  # current as of 2023/11/12
        remote = "https://gitlab.com/gnutls/gnutls.git",
        recursive_init_submodules = True,
        build_file_content = BUILD("gnutls"),
        shallow_since = "1699278575 +0000",
    )

#############################################
def libhttpserver(commit=None):
    git_repository(
        name = "com_github_etr_libhttpserver",
        build_file = "@bazel_rules//repositories:BUILD.libhttpserver",
        commit = commit or "d249ba682441dbb979146482aff01a7073ed165a",  # current as of 2023/11/12
        remote = "https://github.com/etr/libhttpserver.git",
        shallow_since = "1688166248 -0700",
    )

#############################################
def libnettle(commit=None):
    git_repository(
        name = "se_liu_lysator_nettle_nettle",
        commit = commit or "9b1ad3e554f1dda3b65d017b1f79debddff8e712",  # current as of 2023/11/12
        remote = "https://git.lysator.liu.se/nettle/nettle.git",
        recursive_init_submodules = True,
        build_file_content = BUILD("nettle"),
        shallow_since = "1699793977 +0100",
    )

#############################################
def libev(commit=None):
    git_repository(
        name = "com_github_enki_libev",
        remote = "https://github.com/enki/libev.git",
        commit = commit or "93823e6ca699df195a6c7b8bfa6006ec40ee0003",
        shallow_since = "1463172876 -0700",
        build_file = "@bazel_rules//repositories:BUILD.libev",
        patch_cmds = [
            "chmod 755 autogen.sh",
            'sed -ie "s/\\bpod2man.*/true/" Makefile.*',  # This isn't needed and doesn't build.
        ],
    )

#############################################
def microhttpd(ver=None, sha256=None):
    ver = ver or "0.9.71"
    sha256 = sha256 or "e8f445e85faf727b89e9f9590daea4473ae00ead38b237cf1eda55172b89b182"

    http_archive(
        name = "org_gnu_microhttpd",
        build_file = "@bazel_rules//repositories:BUILD.microhttpd",
        canonical_id = ver,  # cache by default keys on sha256?
        sha256 = sha256,
        strip_prefix = "libmicrohttpd-%s" % ver,
        urls = [
            "https://%s/gnu/libmicrohttpd/libmicrohttpd-%s.tar.gz" % (domain, ver)
            for domain in GNU_DOMAINS
        ],
    )

#############################################
def openssl(commit=None):  # WARNING: stuck here. Updateing seems to break too many things.
    git_repository(
        name = "com_github_openssl_openssl",
        commit = commit or "d8eb0e1988aba5d86aa6570357853cad0ab3f532",  # current as of 2023/11/16
        remote = "https://github.com/openssl/openssl.git",
        #recursive_init_submodules = True,
        build_file_content = BUILD("openssl"),
        shallow_since = "1666888769 +0200",
    )

#############################################
def load_skylib(commit=None):
    maybe(
        git_repository,
        name = "bazel_skylib",
        commit = commit or "9c9beee7411744869300f67a98d42f5081e62ab3",  # current as of 2023/11/12
        remote = "https://github.com/bazelbuild/bazel-skylib.git",
        shallow_since = "1699201005 -0500",
    )

#############################################
def load_absl(commit=None):
    maybe(
        git_repository,
        name = "com_google_absl",
        commit = commit or "483a2d59e649179ea9d9bc4d808f6c9d16646f9d",  # current as of 2023/11/12
        remote = "https://github.com/abseil/abseil-cpp.git",
        shallow_since = "1699496241 -0800",
    )

#############################################
def load_rules_cc(commit=None):
    maybe(
        git_repository,
        name = "rules_cc",
        commit = commit or "2f8c04c04462ab83c545ab14c0da68c3b4c96191",  # current as of 2022/06/22
        remote = "https://github.com/bazelbuild/rules_cc.git",
        shallow_since = "1655902949 -0700",
    )

#############################################
def aws_sdk_cpp(**args):
    git_repository(
        name = "com_github_awslabs_aws_c_common",
        remote = "https://github.com/awslabs/aws-c-common.git",
        commit = args.get(
            "com_github_awslabs_aws_c_common",
            "80f21b3cac5ac51c6b8a62c7d2a5ef58a75195ee",
        ),
        shallow_since = "1700172990 -0800",
        build_file_content = BUILD("aws-c-common"),
    )
