load("@bazel_rules//repositories:compare_cc_deps_test.bzl", "compare_cc_deps_test")
load("@bazel_skylib//rules:diff_test.bzl", "diff_test")
load("@bazel_skylib//rules:expand_template.bzl", "expand_template")
load("@bazel_skylib//rules:write_file.bzl", "write_file")

def BUILD(ver = "<<UNKNOWN>>"):
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
        hdrs = [":aws-crt-cpp"],
        srcs = [":aws-crt-cpp.cpp"],
    )

    maj, min, patch = ver.split(".")
    expand_template(
        name = "gen_config_h",
        template = Label(":crt_config.h.tpl"),
        out = "include/aws/crt/Config.h",
        substitutions = {
            "{VER}": ver,
            "{VER_MAJ}": maj,
            "{VER_MIN}": min,
            "{VER_PATCH}": patch,
        },
    )

    write_file(
        name = "crt_VERSION",
        content = [ver, ""],
        out = "crt_VERSION.test",
        testonly = True,
    )

    diff_test(
        name = "version_test",
        file1 = ":crt_VERSION.test",
        file2 = ":VERSION",
    )

    native.filegroup(
        name = "aws-crt-cpp.cpp",
        srcs = native.glob(
            [
                "source/*.cpp",
                "source/auth/*.cpp",
                "source/crypto/*.cpp",
                "source/endpoints/*.cpp",
                "source/http/*.cpp",
                "source/io/*.cpp",
                "source/iot/*.cpp",
                "source/mqtt/*.cpp",
            ],
        ),
    )

    native.cc_library(
        name = "aws-crt-cpp",
        srcs = [":aws-crt-cpp.cpp"],
        hdrs = [
            ":gen_config_h",
        ] + native.glob([
            "include/aws/crt/*.h",
            "include/aws/crt/auth/*.h",
            "include/aws/crt/crypto/*.h",
            "include/aws/crt/endpoints/*.h",
            "include/aws/crt/http/*.h",
            "include/aws/crt/io/*.h",
            "include/aws/crt/mqtt/*.h",
            "include/aws/crt/mqtt/private/*.h",
            "include/aws/iot/*.h",
        ]),
        includes = ["include"],
        deps = [
            "@com_github_awslabs_aws_c_auth//:aws-c-auth",
            "@com_github_awslabs_aws_c_cal//:aws-c-cal",
            "@com_github_awslabs_aws_c_common//:aws-c-common",
            "@com_github_awslabs_aws_c_event_stream//:aws-c-event-stream",
            "@com_github_awslabs_aws_c_io//:aws-c-io",
            "@com_github_awslabs_aws_c_mqtt//:aws-c-mqtt",
            "@com_github_awslabs_aws_c_s3//:aws-c-s3",
        ],
        visibility = ["//visibility:public"],
    )
