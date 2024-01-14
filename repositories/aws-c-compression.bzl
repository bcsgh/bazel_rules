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
                "source/huffman_generator/generator.c", # includes a main()
            ],
        ),
        hdrs = [":aws-c-compression"],
        srcs = [":aws-c-compression.c"],
    )

    native.filegroup(
        name = "aws-c-compression.c",
        srcs = native.glob([
            "source/*.c",
        ]),
    )

    native.cc_library(
        name = "aws-c-compression",
        srcs = [":aws-c-compression.c"],
        hdrs = native.glob([
            "include/aws/compression/*.h",
            "include/aws/compression/private/*.h",
        ]),
        includes = ["include"],
        deps = [
            "@com_github_awslabs_aws_c_common//:aws-c-common",
        ],
        visibility = ["//visibility:public"],
    )
