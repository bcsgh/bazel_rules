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

# Derived from https://github.com/bazelbuild/rules_foreign_cc/blob/main/examples/third_party/openssl/BUILD.openssl.bazel
# (Under http://www.apache.org/licenses/ )

"""An openssl build file based on a snippet found in the github issue:
https://github.com/bazelbuild/rules_foreign_cc/issues/337

Note that the $(PERL) "make variable" (https://docs.bazel.build/versions/main/be/make-variables.html)
is populated by the perl toolchain provided by rules_perl.
"""

load("@rules_foreign_cc//foreign_cc:configure.bzl", "configure_make", "configure_make_variant")

def BUILD(version):
    # Read https://wiki.openssl.org/index.php/Compilation_and_Installation

    native.filegroup(
        name = "all_srcs",
        srcs = native.glob(
            include = ["**"],
            exclude = [
                "BUILD",
                "*.bzl",
            ],
        ),
    )

    CONFIGURE_OPTIONS = [
        "no-comp",
        "no-idea",
        "no-weak-ssl-ciphers",
    ]

    MAKE_TARGETS = [
        "build_programs",
        "install_sw",
    ]

    native.config_setting(
        name = "msvc_compiler",
        flag_values = {
            "@bazel_tools//tools/cpp:compiler": "msvc-cl",
        },
    )

    native.alias(
        name = "openssl",
        actual = select({
            ":msvc_compiler": None,  ##### Note: the orginal has an MSVC build.
            "//conditions:default": ":openssl_default",
        }),
        visibility = ["//visibility:public"],
    )

    configure_make(
        name = "openssl_default",
        configure_command = "config",
        configure_in_place = True,
        configure_options = CONFIGURE_OPTIONS,
        env = select({
            "@platforms//os:macos": {
                "AR": "",
                "PERL": "$$EXT_BUILD_ROOT$$/$(PERL)",
            },
            "//conditions:default": {
                "PERL": "$$EXT_BUILD_ROOT$$/$(PERL)",
            },
        }),
        lib_name = "openssl",
        lib_source = ":all_srcs",
        # Note that for Linux builds, libssl must come before libcrypto on the linker command-line.
        # As such, libssl must be listed before libcrypto
        out_lib_dir = "lib64",
        out_shared_libs = select({
            "@platforms//os:macos": [
                "libssl.%s.dylib" % version,  # NOT TESTED!
                "libcrypto.%s.dylib" % version,
            ],
            "//conditions:default": [
                "libssl.so.%s" % version,
                "libcrypto.so.%s" % version,
            ],
        }),
        #out_interface_libs = [
        #    "libssl.a",
        #    "libcrypto.a",
        #],
        targets = MAKE_TARGETS,
        toolchains = ["@rules_perl//:current_toolchain"],
    )
