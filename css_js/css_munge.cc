// Copyright (c) 2023, Benjamin Shropshire,
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
#include <vector>

#include "absl/flags/flag.h"
#include "absl/flags/parse.h"
#include "absl/log/initialize.h"
#include "absl/log/log.h"
#include "absl/memory/memory.h"
#include "absl/strings/ascii.h"
#include "absl/strings/str_join.h"
#include "absl/strings/str_replace.h"
#include "json/json.h"

ABSL_FLAG(std::string, json, "", "");
ABSL_FLAG(std::string, out, "", "");
ABSL_FLAG(std::string, module, "", "");
ABSL_FLAG(std::string, prefix, "", "");

constexpr auto kTemplate = R"JS(// Generated:

goog.module("<module>");

<vals>

exports = {
<json>
};

// DONE
)JS";

constexpr auto kDef = R"JS(const <name> = "<prefix><value>";)JS";

void JS(const std::string &mod, const std::string& prefix,
        Json::Value root, std::ostream* out) {
  std::vector<std::string> vals, maps;

  for (const auto &k : root.getMemberNames()) {
    const auto name = absl::AsciiStrToUpper(k);
    vals.emplace_back(absl::StrReplaceAll(kDef, {
      {"<name>", name},
      {"<prefix>", prefix},
      {"<value>", root[k].asString()},
    }));
    maps.emplace_back(absl::StrCat("  ", name, ","));
  }

  *out << absl::StrReplaceAll(kTemplate, {
    {"<module>", mod},
    {"<vals>", absl::StrJoin(vals, "\n")},
    {"<json>", absl::StrJoin(maps, "\n")},
  });
}

void JS(const std::string &mod, const std::string& prefix,
        const std::string& json, std::ostream* out) {
  Json::Value root;
  std::string err;
  LOG_IF(QFATAL, !absl::WrapUnique(Json::CharReaderBuilder().newCharReader())
      ->parse(json.c_str(), json.c_str() + json.size(), &root, &err))
    << err << "\n-----\n" << json;

  JS(mod, prefix, root, out);
}

/////////////////////////////////////////////////////////////////////
int main(int argc, char **argv) {
  auto args = absl::ParseCommandLine(argc, argv);
  absl::InitializeLog();

  LOG_IF(QFATAL, (absl::GetFlag(FLAGS_json) == "")) << "--json is requiered.";
  std::ifstream t(absl::GetFlag(FLAGS_json));
  LOG_IF(QFATAL, t.fail())
      << "Failed to open --json=" << absl::GetFlag(FLAGS_json)
      << " " << strerror(errno);

  std::stringstream b;
  b << t.rdbuf();
  std::string json = b.str();

  LOG_IF(QFATAL, (absl::GetFlag(FLAGS_out) == "")) << "--out is requiered.";
  std::ofstream out(absl::GetFlag(FLAGS_out));

  LOG_IF(QFATAL, (absl::GetFlag(FLAGS_module) == "")) << "--module is requiered.";

  JS(absl::GetFlag(FLAGS_module), absl::GetFlag(FLAGS_prefix), json, &out);

  return 0;
}
