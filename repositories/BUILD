load("@bazel_rules//build_test:build.bzl", "build_test")

ALL = [
    "@com_github_curl_curl//:curl",
    "@com_github_enki_libev//:libev",
    "@com_github_etr_libhttpserver//:libhttpserver",
    "@com_github_open_source_parsers_jsoncpp//:json",
    "@com_github_openssl_openssl//:openssl",
    "@com_gitlab_gnutls//:gnutls",
    "@eigen//:eigen",
    "@se_liu_lysator_nettle_nettle//:nettle",
    "@zlib//:zlib",
]
MANUAL = [
    "@com_gitlab_libidn_libidn2//:libidn2",
    "@org_gnu_microhttpd//:microhttpd",
]

[build_test(
    name = t.split("/")[0].replace("@", ""),
    targets = [t],
) for t in ALL]

[build_test(
    name = t.split("/")[0].replace("@", ""),
    targets = [t],
    manual = True,
) for t in MANUAL]
