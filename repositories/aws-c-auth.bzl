load("@bazel_rules//repositories:compare_cc_deps_test.bzl", "compare_cc_deps_test")

def BUILD():
    compare_cc_deps_test(
        name = "sources_test",
        glob = native.glob(
            [
                "**/*.%s" % (e)
                for e in ["c", "cpp", "h"]
            ],
            exclude = ["tests/**"],
        ),
        hdrs = [":aws-c-auth"],
        srcs = [":aws-c-auth.c"],
    )

    native.filegroup(
        name = "aws-c-auth.c",
        srcs = native.glob(["source/*.c"]),
    )

    native.cc_library(
        name = "aws-c-auth",
        srcs = ["aws-c-auth.c"],
        hdrs = native.glob([
            "include/aws/auth/*.h",
            "include/aws/auth/private/*.h",
        ]),
        includes = ["include"],
        deps = [
            "@com_github_awslabs_aws_c_http//:aws-c-http",
            "@com_github_awslabs_aws_c_io//:aws-c-io",
            "@com_github_awslabs_aws_c_sdkutils//:aws-c-sdkutils",
        ],
        visibility = ["//visibility:public"],
    )
