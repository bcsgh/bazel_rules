load("@bazel_rules//repositories:compare_cc_deps_test.bzl", "compare_cc_deps_test")
load("@bazel_skylib//lib:selects.bzl", "selects")
load("@bazel_skylib//rules:write_file.bzl", "write_file")

def BUILD():
    # Not used anywhere in here?
    ITTNOTIFY = ["include/aws/common/external/ittnotify.h"]
    native.cc_library(
        name = "ittnotify-intel",
        hdrs = ITTNOTIFY,
    )
    native.alias(
        name = "ittnotify",
        actual = select({
            #### It's not clear when each of these should be used.
            "//conditions:default": Label(":ittnotify-noop"),
            #"???": ":ittnotify-intel",
        }),
        visibility = ["//visibility:public"],
    )

    ############################################################################
    write_file(
        name = "aws-c-common-config-hdr",
        out = "aws/common/config.h",
        content = [],  # blank. (for now?)
    )
    native.cc_library(
        name = "aws-c-common-config",
        hdrs = ["aws/common/config.h"],
        includes = ["."],
    )

    ############################################################################
    compare_cc_deps_test(
        name = "sources_test",
        glob = native.glob(
            [
                "**/*.%s" % (e)
                for e in ["c", "cpp", "h", "inl"]
            ],
            exclude = [
                "bin/**",
                "tests/**",
                "verification/cbmc/**",
                ###
                "include/aws/testing/aws_test_harness.h",
                "AWSCRTAndroidTestRunner/app/src/main/cpp/native-lib.cpp",
            ],
        ),
        hdrs = [
            ":aws-c-common",
            ":ittnotify-intel",
        ],
        srcs = [
            ":aws-c-common.c",
            ####
            ":aws-c-common-sys-android.c",
            ":aws-c-common-sys-posix.c",
            ":aws-c-common-sys-windows.c",
            ####
            ":aws-c-common-sysenv-linux.c",
            ":aws-c-common-sysenv-fallback.c",
            ####
            ":aws-c-common-arch-arm.c",
            ":aws-c-common-arch-intel.c",
            ":aws-c-common-arch-intel-impl.c",
            ":aws-c-common-arch-generic.c",
        ],
    )

    ############################################################################
    SYS_POSIX_C =   ["source/posix/*.c"]
    SYS_WINDOWS_C = ["source/windows/*.c"]
    native.filegroup(
        name = "aws-c-common-sys-posix.c",
        srcs = native.glob(SYS_POSIX_C),
    )
    native.filegroup(
        name = "aws-c-common-sys-windows.c",
        srcs = native.glob(SYS_WINDOWS_C),
    )
    native.alias(
        name = "aws-c-common-sys.c",
        actual = select({
            "@platforms//os:windows": "aws-c-common-sys-windows.c",
            "//conditions:default": "aws-c-common-sys-posix.c",
        }),
    )
    native.cc_library(
        name = "aws-c-common-sys",
        linkopts = select({
            "@platforms//os:linux": ["-lpthread", "-ldl"],
            "//conditions:default": [],
        }),
    )

    ############################################################################
    SYS_ANDROID_C = ["source/android/*.c"]
    native.filegroup(
        name = "aws-c-common-sys-android.c",
        srcs = ["source/android/logging.c"],
    )

    ############################################################################
    SYSENV_LINUX_C =   ["source/linux/system_info.c"]
    SYSENV_FALLBAK_C = ["source/platform_fallback_stubs/system_info.c"]
    native.filegroup(
        name = "aws-c-common-sysenv-linux.c",
        srcs = native.glob(SYSENV_LINUX_C),
    )
    native.filegroup(
        name = "aws-c-common-sysenv-fallback.c",
        srcs = native.glob(SYSENV_FALLBAK_C),
    )
    native.alias(
        name = "aws-c-common-sysenv.c",
        actual = select({
            "@platforms//os:linux": "aws-c-common-sysenv-linux.c",
            "//conditions:default": "aws-c-common-sysenv-fallback.c",
        }),
    )

    ############################################################################
    ARCH_ARM_C =     ["source/arch/arm/**/*.c"]
    ARCH_INTEL_C =   ["source/arch/intel/**/*.c"]
    ARCH_GENERIC_C = ["source/arch/generic/**/*.c"]
    native.filegroup(
        name = "aws-c-common-arch-arm.c",
        srcs = native.glob(ARCH_ARM_C),
    )
    native.filegroup(
        name = "aws-c-common-arch-intel.c",
        srcs = [
            "source/arch/intel/encoding_avx2.c",
            "source/arch/intel/cpuid.c",
        ] + select({
            "@bazel_tools//tools/cpp:msvc": ["source/arch/intel/msvc/cpuid.c"],
            "//conditions:default": ["source/arch/intel/asm/cpuid.c"],
        }),
    )
    native.filegroup(
        name = "aws-c-common-arch-intel-impl.c",
        testonly = True,
        srcs = [
            "source/arch/intel/msvc/cpuid.c",
            "source/arch/intel/asm/cpuid.c",
        ],
    )
    native.filegroup(
        name = "aws-c-common-arch-generic.c",
        srcs = native.glob(ARCH_GENERIC_C),
    )
    native.alias(
        name = "aws-c-common-arch.c",
        actual = selects.with_or({
            ("@platforms//cpu:aarch32", "@platforms//cpu:aarch64"): "aws-c-common-arch-arm.c",
            #("@platforms//cpu:x86_32", "@platforms//cpu:x86_64"): "aws-c-common-arch-intel.c",  # TODO Doesn't compile?
            "//conditions:default": "aws-c-common-arch-generic.c",
        }),
    )

    ############################################################################
    native.filegroup(
        name = "aws-c-common.c",
        srcs = native.glob(
            [
                "source/**/*.c",
            ],
            exclude =
                SYSENV_LINUX_C + SYSENV_FALLBAK_C +
                SYS_ANDROID_C + SYS_POSIX_C + SYS_WINDOWS_C +
                ARCH_ARM_C + ARCH_INTEL_C + ARCH_GENERIC_C,
        ),
    )

    native.cc_library(
        name = "aws-c-common",
        srcs = [
            ":aws-c-common.c",
            ":aws-c-common-arch.c",
            ":aws-c-common-sys.c",
            ":aws-c-common-sysenv.c",
        ] + select({
            "@platforms//os:android": [":aws-c-common-sys-android.c"],
            "//conditions:default": [],
        }),
        hdrs = native.glob([
            "include/aws/common/*.h",
            "include/aws/common/*.inl",
            "include/aws/common/external/*.h",
            "include/aws/common/posix/*.inl",
            "include/aws/common/private/*.h",
            "include/aws/common/private/*.inl",
        ], exclude = ITTNOTIFY),
        includes = ["include"],
        defines = [
            "AWS_AFFINITY_METHOD=0",  # TODO see source/posix/thread.c
        ],
        deps = [
            ":aws-c-common-config",
            ":aws-c-common-sys",
        ],
        visibility = ["//visibility:public"],
    )
