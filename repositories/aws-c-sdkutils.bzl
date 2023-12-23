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
                "tests/**",
            ],
        ),
        hdrs = [":aws-c-sdkutils"],
        srcs = [":aws-c-sdkutils.c"],
    )

    native.filegroup(
        name = "aws-c-sdkutils.c",
        srcs = native.glob([
            "source/*.c",
        ])
    )

    native.cc_library(
        name = "aws-c-sdkutils",
        srcs = ["aws-c-sdkutils.c"],
        hdrs = native.glob([
            "include/aws/sdkutils/*.h",
            "include/aws/sdkutils/private/*.h",
        ]),
        includes = [
            "include",
        ],
        deps = [
            "@com_github_awslabs_aws_c_common//:aws-c-common",
        ],
        visibility = ["//visibility:public"],
    )
