load("@bazel_rules//build_test:build.bzl", "build_test")

build_test(
    name = "http",
    targets = [
        "@com_github_etr_libhttpserver//:libhttpserver",
        "@org_gnu_microhttpd//:microhttpd",
    ]
)
