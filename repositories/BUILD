load("//build_test:build.bzl", "build_test")

exports_files([
    "eigen_static_version_assert.cc",
])

cc_library(
    name = "aws-cpp-sdk-config",
    hdrs = [
        "aws/common/config.h",
    ],
    includes = ["."],
    visibility = ["//visibility:public"],
)

test_suite(
    name = "source_tests",
    tests = [
        "@com_github_apple_oss_common_crypto//:sources_test",
        "@com_githib_aws_s2n_tls//:sources_test",
        "@com_github_awslabs_aws_c_cal//:sources_test",
        "@com_github_awslabs_aws_c_common//:sources_test",
        "@com_github_awslabs_aws_c_compression//:sources_test",
        "@com_github_awslabs_aws_c_http//:sources_test",
        "@com_github_awslabs_aws_c_io//:sources_test",
        "@com_github_awslabs_aws_c_sdkutils//:sources_test",
        "@com_github_awslabs_aws_checksums//:sources_test",
    ],
)

ALL = [
    "@com_github_curl_curl//:curl",
    "@com_github_enki_libev//:libev",
    "@com_github_etr_libhttpserver//:libhttpserver",
    "@com_github_open_source_parsers_jsoncpp//:json",
    "@eigen//:eigen",
    "@zlib//:zlib",
]

MANUAL = [
    "@com_github_openssl_openssl//:openssl",           # >2m30s
    "@com_gitlab_gnutls//:gnutls",
    "@com_gitlab_libidn_libidn2//:libidn2",
    "@org_gnu_microhttpd//:microhttpd",
    "@se_liu_lysator_nettle_nettle//:nettle",          # >90s
]

[build_test(
    name = t.split("/")[0].replace("@", ""),
    targets = [t],
) for t in ALL]

[build_test(
    name = t.split("/")[0].replace("@", ""),
    tags = ["manual"],
    targets = [t],
) for t in MANUAL]

test_suite(
    name = "ci",
    tests = [
        t.split("/")[0].replace("@", "")
        for t in ALL
    ],
)

test_suite(
    name = "manual",
    tags = ["manual"],
    tests = [
        t.split("/")[0].replace("@", "")
        for t in MANUAL
    ] + [
        "@com_github_etr_libhttpserver//:all_tests",
    ],
)
