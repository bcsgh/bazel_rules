load("@bazel_skylib//rules:diff_test.bzl", "diff_test")
load("@io_bazel_rules_closure//closure:defs.bzl", "closure_js_library")

proto_library(
    name = "api",
    srcs = ["api.proto"],
    deps = [
        "@com_google_protobuf//:descriptor_proto",
    ],
)

cc_proto_library(
    name = "api_cc",
    deps = [":api"],
)

####################################
cc_proto_library(
    name = "descriptor_proto_cc",
    deps = ["@com_google_protobuf//:descriptor_proto"],
)

cc_binary(
    name = "gen_metadata_tool",
    srcs = ["gen_metadata_tool.cc"],
    deps = [
        "@com_google_absl//absl/flags:flag",
        "@com_google_absl//absl/flags:parse",
        ":api_cc",
        ":descriptor_proto_cc",
    ],
    visibility = ["//visibility:public"],
)

closure_js_library(
    name = "gen_metadata_js",
    srcs = [":gen_metadata.js"],
)

cc_library(
    name = "gen_metadata_cc",
    hdrs = [":gen_metadata.h"],
)
