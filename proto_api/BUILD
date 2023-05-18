load("@bazel_skylib//rules:diff_test.bzl", "diff_test")
load("@io_bazel_rules_closure//closure:defs.bzl", "closure_js_library")

proto_library(
    name = "api_meta_proto",
    srcs = ["api_meta.proto"],
    deps = [
        "@com_google_protobuf//:descriptor_proto",
    ],
    visibility = ["//visibility:public"],
)

cc_proto_library(
    name = "api_meta_cc",
    deps = [":api_meta_proto"],
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
        ":api_meta_cc",
        ":descriptor_proto_cc",
    ],
    visibility = ["//visibility:public"],
)
