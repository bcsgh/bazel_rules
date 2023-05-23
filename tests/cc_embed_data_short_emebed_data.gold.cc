// Generated code.
#include "absl/strings/string_view.h"
#include "absl/types/span.h"

/////// linker provided globals

// tests/cc_embed_data_test.bzl
extern const char _binary_tests_cc_embed_data_test_bzl_start;
extern const char _binary_tests_cc_embed_data_test_bzl_end;
// bazel-out/k8-fastbuild/bin/tests/gen_detex.txt
extern const char _binary_bazel_out_k8_fastbuild_bin_tests_gen_detex_txt_start;
extern const char _binary_bazel_out_k8_fastbuild_bin_tests_gen_detex_txt_end;
// tests/testdata/nested.txt
extern const char _binary_tests_testdata_nested_txt_start;
extern const char _binary_tests_testdata_nested_txt_end;
// external/bazel_skylib/LICENSE
extern const char _binary_external_bazel_skylib_LICENSE_start;
extern const char _binary_external_bazel_skylib_LICENSE_end;
// external/bazel_tools/tools/genrule/genrule-setup.sh
extern const char _binary_external_bazel_tools_tools_genrule_genrule_setup_sh_start;
extern const char _binary_external_bazel_tools_tools_genrule_genrule_setup_sh_end;

/////// Getter functions.
namespace test_ns {

// tests/cc_embed_data_test.bzl
::absl::string_view tests_cc_embed_data_test_bzl() {
  static ::absl::string_view ret{&_binary_tests_cc_embed_data_test_bzl_start,
    ::absl::string_view::size_type(
        &_binary_tests_cc_embed_data_test_bzl_end -
        &_binary_tests_cc_embed_data_test_bzl_start)};
  return ret;
}

// bazel-out/k8-fastbuild/bin/tests/gen_detex.txt
::absl::string_view tests_gen_detex_txt() {
  static ::absl::string_view ret{&_binary_bazel_out_k8_fastbuild_bin_tests_gen_detex_txt_start,
    ::absl::string_view::size_type(
        &_binary_bazel_out_k8_fastbuild_bin_tests_gen_detex_txt_end -
        &_binary_bazel_out_k8_fastbuild_bin_tests_gen_detex_txt_start)};
  return ret;
}

// tests/testdata/nested.txt
::absl::string_view tests_testdata_nested_txt() {
  static ::absl::string_view ret{&_binary_tests_testdata_nested_txt_start,
    ::absl::string_view::size_type(
        &_binary_tests_testdata_nested_txt_end -
        &_binary_tests_testdata_nested_txt_start)};
  return ret;
}

// external/bazel_skylib/LICENSE
::absl::string_view LICENSE() {
  static ::absl::string_view ret{&_binary_external_bazel_skylib_LICENSE_start,
    ::absl::string_view::size_type(
        &_binary_external_bazel_skylib_LICENSE_end -
        &_binary_external_bazel_skylib_LICENSE_start)};
  return ret;
}

// external/bazel_tools/tools/genrule/genrule-setup.sh
::absl::string_view tools_genrule_genrule_setup_sh() {
  static ::absl::string_view ret{&_binary_external_bazel_tools_tools_genrule_genrule_setup_sh_start,
    ::absl::string_view::size_type(
        &_binary_external_bazel_tools_tools_genrule_genrule_setup_sh_end -
        &_binary_external_bazel_tools_tools_genrule_genrule_setup_sh_start)};
  return ret;
}

using EmbeddedIndex = absl::Span<std::pair<absl::string_view, absl::string_view>>;
EmbeddedIndex EmbedIndex() {
  static std::pair<absl::string_view, absl::string_view> kRet[] = {
    {"tests/cc_embed_data_test.bzl", tests_cc_embed_data_test_bzl()},
    {"tests/gen_detex.txt", tests_gen_detex_txt()},
    {"tests/testdata/nested.txt", tests_testdata_nested_txt()},
    {"LICENSE", LICENSE()},
    {"tools/genrule/genrule-setup.sh", tools_genrule_genrule_setup_sh()},
  };
  return EmbeddedIndex{kRet, 5};
}

EmbeddedIndex OriginMap() {
  static std::pair<absl::string_view, absl::string_view> kRet[] = {
    {"tests/cc_embed_data_test.bzl", "tests/cc_embed_data_test.bzl"},
    {"tests/gen_detex.txt", "tests/gen_detex.txt"},
    {"tests/testdata/nested.txt", "tests/testdata/nested.txt"},
    {"LICENSE", "external/bazel_skylib/LICENSE"},
    {"tools/genrule/genrule-setup.sh", "external/bazel_tools/tools/genrule/genrule-setup.sh"},
  };
  return EmbeddedIndex{kRet, 5};
}

}  // namespace test_ns
// Done

