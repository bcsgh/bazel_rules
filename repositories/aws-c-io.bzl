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
                "include/aws/testing/**",
                "tests/**",
            ],
        ),
        hdrs = [":aws-c-io"],
        srcs = [
            ":aws-c-io.c",
            ########
            ":aws-c-io-tls-darwin.c",
            ":aws-c-io-tls-s2n.c",
            ":aws-c-io-tls-windows.c",
            ########
            "aws-c-io-other-bsd.c",
            "aws-c-io-other-linux.c",
            "aws-c-io-other-windows.c",
        ],
    )

    ############################################################################
    TLS_DARWIN_C =  [
        "source/darwin/secure_transport_tls_channel_handler.c",
        "source/darwin/darwin_pki_utils.c",
    ]
    TLS_S2N_C =     ["source/s2n/s2n_tls_channel_handler.c"]
    TLS_WINDOWS_C = [
        "source/windows/secure_channel_tls_handler.c",
        "source/windows/windows_pki_utils.c",
    ]
    native.filegroup(
        name = "aws-c-io-tls-darwin.c",
        srcs = native.glob(TLS_DARWIN_C),
    )
    native.filegroup(
        name = "aws-c-io-tls-windows.c",
        srcs = native.glob(TLS_WINDOWS_C),
    )
    native.filegroup(
        name = "aws-c-io-tls-s2n.c",
        srcs = native.glob(TLS_S2N_C),
    )
    native.alias(
        name = "aws-c-io-tls.c",
        actual = selects.with_or({
            ("@platforms//os:osx", "@platforms//os:ios"):
                ":aws-c-io-tls-darwin.c",
            "@platforms//os:windows":
                ":aws-c-io-tls-windows.c",
            "//conditions:default":
                ":aws-c-io-tls-s2n.c",
        }),
    )
    native.cc_library(
        name = "aws-c-io-tls",
        defines = selects.with_or({
            ("@platforms//os:osx", "@platforms//os:ios"): [],
            "@platforms//os:windows": [],
            "//conditions:default": ["USE_S2N"],
        }),
        deps = selects.with_or({
            ("@platforms//os:osx", "@platforms//os:ios"): [],
            "@platforms//os:windows": [],
            "//conditions:default": ["@com_githib_aws_s2n_tls//:s2n-tls"],
        }),
    )

    ############################################################################
    OTHER_BSD_C = ["source/bsd/kqueue_event_loop.c"]
    OTHER_LINUX_C = ["source/linux/epoll_event_loop.c"]
    OTHER_POSIX_C = [
        "source/posix/host_resolver.c",
        "source/posix/pipe.c",
        "source/posix/shared_library.c",
        "source/posix/socket.c",
    ]
    OTHER_WINDOWS_C = [
        "source/windows/host_resolver.c",
        "source/windows/iocp/iocp_event_loop.c",
        "source/windows/iocp/pipe.c",
        "source/windows/iocp/socket.c",
        "source/windows/shared_library.c",
        "source/windows/winsock_init.c",
    ]
    native.filegroup(
        name = "aws-c-io-other-bsd.c",
        srcs = OTHER_BSD_C + OTHER_POSIX_C,
    )
    native.filegroup(
        name = "aws-c-io-other-linux.c",
        srcs = OTHER_LINUX_C+ OTHER_POSIX_C,
    )
    native.filegroup(
        name = "aws-c-io-other-windows.c",
        srcs = native.glob(OTHER_WINDOWS_C),
    )
    native.alias(
        name = "aws-c-io-other.c",
        actual = selects.with_or({
            ("@platforms//os:freebsd", "@platforms//os:netbsd", "@platforms//os:openbsd"):
                ":aws-c-io-other-bsd.c",
            "@platforms//os:windows":
                ":aws-c-io-other-windows.c",
            "@platforms//os:linux":
                ":aws-c-io-other-linux.c",
        }),
    )

    ############################################################################
    native.filegroup(
        name = "aws-c-io.c",
        srcs = native.glob([
            "source/*.c",
            "source/pkcs11/v2.40/*.h",
            "source/pkcs11_private.h",
        ],
        exclude =
            TLS_DARWIN_C + TLS_S2N_C + TLS_WINDOWS_C +
            OTHER_BSD_C + OTHER_LINUX_C + OTHER_WINDOWS_C
        )
    )

    native.cc_library(
        name = "aws-c-io",
        srcs = [
            ":aws-c-io.c",
            ":aws-c-io-other.c",
            ":aws-c-io-tls.c",
        ],
        hdrs = native.glob([
            "include/aws/io/**/*.h",
        ]),
        includes = ["include"],
        deps = [
            "@com_github_awslabs_aws_c_cal//:aws-c-cal",
            "@com_github_awslabs_aws_c_common//:aws-c-common",
            ":aws-c-io-tls",
        ],
        visibility = ["//visibility:public"],
    )
