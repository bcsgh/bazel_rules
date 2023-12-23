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
                "cn_tool/main.c",
                "android/**/*.c",
                "CCRegression/**",
            ],
        ),
        hdrs = [":common_crypto"],
        srcs = [":common_crypto.c"],
    )

    native.filegroup(
        name = "common_crypto.c",
        srcs = native.glob(
            [
                "lib/*.c",
                "libcn/*.c",
                "lib/*.h",
                "libcn/*.h",
            ],
            exclude = [
                "android/**",
                "CCRegression/**",
            ],
        ),
    )

    selects.config_setting_group(
        name = "apple",
        match_any = ["@platforms//os:osx", "@platforms//os:ios"],
    )

    native.cc_library(
        name = "common_crypto",
        target_compatible_with = [":apple"],  ## TODO get this working!
        srcs = [":common_crypto.c"],
        hdrs = native.glob(["include/*.h"]),
        strip_include_prefix = "include",
        include_prefix = "CommonCrypto",
        deps = [
            ":common_crypto_h1",
            ":common_crypto_h2",
            ":common_crypto_h3",
        ],
        visibility = ["//visibility:public"],
    )

    native.cc_library(
        name = "common_crypto_h1",
        hdrs = native.glob(["android/include/**/*.h"]),
        includes = ["android/include"],
    )

    native.cc_library(
        name = "common_crypto_h2",
        hdrs = native.glob(["include/Private/*.h"]),
        strip_include_prefix = "include/Private",
        include_prefix = "CommonCrypto",
    )

    native.cc_library(
        name = "common_crypto_h3",
        hdrs = [
            "include/Private/CommonBaseXX.h",
            "include/Private/CommonCRC.h",
            "include/Private/CommonNumerics.h",
        ],
        strip_include_prefix = "include/Private",
        include_prefix = "CommonNumerics",
    )
