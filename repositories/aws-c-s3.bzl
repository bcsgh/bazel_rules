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
                "samples/**",
                "tests/**",
            ],
        ),
        hdrs = [":aws-c-s3"],
        srcs = [":aws-c-s3.c"],
    )

    native.filegroup(
        name = "aws-c-s3.c",
        srcs = native.glob([
            "source/*.c",
            "source/s3_endpoint_resolver/*.c",
        ]),
    )

    native.cc_library(
        name = "aws-c-s3",
        srcs = [":aws-c-s3.c"],
        hdrs = native.glob([
            "include/aws/s3/*.h",
            "include/aws/s3/private/*.h",
        ]),
        includes = ["include"],
        deps = [
            "@com_github_awslabs_aws_c_auth//:aws-c-auth",
            "@com_github_awslabs_aws_checksums//:aws-checksums",
        ],
        visibility = ["//visibility:public"],
    )
