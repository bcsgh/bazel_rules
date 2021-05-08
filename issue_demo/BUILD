cc_binary(
    name = "libcurl_demo",
    srcs = ["libcurl_demo.cc"],
    args = ["--alsologtostderr"],
    deps = [
        "@com_github_curl_curl//:curl",
        "@com_google_absl//absl/cleanup",
        "@com_google_absl//absl/strings",
    ],
)

cc_test(
    name = "libcurl_tls_test",
    srcs = ["libcurl_tls_test.cc"],
    args = ["--alsologtostderr"],
    deps = [
        "@com_github_curl_curl//:curl",
        "@com_google_absl//absl/cleanup",
        "@com_google_absl//absl/strings",
    ],
)
