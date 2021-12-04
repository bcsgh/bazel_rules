load("@bazel_rules//build_test:build.bzl", "build_test")

ALL = [
    "@com_github_curl_curl//:curl",
    "@com_github_enki_libev//:libev",
    "@com_github_open_source_parsers_jsoncpp//:json",
    "@eigen//:eigen",
    "@zlib//:zlib",
]

MANUAL = [
    "@com_github_etr_libhttpserver//:libhttpserver",
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
    ],
)
