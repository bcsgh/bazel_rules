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

#include "absl/flags/flag.h"
#include "absl/flags/parse.h"
#include "proto_api/api.pb.h"

namespace api = proto_api::pb;

void CC(std::ostream& out) {
  out << R"CC(#ifndef BOILER_ENDPOINT_H_
#define BOILER_ENDPOINT_H_

// GENERATED CODE -- DO NOT EDIT!

namespace http_boiler_api {
)CC";

  auto *root = google::protobuf::GetEnumDescriptor<api::Endpoint>()->file();
  for (int i = 0, j = root->enum_type_count(); i < j; i++) {
    auto *desc = root->enum_type(i);
    out << "struct " << desc->name() << " {\n";
    std::vector<std::string> all;
    for (int i = 0; i < desc->value_count(); i++) {
      auto *val = desc->value(i);
      auto url = val->options().GetExtension(api::target_url);
      if (url.empty()) continue;
      all.emplace_back(val->name());
      out << "  static constexpr const char* " << val->name() << " = \"" << url << "\";\n";
    }
    out << "  static constexpr const char* ALL[] = {";
    for (const auto &e : all) out << e << ", ";
    out << "};\n};\n";
  }

  out << R"CC(
}  // namespace http_boiler_api
#endif //  BOILER_ENDPOINT_H_
)CC";
}

void CC(const std::string& path) {
  if (path == "") return;
  std::ofstream out(path);
  if (out) CC(out);
}

void JS(std::ostream& out) {
  out << R"JS(/**
 * @fileoverview Map a proto enum with custom options into JS
 * @public
 */
/* eslint-disable */

// GENERATED CODE -- DO NOT EDIT!

goog.module('Boiler.Endpoints');

exports = {
)JS";

  auto *root = google::protobuf::GetEnumDescriptor<api::Endpoint>();
  for (int i = 0, j = root->file()->enum_type_count(); i < j; i++) {
    auto *desc = root->file()->enum_type(i);
    out << "  " << desc->name() << ": {\n";
    for (int i = 0; i < desc->value_count(); i++) {
      auto *val = desc->value(i);
      auto url = val->options().GetExtension(api::target_url);
      if (url.empty()) continue;
      out << "    " << val->name() << ": '" << url << "',\n";
    }
    out << "  },\n";
  }

  out << R"JS(
};

// DONE
)JS";
}

void JS(const std::string& path) {
  if (path == "") return;
  std::ofstream out(path);
  if (out) JS(out);
}

ABSL_FLAG(std::string, js, "", "");
ABSL_FLAG(std::string, h, "", "");

int main(int argc, char **argv) {
  auto args = absl::ParseCommandLine(argc, argv);

  JS(absl::GetFlag(FLAGS_js));
  CC(absl::GetFlag(FLAGS_h));

  return 0;
}
