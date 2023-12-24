load("@bazel_rules//repositories:compare_cc_deps_test.bzl", "compare_cc_deps_test")

def BUILD():
    compare_cc_deps_test(
        name = "sources_test",
        glob = native.glob(
            [
                "**/*.%s" % (e)
                for e in ["c", "cpp", "h", "def"]
            ],
            exclude = [
                "bin/**",
                "tests/**",
            ],
        ),
        hdrs = [
            ":aws-c-http",
            ":aws-c-http-defs",
        ],
        srcs = [":aws-c-http.c"],
    )

    native.cc_library(
        # Only used internaly.
        name = "aws-c-http-defs",
        hdrs = native.glob(["include/aws/http/private/*.def"]),
    )

    native.filegroup(
        name = "aws-c-http.c",
        srcs = native.glob(["source/*.c"]),
    )

    native.cc_library(
        name = "aws-c-http",
        srcs = [":aws-c-http.c"],
        hdrs = native.glob([
            "include/aws/http/*.h",
            "include/aws/http/private/*.h",
        ]),
        includes = ["include"],
        implementation_deps = [":aws-c-http-defs"],
        deps = [
            "@com_github_awslabs_aws_c_common//:aws-c-common",
            "@com_github_awslabs_aws_c_compression//:aws-c-compression",
            "@com_github_awslabs_aws_c_io//:aws-c-io",
        ],
        visibility = ["//visibility:public"],
    )
