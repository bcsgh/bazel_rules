# Building this may need one or more of the following:
# sudo apt install \
#   gperf \
#   autogen \
#   pkg-config \
#   autotools-dev \
#   autoconf \
#   libtool \
#   autopoint \
#   libpthread-stubs0-dev

load("@rules_foreign_cc//foreign_cc:configure.bzl", "configure_make")

def BUILD():
    native.filegroup(
        name = "lib_source",
        srcs = native.glob(["**"]),
    )

    configure_make(
        name = "nettle",
        autogen = True,
        autogen_command = ".bootstrap",
        env = {
            "CFLAGS": "-Wno-error",
        },
        configure_in_place = True,
        configure_options = [
            #"--help",
            "--disable-doc",
            "--disable-shared",
        ],
        lib_source = ":lib_source",
        out_static_libs = ["libnettle.a"],
        visibility = ["//visibility:public"],
    )
