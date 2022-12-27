// Copyright (c) 2018, Benjamin Shropshire,
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
#include "absl/strings/str_cat.h"
#include "absl/strings/str_replace.h"
#include "absl/strings/strip.h"
#include "json/json.h"

ABSL_FLAG(std::string, cc, "", "The generated source");
ABSL_FLAG(std::string, h, "", "The generated header");

ABSL_FLAG(std::string, gendir, "", "The $(GENDIR) directory used by blaze");
ABSL_FLAG(std::string, workspace, "", "The named of the WORKSPACE in use");
ABSL_FLAG(std::string, namespace, "", "The C++ namespace to put the API in.");
ABSL_FLAG(std::string, symbol_prefix, "",
          "The prefix of the linker generated globals.");
ABSL_FLAG(std::string, json_manifest, "", "The set of files to generate for.");

struct Item {
  std::string file_name;
  std::string file_path;
  std::string file_src;
  std::string var_name;
  std::string symbol_name;
};

std::optional<std::vector<Item>> Load() {
  std::vector<Item> items;

  Json::Value json_manifest;
  // OPEN
  std::ifstream json;
  json.open(absl::GetFlag(FLAGS_json_manifest), std::ios::in);
  if (!json.is_open()) {
    std::cerr << "failed to read json_manifest: " << absl::GetFlag(FLAGS_json_manifest) << "\n";
    return std::nullopt;
  }

  // READ
  Json::CharReaderBuilder rbuilder;
  rbuilder["collectComments"] = false;
  std::string errs;
  if (!Json::parseFromStream(rbuilder, json, &json_manifest, &errs)) {
    std::cerr << "ERROR parsing  " << absl::GetFlag(FLAGS_json_manifest) << "\n" << errs;
    return std::nullopt;
  }

  // CONSUME
  for (const auto &i : json_manifest) {
    // VALIDATE
    if (!i.isMember("name")) {
      std::cerr << "Missing `name` on json_manifest node.\n";
      return std::nullopt;
    }
    if (!i["name"].isString()) {
      std::cerr << "Expect string for `name` on json_manifest node.\n";
      return std::nullopt;
    }
    std::string name = i["name"].asString();

    if (!i.isMember("path")) {
      std::cerr << "Missing `paths` on json_manifest node.\n";
      return std::nullopt;
    }
    if (!i["path"].isString()) {
      std::cerr << "Expect string for `path` on json_manifest node.\n";
      return std::nullopt;
    }
    std::string path = i["path"].asString();

    if (!i.isMember("src")) {
      std::cerr << "Missing `paths` on json_manifest node.\n";
      return std::nullopt;
    }
    if (!i["src"].isString()) {
      std::cerr << "Expect string for `src` on json_manifest node.\n";
      return std::nullopt;
    }
    std::string src = i["src"].asString();

    // Things needed to turn a path into a symbol name.
    static const std::vector<std::pair<absl::string_view, absl::string_view>> rep = {
        {"/", "_"}, {".", "_"}, {"-", "_"}  //
    };

    items.emplace_back(Item{
        name,
        path,
        src,
        absl::StrReplaceAll(name, rep),
        absl::StrCat("_binary_", absl::StrReplaceAll(path, rep), "_"),
    });

  }
  return std::move(items);
}


int main(int argc, char** argv) {
  auto args = absl::ParseCommandLine(argc, argv);

  std::ofstream cc, h;
  cc.open(absl::GetFlag(FLAGS_cc), std::ios::out);
  if (cc.fail()) {
    std::cerr << absl::GetFlag(FLAGS_cc) << ": " << std::strerror(errno);
    return 1;
  }

  h.open(absl::GetFlag(FLAGS_h), std::ios::out);
  if (h.fail()) {
    std::cerr << absl::GetFlag(FLAGS_h) << ": " << std::strerror(errno);
    return 1;
  }

  auto items_or = Load();
  if (!items_or) return 1;
  auto items = std::move(*items_or);

  // Set up using a namespace is requested.
  std::string ns_open, ns_close;
  if (!absl::GetFlag(FLAGS_namespace).empty()) {
    std::cerr << "Using " << absl::GetFlag(FLAGS_namespace) << "\n";
    ns_open =
        absl::StrCat("namespace ", absl::GetFlag(FLAGS_namespace), " {\n");
    ns_close =
        absl::StrCat("}  // namespace ", absl::GetFlag(FLAGS_namespace), "\n");
  }

  constexpr char header[] = R"(// Generated code.
#include "absl/strings/string_view.h"
#include "absl/types/span.h"

)";
  constexpr char decl[] = R"(EmbeddedIndex EmbedIndex())";
  constexpr char type[] = "using EmbeddedIndex = absl::Span<std::pair<absl::string_view, absl::string_view>>";
  constexpr char map_decl[] = R"(EmbeddedIndex OriginMap())";

  /////// The header.
  h << header << ns_open;
  for (const auto& item : items) {
    h << "// " << item.file_path << "\n"
      << "::absl::string_view " << item.var_name << "();\n\n";
  }
  if (!absl::GetFlag(FLAGS_namespace).empty()) {
    h << type << ";\n\n";
    h << "// Map from file names to their contents.\n"
      << decl << ";\n";
    h << "// Map from file names to their 'original' paths.\n"
      << map_decl << ";\n\n";
  }
  h << ns_close << "// Done\n\n";

  /////// The implementation.
  cc << header << "/////// linker provided globals\n\n";
  for (const auto& item : items) {
    cc << "// " << item.file_path << "\n"
       << "extern const char " << item.symbol_name << "start;\n"
       << "extern const char " << item.symbol_name << "end;\n";
  }

  cc << "\n/////// Getter functions.\n" << ns_open << "\n";

  for (const auto& item : items) {
    cc << "// " << item.file_path << "\n"
       << "::absl::string_view " << item.var_name << "() {\n"
       << "  static ::absl::string_view ret{&" << item.symbol_name << "start,\n"
       << "    ::absl::string_view::size_type(\n"
       << "        &" << item.symbol_name << "end -\n"
       << "        &" << item.symbol_name << "start)};\n"
       << "  return ret;\n"
       << "}\n\n";
  }

  if (!absl::GetFlag(FLAGS_namespace).empty()) {
    cc << type << ";\n";
    cc << decl << R"( {
  static std::pair<absl::string_view, absl::string_view> kRet[] = {
)";

    for (const auto& item : items) {
      cc << "    {\"" << item.file_name << "\", " << item.var_name << "()},\n";
    }
    cc << "  };\n"
       << "  return EmbeddedIndex{kRet, " << items.size() << "};\n"
       << "}\n\n";

    cc << map_decl << R"( {
  static std::pair<absl::string_view, absl::string_view> kRet[] = {
)";
    for (const auto& item : items) {
      cc << "    {\"" << item.file_name << "\", \"" << item.file_src << "\"},\n";
    }
    cc << "  };\n"
       << "  return EmbeddedIndex{kRet, " << items.size() << "};\n"
       << "}\n\n";
  }

  cc << ns_close << "// Done\n\n";

  return 0;
}