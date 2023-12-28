load("@bazel_rules//repositories:compare_cc_deps_test.bzl", "compare_cc_deps_test")

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
                "docs/**",
                "tests/**",
                "codebuild/bin/s2n_dynamic_load_test.c",
            ],
        ),
        hdrs = [":s2n-tls"],
        srcs = [":s2n-tls.c"],
    )

    native.filegroup(
        name = "s2n-tls.c",
        srcs = native.glob([
            "crypto/*.c",
            "error/*.c",
            "stuffer/*.c",
            "tls/*.c",
            "tls/extensions/*.c",
            "utils/*.c",
        ]),
    )

    native.cc_library(
        name = "s2n-tls",
        srcs = [":s2n-tls.c"],
        hdrs = native.glob([
            "api/*.h",
            "api/unstable/*.h",
            "crypto/*.h",
            "error/*.h",
            "stuffer/*.h",
            "tls/*.h",
            "tls/extensions/*.h",
            "utils/*.h",
        ]),
        copts = ["-Wno-deprecated-declarations"],
        linkopts = ["-lpthread"],
        includes = ["api"],
        deps = [
            "@com_github_openssl_openssl//:openssl",
        ],
        visibility = ["//visibility:public"],
    )
