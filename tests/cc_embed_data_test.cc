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
#include <string>
#include <vector>

#include "gtest/gtest.h"
#include "tests/cc_embed_data_example_emebed_data.h"

namespace {

std::string ReadFile(const std::string &path) {
  std::ifstream ifs{path.c_str(),
                    std::ios::in | std::ios::binary | std::ios::ate};

  std::string::size_type size = ifs.tellg();
  ifs.seekg(0, std::ios::beg);

  std::string ret(size, '\0');
  ifs.read(&*ret.begin(), size);
  return ret;
}

TEST(CcEmbedData, Basic) {
  EXPECT_EQ(ReadFile("tests/BUILD"),
            ::tests_BUILD());

  EXPECT_EQ(ReadFile("tests/cc_embed_data_test.cc"),
            ::tests_cc_embed_data_test_cc());

  EXPECT_EQ(ReadFile("tests/gen.lexer.h"),
            ::tests_gen_lexer_h());

  EXPECT_EQ(ReadFile("tests/gen_dot_test.dot"),
            ::tests_gen_dot_test_dot());

  EXPECT_EQ(ReadFile("tests/lexer.l"),
            ::tests_lexer_l());

  EXPECT_EQ(ReadFile("tests/parser.y"),
            ::tests_parser_y());
}

}  // namespace
