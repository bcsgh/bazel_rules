load("@bazel_rules//repositories:compare_cc_deps_test.bzl", "compare_cc_deps_test")
load("@bazel_skylib//lib:selects.bzl", "selects")

def BUILD():
    compare_cc_deps_test(
        name = "sources_test",
        glob = native.glob(
            [
                "**/*.%s" % (e)
                for e in ["c", "cpp", "h"]
            ],
            exclude = [
                "bin/**",
                "tests/**",
            ],
        ),
        hdrs = [":aws-c-cal"],
        srcs = [
            ":aws-c-cal.c",
            ########
            "aws-c-cal-crypto-darwin.c",
            "aws-c-cal-crypto-unix.c",
            "aws-c-cal-crypto-windows.c",
        ],
    )

    ############################################################################
    CRYPTO_DARWIN_C =  ["source/darwin/**/*.c"]
    CRYPTO_UNIX_C =    ["source/unix/**/*.c"]
    CRYPTO_WINDOWS_C = ["source/windows/**/*.c"]
    native.filegroup(
        name = "aws-c-cal-crypto-darwin.c",
        srcs = native.glob(CRYPTO_DARWIN_C),
    )
    native.filegroup(
        name = "aws-c-cal-crypto-windows.c",
        srcs = native.glob(CRYPTO_WINDOWS_C),
    )
    native.filegroup(
        name = "aws-c-cal-crypto-unix.c",
        srcs = native.glob(CRYPTO_UNIX_C),
    )
    native.alias(
        name = "aws-c-cal-crypto.c",
        actual = selects.with_or({
            ("@platforms//os:osx", "@platforms//os:ios"):
                ":aws-c-cal-crypto-darwin.c",
            ("@platforms//os:linux", "@platforms//os:netbsd", "@platforms//os:openbsd"):
                ":aws-c-cal-crypto-unix.c",
            "@platforms//os:windows":
                ":aws-c-cal-crypto-windows.c",
        }),
    )
    native.cc_library(
        name = "aws-c-cal-crypto",
        deps = selects.with_or({
            ("@platforms//os:osx", "@platforms//os:ios"): [
                "@com_github_apple_oss_common_crypto//:common_crypto",
            ],
            ("@platforms//os:linux", "@platforms//os:netbsd", "@platforms//os:openbsd"): [
                "@com_github_openssl_openssl//:openssl",
            ],
            "@platforms//os:windows": [":bcrypt-not-implemented"],
        }),
    )

    ############################################################################
    native.filegroup(
        name = "aws-c-cal.c",
        srcs = native.glob(
            [
                "source/*.c",
                "source/darwin/common_cryptor_spi.h",  ## ???
            ],
            exclude = CRYPTO_DARWIN_C + CRYPTO_UNIX_C + CRYPTO_WINDOWS_C,
        ),
    )

    native.cc_library(
        name = "aws-c-cal",
        srcs = [
            ":aws-c-cal.c",
            ":aws-c-cal-crypto.c",
        ],
        hdrs = native.glob([
            "include/aws/cal/*.h",
            "include/aws/cal/private/*.h",
        ]),
        includes = ["include"],
        deps = [
            "@com_github_awslabs_aws_c_common//:aws-c-common",
            ":aws-c-cal-crypto",
        ],
        visibility = ["//visibility:public"],
    )
