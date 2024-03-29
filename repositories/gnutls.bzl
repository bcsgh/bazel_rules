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
        srcs = native.glob(
            ["**"],
            exclude = [
                "devel/libtasn1/tests/**",
            ],
        ),
    )

    configure_make(
        name = "gnutls",
        autogen = True,
        autogen_command = "bootstrap",
        autogen_options = [
            "--no-bootstrap-sync",
            "--copy",
            "--no-git",
            "--gnulib-srcdir=gnulib",
            "--skip-po",
        ],
        env = {
            "CFLAGS": " ".join([
                "-Wno-error",
            ]),
        },
        ###
        configure_in_place = True,
        configure_options = [
            #"--help=recursive",
            "--disable-cxx",  # To avoid exceptions
            "--disable-tests",
            "--disable-doc",
            "--with-included-unistring",
            "--enable-shared=no",
        ],
        lib_source = ":lib_source",
        out_static_libs = ["gnutls.a"],
        ###
        postfix_script = "\n".join([
            # Squash all the generated libraries into one.
            # This avoids needing to know exactly which libraries are generated.
            "mkdir ar_merge_tmp",
            "(cd ar_merge_tmp ; for f in ../lib/*/.libs/*.a ; do ar -x $f ; done )",
            "ar -csr $INSTALLDIR/lib/gnutls.a ar_merge_tmp/*.o",
        ]),
        deps = [
            "@com_github_enki_libev//:libev",
            "@se_liu_lysator_nettle_nettle//:nettle",
        ],
        visibility = ["//visibility:public"],
    )
