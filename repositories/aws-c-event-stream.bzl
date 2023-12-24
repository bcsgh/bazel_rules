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
                "tests/**",
            ],
        ),
        hdrs = [":aws-c-event-stream"],
        srcs = [":aws-c-event-stream.c"],
    )

    native.filegroup(
        name = "aws-c-event-stream.c",
        srcs = native.glob(["source/*.c"]),
    )

    native.cc_library(
        name = "aws-c-event-stream",
        srcs = ["aws-c-event-stream.c"],
        hdrs = native.glob([
            "include/aws/event-stream/*.h",
            "include/aws/event-stream/private/*.h",
        ]),
        includes = ["include"],
        deps = [
            "@com_github_awslabs_aws_c_common//:aws-c-common",
            "@com_github_awslabs_aws_c_io//:aws-c-io",
            "@com_github_awslabs_aws_checksums//:aws-checksums",
        ],
        visibility = ["//visibility:public"],
    )
