def BUILD():
    skip = ["lua.c", "onelua.c"]
    hdrs = native.glob(["*.h"], exclude = skip)
    srcs = native.glob(["*.c"], exclude = skip)

    native.cc_library(
        name = "lua",
        hdrs = hdrs,
        srcs = srcs,
        visibility = ["//visibility:public"],
    )
