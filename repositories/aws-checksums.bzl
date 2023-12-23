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
                "tests/**",
            ],
        ),
        hdrs = [":aws-checksums"],
        srcs = [
            ":aws-checksums.c",
            ####
            ":aws-checksums-arch-arm.c",
            ":aws-checksums-arch-intel.c",
            ":aws-checksums-arch-intel-impl.c",
            ":aws-checksums-arch-generic.c",
        ],
    )

    ############################################################################
    ARCH_ARM_C      = ["source/arm/**/*.c"]
    ARCH_INTEL_C    = ["source/intel/**/*.c"]
    ARCH_GENERIC_C  = ["source/generic/**/*.c"]
    native.filegroup(
        name = "aws-checksums-arch-arm.c",
        srcs = native.glob(ARCH_ARM_C),
    )
    native.filegroup(
        name = "aws-checksums-arch-intel.c",
        srcs = select({
            "@bazel_tools//tools/cpp:msvc": ["source/intel/visualc/visualc_crc32c_sse42.c"],
            "//conditions:default": ["source/intel/asm/crc32c_sse42_asm.c"],
        }),
    )
    native.filegroup(
        name = "aws-checksums-arch-intel-impl.c",
        testonly = True,
        srcs = [
            "source/intel/visualc/visualc_crc32c_sse42.c",
            "source/intel/asm/crc32c_sse42_asm.c",
        ]
    )
    native.filegroup(
        name = "aws-checksums-arch-generic.c",
        srcs = native.glob(ARCH_GENERIC_C),
    )
    native.alias(
        name = "aws-checksums-arch.c",
        actual = selects.with_or({
            ("@platforms//cpu:aarch32", "@platforms//cpu:aarch64"): "aws-checksums-arch-arm.c",
            ("@platforms//cpu:x86_32", "@platforms//cpu:x86_64"): "aws-checksums-arch-intel.c",
            "//conditions:default": "aws-checksums-arch-generic.c",
        })
    )

    ############################################################################
    native.filegroup(
        name = "aws-checksums.c",
        srcs = native.glob([
            "source/*.c",
        ],
        exclude =
            ARCH_ARM_C  + ARCH_INTEL_C  + ARCH_GENERIC_C,
        )
    )

    native.cc_library(
        name = "aws-checksums",
        srcs = [
            ":aws-checksums.c",
            ":aws-checksums-arch.c",
        ],
        hdrs = native.glob([
            "include/aws/checksums/*.h",
            "include/aws/checksums/private/*.h",
        ]),
        includes = [
            "include",
        ],
        deps = [
            "@com_github_awslabs_aws_c_common//:aws-c-common",
        ],
        visibility = ["//visibility:public"],
    )
