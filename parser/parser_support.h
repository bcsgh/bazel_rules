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

#ifndef PARSER_PARSER_SUPPORT_H_
#define PARSER_PARSER_SUPPORT_H_

#include <functional>
#include <string>

namespace parser_support {

// A state object passed to the lexer and parser.
// For the lexer, use ${yy}set_extra/${yy}get_extra
// For the paser use %parse-param
struct ScannerExtra {
  // The file name being handled.
  std::string* filename;
  // The sink for output from the generated code.
  std::function<void(const std::string&)> outp;
};

// Print an error message to STDEFF
// Args:
//  filename:
//  bl: begin line number
//  bc: begin column number
//  el: end line number
//  ec: end column number
//  msg: an arbitrary message.
void Error(const std::string* filename, int bl, int bc, int el, int ec,
           const std::string& msg, const ScannerExtra* e);

template <class L>
void Error(L const& loc, std::string const& msg, const ScannerExtra* e) {
  Error(loc.begin.filename, loc.begin.line, loc.begin.column, loc.end.line,
        loc.end.column, msg, e);
}

}  // namespace parser_support

#endif  // PARSER_PARSER_SUPPORT_H_
