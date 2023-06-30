workspace(name = "bazel_rules")

load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
load("@bazel_rules//repositories:repositories.bzl", "eigen", "jsoncpp", "libcurl", "libev", "libgnutls", "libhttpserver", "libidn2", "libnettle", "libp11", "microhttpd", "openssl", "zlib")
eigen()
jsoncpp()
libcurl()
libev()
libgnutls()
libhttpserver()
libidn2()
libnettle()
libp11()
microhttpd()
openssl()
zlib()

load("@bazel_rules//cc_embed_data:cc_embed_data_deps.bzl", cc_embed_data_deps = "get_deps")
load("@bazel_rules//css_js:css_js_deps.bzl", css_js_deps = "get_deps")
load("@bazel_rules//tests:fail_test.bzl", fail_test_deps = "get_deps")
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

git_repository(
    name = "rules_foreign_cc",
    commit = "c923238c6dc5a35c233a4acca28d90a0b1816836",  # current as of 2022/10/27
    remote = "https://github.com/bazelbuild/rules_foreign_cc.git",
    shallow_since = "1666910343 +0100",
)

load("@rules_foreign_cc//foreign_cc:repositories.bzl", "rules_foreign_cc_dependencies")

rules_foreign_cc_dependencies([])

#############################################
load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

#############################################
#"""
load("@bazel_rules//latex:repo.bzl", "latex_toolchain_repository")
latex_toolchain_repository(name="local_latex_toolchain")
register_toolchains("@local_latex_toolchain//:local_latex")  # uses ctx.which to look things up
"""
register_toolchains("@bazel_rules//latex:linux_texlive")  # assumes default paths
#"""

register_toolchains("@bazel_rules//parser:linux_flex_bison")

#############################################
git_repository(
    name = "rules_proto",
    commit = "f371ed34ed7f1a8b83cc34ae96db277e0ba4fcb0",  # tag=5.3.0-21.5 + f371ed3
    remote = "https://github.com/bazelbuild/rules_proto.git",
    shallow_since = "1664409030 -0700",
)

load("@rules_proto//proto:repositories.bzl", "rules_proto_dependencies")

rules_proto_dependencies()

#############################################
# https://github.com/bazelbuild/rules_closure
git_repository(
    name = "io_bazel_rules_closure",
    remote = "https://github.com/bazelbuild/rules_closure.git",
    tag = "0.11.0",
)

load("@io_bazel_rules_closure//closure:repositories.bzl", "rules_closure_dependencies", "rules_closure_toolchains")

rules_closure_dependencies()

rules_closure_toolchains()

#############################################
git_repository(
    name = "com_google_googletest",
    commit = "3026483ae575e2de942db5e760cf95e973308dd5",  # current as of 2022/10/25
    remote = "https://github.com/google/googletest.git",
    shallow_since = "1666712359 -0700",
)

#############################################
git_repository(
    name = "com_googlesource_code_re2",
    commit = "7a65faf439295e941baa6640a717d89c1f13e9cd",  # current as of 2022/10/27
    remote = "https://github.com/google/re2.git",
    shallow_since = "1666860568 +0000",
)

#############################################
