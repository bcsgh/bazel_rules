# Copyright (c) 2018, Benjamin Shropshire,
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
# 3. Neither the name of the copyright holder nor the names of its contributors
#    may be used to endorse or promote products derived from this software
#    without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

load("//build_test:build.bzl", "build_test")
load("//graphviz:graphviz.bzl", "gen_dot")
load("@bazel_skylib//rules:diff_test.bzl", "diff_test")
load(":build_test_test.bzl", "build_test_suite")
load(":cc_embed_data_test.bzl", "cc_embed_data_suite")
load(":css_js_test.bzl", "css_class_names_js_suite")
load(":detex_test.bzl", "detex_suite")
load(":gen_dot_test.bzl", "gen_dot_suite")
load(":git_stamp_test.bzl", "git_stamp_suite")
load(":latex_ref_test_test.bzl", "latex_ref_test_suite")
load(":parser_test.bzl", "parser_suite")
load(":proto_api_test.bzl", "proto_api_suite")
load(":role_call_test_test.bzl", "role_call_test_suite")
load(":spell_test_test.bzl", "spell_test_suite")
load(":tex_to_pdf_test.bzl", "tex_to_pdf_suite")

test_suite(
    name = "ci",
    tests = [
        ":build_test_test",
        ":cc_embed_data_test",
        ":com_github_enki_libev_ver_test",
        ":com_github_open_source_parsers_jsoncpp_ver_test",
        ":com_github_p11glue_p11kit_ver_test",
        ":com_gitlab_gnutls_libtasn1_ver_test",
        ":com_gitlab_libidn_libidn2_ver_test",
        ":detex_test",
        ":dictionary_gold_test",
        ":eigen_test",
        ":eigen_ver_test",
        ":gen_dot_test",
        ":gen_latex_test",
        ":org_gmplib_gmp_ver_test",
        ":parser_test",
        ":proto_api_test",
        ":ref_test",
        ":role_call_test",
        ":se_liu_lysator_nettle_nettle_ver_test",
        ":spell_test_test",
        ":zlib_ver_test",
    ],
)

test_suite(
    name = "ver_tests",
    tags = ["manual"],
    tests = [
        ":com_github_curl_curl_ver_test",
        ":com_github_enki_libev_ver_test",
        ":com_github_open_source_parsers_jsoncpp_ver_test",
        ":com_github_openssl_openssl_ver_test",
        ":com_github_p11glue_p11kit_ver_test",
        ":com_gitlab_gnutls_libtasn1_ver_test",
        ":com_gitlab_libidn_libidn2_ver_test",
        ":eigen_ver_test",
        ":org_gmplib_gmp_ver_test",
        ":se_liu_lysator_nettle_nettle_ver_test",
        ":zlib_ver_test",
    ],
)

######## build_test
build_test_suite(
    name = "build_test_test",
)

######## cc_embed_data

cc_embed_data_suite(
    name = "cc_embed_data_test",
)
######## genlex/genyacc

parser_suite(
    name = "parser_test"
)

######## gen_dot

gen_dot_suite(
    name = "gen_dot_test",
)

######## http

build_test(
    name = "http",
    tags = ["manual"],
    targets = [
        "@com_github_etr_libhttpserver//:libhttpserver",
        "@org_gnu_microhttpd//:microhttpd",
    ],
)

######## css_js

css_class_names_js_suite(
    name = "css_js",
)

######## latex

git_stamp_suite(
    name = "git_stamp_test",
)

tex_to_pdf_suite(
    name = "gen_latex_test",
)

detex_suite(
    name = "detex_test",
)

latex_ref_test_suite(
    name = "ref_test",
    job = ":gen_tex_to_pdf",
)

role_call_test_suite(
    name = "role_call_test",
)

diff_test(
    name = "dictionary_gold_test",
    file1 = ":gen_latex.dict",
    file2 = ":spell_test.dict",
)

######## spelling

spell_test_suite(
    name = "spell_test_test",
)

######## gen_proto_api
proto_api_suite(
    name = "proto_api_test",
)

######## repositories

build_test(
    name = "eigen_test",
    targets = [
        "@eigen//:eigen",
    ],
)

cc_test(
    name = "libcurl_tls_test",
    srcs = ["libcurl_tls_test.cc"],
    tags = ["manual"],
    deps = [
        "@com_github_curl_curl//:curl",
        "@com_google_absl//absl/cleanup",
        "@com_google_absl//absl/strings",
    ],
)

cc_test(
    name = "eigen_ver_test",
    srcs = ["eigen_ver_test.cc"],
    deps = [
        "@com_google_googletest//:gtest_main",
        "@eigen//:eigen",
    ],
)

cc_test(
    name = "com_github_curl_curl_ver_test",
    srcs = ["com_github_curl_curl_ver_test.cc"],
    tags = ["manual"],
    deps = [
        "@com_github_curl_curl//:curl",
        "@com_google_googletest//:gtest_main",
    ],
)

cc_test(
    name = "com_gitlab_libidn_libidn2_ver_test",
    srcs = ["com_gitlab_libidn_libidn2_ver_test.cc"],
    deps = [
        "@com_gitlab_libidn_libidn2//:libidn2",
        "@com_google_googletest//:gtest_main",
    ],
)

cc_test(
    name = "zlib_ver_test",
    srcs = ["zlib_ver_test.cc"],
    deps = [
        "@com_google_googletest//:gtest_main",
        "@zlib//:zlib",
    ],
)

cc_test(
    name = "com_github_open_source_parsers_jsoncpp_ver_test",
    srcs = ["com_github_open_source_parsers_jsoncpp_ver_test.cc"],
    deps = [
        "@com_github_open_source_parsers_jsoncpp//:json",
        "@com_google_googletest//:gtest_main",
    ],
)

cc_test(
    name = "se_liu_lysator_nettle_nettle_ver_test",
    srcs = ["se_liu_lysator_nettle_nettle_ver_test.cc"],
    tags = ["manual"],
    deps = [
        "@com_google_googletest//:gtest_main",
        "@se_liu_lysator_nettle_nettle//:nettle",
    ],
)

cc_test(
    name = "com_github_enki_libev_ver_test",
    srcs = ["com_github_enki_libev_ver_test.cc"],
    deps = [
        "@com_github_enki_libev//:libev",
        "@com_google_googletest//:gtest_main",
    ],
)

cc_test(
    name = "com_github_openssl_openssl_ver_test",
    srcs = ["com_github_openssl_openssl_ver_test.cc"],
    tags = ["manual"],
    deps = [
        "@com_github_openssl_openssl//:openssl",
        "@com_google_googletest//:gtest_main",
    ],
)

cc_test(
    name = "com_gitlab_gnutls_libtasn1_ver_test",
    srcs = ["com_gitlab_gnutls_libtasn1_ver_test.cc"],
    deps = [
        "@com_gitlab_gnutls_libtasn1//:libtasn1",
        "@com_google_googletest//:gtest_main",
    ],
)

cc_test(
    name = "com_github_p11glue_p11kit_ver_test",
    srcs = ["com_github_p11glue_p11kit_ver_test.cc"],
    deps = [
        "@com_github_p11glue_p11kit//:libp11kit",
        "@com_google_googletest//:gtest_main",
    ],
)

cc_test(
    name = "org_gmplib_gmp_ver_test",
    srcs = ["org_gmplib_gmp_ver_test.cc"],
    deps = [
        "@com_google_googletest//:gtest_main",
        "@org_gmplib_gmp//:gmplib",
    ],
)
########

build_test(
    name = "git_commit_test",
    targets = [
        "@workspace_status//:git-commit",
    ],
)

########
test_suite(
    name = "aws_smoke_tests",
    tests = [
        ":com_github_awslabs_aws_c_auth_smoke_test",
        ":com_github_awslabs_aws_c_cal_smoke_test",
        ":com_github_awslabs_aws_c_common_smoke_test",
        ":com_github_awslabs_aws_c_compression_smoke_test",
        ":com_github_awslabs_aws_c_http_smoke_test",
        ":com_github_awslabs_aws_c_io_smoke_test",
        ":com_github_awslabs_aws_c_s3_smoke_test",
        ":com_github_awslabs_aws_c_sdkutils_smoke_test",
    ]
)

cc_test(
    name = "com_github_awslabs_aws_c_auth_smoke_test",
    srcs = ["basic_smoke_test.cc"],
    deps = ["@com_github_awslabs_aws_c_auth//:aws-c-auth"],
)

cc_test(
    name = "com_github_awslabs_aws_c_cal_smoke_test",
    srcs = ["basic_smoke_test.cc"],
    deps = ["@com_github_awslabs_aws_c_cal//:aws-c-cal"],
)

cc_test(
    name = "com_github_awslabs_aws_c_common_smoke_test",
    srcs = ["basic_smoke_test.cc"],
    deps = ["@com_github_awslabs_aws_c_common//:aws-c-common"],
)

cc_test(
    name = "com_github_awslabs_aws_c_compression_smoke_test",
    srcs = ["basic_smoke_test.cc"],
    deps = ["@com_github_awslabs_aws_c_compression//:aws-c-compression"],
)

cc_test(
    name = "com_github_awslabs_aws_c_http_smoke_test",
    srcs = ["basic_smoke_test.cc"],
    deps = ["@com_github_awslabs_aws_c_http//:aws-c-http"],
)

cc_test(
    name = "com_github_awslabs_aws_c_io_smoke_test",
    srcs = ["basic_smoke_test.cc"],
    deps = ["@com_github_awslabs_aws_c_io//:aws-c-io"],
)

cc_test(
    name = "com_github_awslabs_aws_c_s3_smoke_test",
    srcs = ["basic_smoke_test.cc"],
    deps = ["@com_github_awslabs_aws_c_s3//:aws-c-s3"],
)

cc_test(
    name = "com_github_awslabs_aws_c_sdkutils_smoke_test",
    srcs = ["basic_smoke_test.cc"],
    deps = ["@com_github_awslabs_aws_c_sdkutils//:aws-c-sdkutils"],
)
