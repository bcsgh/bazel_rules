// Generated code.
#include "absl/strings/string_view.h"
#include "absl/types/span.h"

/////// linker provided globals

// tests/cc_embed_data_test.bzl
extern const char _binary_tests_cc_embed_data_short_0_start;
extern const char _binary_tests_cc_embed_data_short_0_end;
// tests/gen_detex.txt
extern const char _binary_tests_cc_embed_data_short_1_start;
extern const char _binary_tests_cc_embed_data_short_1_end;

/////// Getter functions.
namespace test_ns {

// tests/cc_embed_data_test.bzl
::absl::string_view tests_cc_embed_data_test_bzl() {
  static ::absl::string_view ret{&_binary_tests_cc_embed_data_short_0_start,
    ::absl::string_view::size_type(
        &_binary_tests_cc_embed_data_short_0_end -
        &_binary_tests_cc_embed_data_short_0_start)};
  return ret;
}

// tests/gen_detex.txt
::absl::string_view tests_gen_detex_txt() {
  static ::absl::string_view ret{&_binary_tests_cc_embed_data_short_1_start,
    ::absl::string_view::size_type(
        &_binary_tests_cc_embed_data_short_1_end -
        &_binary_tests_cc_embed_data_short_1_start)};
  return ret;
}

using EmbeddedIndex = absl::Span<std::pair<absl::string_view, absl::string_view>>;
EmbeddedIndex EmbedIndex() {
  static std::pair<absl::string_view, absl::string_view> kRet[] = {
    {"tests/cc_embed_data_test.bzl", tests_cc_embed_data_test_bzl()},
    {"tests/gen_detex.txt", tests_gen_detex_txt()},
  };
  return EmbeddedIndex{kRet, 2};
}

}  // namespace test_ns
// Done

