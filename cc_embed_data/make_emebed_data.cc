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

#include "absl/strings/str_cat.h"
#include "absl/strings/str_replace.h"
#include "absl/strings/strip.h"
#include "gflags/gflags.h"

DEFINE_string(cc, "", "The generated source");
DEFINE_string(h, "", "The generated header");

DEFINE_string(gendir, "", "The $(GENDIR) directory used by blaze");
DEFINE_string(workspace, "", "The named of the WORKSPACE in use");
DEFINE_string(namespace, "", "The C++ namespace to put the API in.");

int main(int argc, char** argv) {
  gflags::ParseCommandLineFlags(&argc, &argv, true);

  std::ofstream cc, h;
  cc.open(FLAGS_cc, std::ios::out);
  if(cc.fail()) {
    std::cerr << FLAGS_cc << ": " << std::strerror(errno);
    return 1;
  }

  h.open(FLAGS_h, std::ios::out);
  if(h.fail()) {
    std::cerr << FLAGS_h << ": " << std::strerror(errno);
    return 1;
  }

  struct Item {
    absl::string_view file_name;
    std::string var_name;
    std::string symbol_name;
  };
  std::vector<Item> items;

  // Generate the names:
  for(int i = 1; i < argc; i++) {
    // Things needed to turn a path into a symbol name.
    const std::vector<std::pair<absl::string_view, absl::string_view>> rep = {
      {"/", "_"}, {".", "_"}, {"-", "_"}
    };

    // The generated object file is from the original names.
    std::string var_name = absl::StrReplaceAll(argv[i], rep);

    // Do a bunch of magic to get the workspace relative path.
    // This is complicated by generated file being in a different places
    // and by the paths changing for the tools vs. result builds.
    absl::string_view file_name = argv[i];
    absl::ConsumePrefix(&file_name, FLAGS_gendir);
    absl::ConsumePrefix(&file_name, "/");
    absl::ConsumePrefix(&file_name, absl::StrCat("external/", FLAGS_workspace, "/"));

    items.emplace_back(Item{
      file_name,
      absl::StrReplaceAll(file_name, rep),
      absl::StrCat("_binary_src_", (i-1), "_"),
    });
  }

  // Set up using a namespace is requested.
  std::string ns_open, ns_close;
  if (!FLAGS_namespace.empty()) {
    std::cerr << "Using " << FLAGS_namespace << "\n";
    ns_open = absl::StrCat("namespace ", FLAGS_namespace, " {\n");
    ns_close = absl::StrCat("}  // namespace ", FLAGS_namespace, "\n");
  }

  auto header = R"(// Generated code.
#include "absl/strings/string_view.h"

)";

  /////// The header.
  h << header << ns_open;
  for (const auto& item : items) {
    h << "// " << item.file_name << "\n"
      << "::absl::string_view " << item.var_name << "();\n\n";
  }
  h << ns_close << "// Done\n\n";

  /////// The implementation.
  cc << header << "/////// linker provided globals\n\n";
  for (const auto& item : items) {
    cc << "// " << item.file_name << "\n"
       << "extern const char " << item.symbol_name << "start;\n"
       << "extern const char " << item.symbol_name << "end;\n";
  }

  cc << "\n/////// Getter functions.\n" << ns_open << "\n";

  for (const auto& item : items) {
    cc << "// " << item.file_name << "\n"
       << "::absl::string_view " << item.var_name << "() {\n"
       << "  static ::absl::string_view ret{&" << item.symbol_name << "start,\n"
       << "    ::absl::string_view::size_type(\n"
       << "        &" << item.symbol_name << "end -\n"
       << "        &" << item.symbol_name << "start)};\n"
       << "  return ret;\n"
       << "}\n\n";
  }

  cc << ns_close << "// Done\n\n";

  return 0;
}