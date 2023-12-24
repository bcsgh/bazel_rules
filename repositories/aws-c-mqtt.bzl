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
        hdrs = [":aws-c-mqtt"],
        srcs = [":aws-c-mqtt.c"],
    )

    native.filegroup(
        name = "aws-c-mqtt.c",
        srcs = native.glob([
            "source/*.c",
            "source/v5/*.c",
        ]),
    )

    native.cc_library(
        name = "aws-c-mqtt",
        srcs = ["aws-c-mqtt.c"],
        hdrs = native.glob([
            "include/aws/mqtt/*.h",
            "include/aws/mqtt/private/*.h",
            "include/aws/mqtt/v5/*.h",
            "include/aws/mqtt/private/v5/*.h",
        ]),
        includes = ["include"],
        deps = [
            "@com_github_awslabs_aws_c_common//:aws-c-common",
            "@com_github_awslabs_aws_c_http//:aws-c-http",
            "@com_github_awslabs_aws_c_io//:aws-c-io",
        ],
        visibility = ["//visibility:public"],
    )
