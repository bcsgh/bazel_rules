workspace(name = "bazel_rules")

load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

git_repository(  # TODO: stuck here. Updateing seems to break something.
    name = "rules_foreign_cc",
    commit = "c923238c6dc5a35c233a4acca28d90a0b1816836",  # current as of 2022/10/27
    remote = "https://github.com/bazelbuild/rules_foreign_cc.git",
    shallow_since = "1666910343 +0100",
)

#############################################
git_repository(
    name = "rules_proto",
    commit = "f371ed34ed7f1a8b83cc34ae96db277e0ba4fcb0",  # tag=5.3.0-21.5 + f371ed3
    remote = "https://github.com/bazelbuild/rules_proto.git",
    shallow_since = "1664409030 -0700",
)

#############################################
# https://github.com/bazelbuild/rules_closure
git_repository(
    name = "io_bazel_rules_closure",
    remote = "https://github.com/bazelbuild/rules_closure.git",
    tag = "0.11.0",
)

#############################################
git_repository(
    name = "com_google_googletest",
    commit = "b10fad38c4026a29ea6561ab15fc4818170d1c10",  # current as of 2023/11/12
    remote = "https://github.com/google/googletest.git",
    shallow_since = "1698701593 -0700",
)

#############################################
git_repository(
    name = "com_googlesource_code_re2",
    commit = "974f44c8d45242e710dc0a85a4defffdb3ce07fc",  # current as of 2023/11/12
    remote = "https://github.com/google/re2.git",
    shallow_since = "1699394483 +0000",
)

################################################################################
################################################################################
load("@bazel_rules//repositories:repositories.bzl", "aws_sdk_cpp", "com_github_aws_sdk", "eigen", "jsoncpp", "libasn1", "libcurl", "libev", "libgmp", "libgnutls", "libhttpserver", "libidn2", "libnettle", "libp11", "load_skylib", "microhttpd", "openssl", "rules_perl", "zlib")
rules_perl()

load("@rules_perl//perl:deps.bzl", "perl_register_toolchains", "perl_rules_dependencies")

load_skylib()

perl_rules_dependencies()
perl_register_toolchains()

eigen()
jsoncpp()
libasn1()
libcurl()
libev()
libgnutls()
libhttpserver()
libidn2()
libgmp()
libnettle()
libp11()
microhttpd()
openssl()
zlib()

# Make sure the special cases get built
load("@bazel_rules//repositories:aws-sdk-cpp.bzl", aws_default_apis = "DEFAULTS", aws_skips = "SKIP")
aws_sdk_cpp(apis = aws_default_apis + aws_skips + ["polly"])

#############################################
load("@bazel_rules//cc_embed_data:cc_embed_data_deps.bzl", cc_embed_data_deps = "get_deps")
load("@bazel_rules//css_js:css_js_deps.bzl", css_js_deps = "get_deps")
load("@bazel_rules//fail_test:fail_test.bzl", fail_test_deps = "get_deps")
load("@bazel_rules//latex:git_stamp_deps.bzl", git_stamp_deps = "get_deps")
load("@bazel_rules//latex:ref_test.bzl", ref_test_deps = "get_deps")
load("@bazel_rules//latex:role_call_test.bzl", role_call_test_deps = "get_deps")
load("@bazel_rules//proto_api:proto_api.bzl", proto_api_deps = "get_deps")
cc_embed_data_deps()
css_js_deps()
fail_test_deps()
git_stamp_deps()
ref_test_deps()
role_call_test_deps()
proto_api_deps()

load("@rules_foreign_cc//foreign_cc:repositories.bzl", "rules_foreign_cc_dependencies")
rules_foreign_cc_dependencies([])

#############################################
load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")
bazel_skylib_workspace()

#############################################
load("@rules_proto//proto:repositories.bzl", "rules_proto_dependencies")
rules_proto_dependencies()

#############################################
load("@io_bazel_rules_closure//closure:repositories.bzl", "rules_closure_dependencies", "rules_closure_toolchains")
rules_closure_dependencies(
    omit_bazel_skylib = True,
)
rules_closure_toolchains()

################################################################################
################################################################################
#"""
load("@bazel_rules//latex:repo.bzl", "latex_toolchain_repository")
latex_toolchain_repository(name="local_latex_toolchain")
register_toolchains("@local_latex_toolchain//:local_latex")  # uses ctx.which to look things up
"""
register_toolchains("@bazel_rules//latex:linux_texlive")  # assumes default paths
#"""

register_toolchains("@bazel_rules//parser:linux_flex_bison")
