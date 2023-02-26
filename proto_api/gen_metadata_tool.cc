// Copyright (c) 2021, Benjamin Shropshire,
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// 1. Redistributions of source code must retain the above copyright notice,
//    this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.
// 3. Neither the name of the copyright holder nor the names of its contributors
//    may be used to endorse or promote products derived from this software
//    without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

#include <fstream>
#include <iostream>
#include <sstream>

#include "absl/flags/flag.h"
#include "absl/flags/parse.h"
#include "absl/strings/ascii.h"
#include "absl/strings/str_cat.h"
#include "absl/strings/str_replace.h"
#include "google/protobuf/descriptor.pb.h"
#include "proto_api/api_meta.pb.h"

ABSL_FLAG(std::string, src, "", "");
ABSL_FLAG(std::string, js, "", "");
ABSL_FLAG(std::string, js_module, "",
          "Override the goog.module to use in the JS file. "
          "(Generated from the proto c if not set here).");
ABSL_FLAG(std::string, h, "", "");
ABSL_FLAG(std::string, h_guard, "",
          "Override the include-guard to use in the C++ header file. "
          "(Generated from --h if not set here).");
ABSL_FLAG(std::string, h_namespace, "",
          "Override the namespace to use in the C++ header file. "
          "(Generated from the proto module if not set here).");

namespace api = proto_api::pb;
using google::protobuf::FileDescriptorProto;

void CC(const FileDescriptorProto* root, const std::string& path, std::ostream& out) {
  std::string include_guard;
  if (absl::GetFlag(FLAGS_h_guard) == "") {
    include_guard = absl::StrCat(absl::AsciiStrToUpper(path), "_");
  } else {
    include_guard = absl::GetFlag(FLAGS_h_guard);
  }
  for (auto& c : include_guard) {
    if (c != '_' && !absl::ascii_isalnum(c)) c = '_';
  }

  std::string ns;
  if (absl::GetFlag(FLAGS_h_namespace) == "") {
    ns = absl::StrCat(absl::StrReplaceAll(root->package(), {{".", "::"}}), "::gen_api");
  } else {
    ns = absl::GetFlag(FLAGS_h_namespace);
  }

  out << R"CC(#ifndef )CC" << include_guard << R"CC(
#define )CC" << include_guard << R"CC(

// GENERATED CODE -- DO NOT EDIT!

namespace )CC" << ns << R"CC( {

)CC";

  for (const auto &desc : root->enum_type()) {
    out << "struct " << desc.name() << " {\n";
    std::vector<std::string> all;
    for (const auto &val : desc.value()) {
      auto url = val.options().GetExtension(api::target_url);
      if (url.empty()) continue;
      all.emplace_back(val.name());
      out << "  static constexpr const char* " << val.name() << " = \"" << url << "\";\n";
    }
    out << "  static constexpr const char* ALL[] = {";
    for (const auto &e : all) out << e << ", ";
    out << "};\n};\n";
  }

  out << R"CC(
}  // namespace )CC" << ns << R"CC(

#endif //  )CC" << include_guard << R"CC(
)CC";
}

void CC(const FileDescriptorProto* root, const std::string& path) {
  if (path == "") return;
  std::ofstream out(path);
  if (out) CC(root, path, out);
}

void JS(const FileDescriptorProto* root, std::ostream& out) {
  std::string module;
  std::string ns;
  if (absl::GetFlag(FLAGS_js_module) == "") {
    module = absl::StrCat(root->package(), ".GenAPI");
  } else {
    module = absl::GetFlag(FLAGS_js_module);
  }

  out << R"JS(/**
 * @fileoverview Map a proto enum with custom options into JS
 * @public
 */
/* eslint-disable */

// GENERATED CODE -- DO NOT EDIT!

goog.module(')JS" << module << R"JS(');

exports = {
)JS";

  for (const auto &desc : root->enum_type()) {
    out << "  " << desc.name() << ": {\n";
    for (const auto &val : desc.value()) {
      auto url = val.options().GetExtension(api::target_url);
      if (url.empty()) continue;
      out << "    " << val.name() << ": '" << url << "',\n";
    }
    out << "  },\n";
  }

  out << R"JS(
};

// DONE
)JS";
}

void JS(const FileDescriptorProto* root, const std::string& path) {
  if (path == "") return;
  std::ofstream out(path);
  if (out) JS(root, out);
}

int main(int argc, char **argv) {
  auto args = absl::ParseCommandLine(argc, argv);

  if (absl::GetFlag(FLAGS_src) == "") {
    std::cerr << "--src is requiered\n" << std::flush;
    return 1;
  }

  std::ifstream t(absl::GetFlag(FLAGS_src));
  std::stringstream b;
  b << t.rdbuf();
  google::protobuf::FileDescriptorSet file;
  if (!file.ParseFromString(b.str())) {
    std::cerr << "--src is not a FileDescriptorSet\n" << std::flush;
    return 1;
  }

  if (file.file_size() != 1) {
    std::cerr << "--src contains " << file.file_size() << " files. Expected exactly 1.\n" << std::flush;
    return 1;
  }

  auto root = file.file(0);
  JS(&root, absl::GetFlag(FLAGS_js));
  CC(&root, absl::GetFlag(FLAGS_h));

  return 0;
}
