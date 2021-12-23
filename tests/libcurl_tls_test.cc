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

#include <iostream>
#include <set>
#include <string>

#include "absl/cleanup/cleanup.h"
#include "absl/strings/str_join.h"
#include "curl/curl.h"

// Test that TLS/SSL is supported by this build of CURL.

int main(int argc, char **argv) {
  curl_global_init(CURL_GLOBAL_ALL);
  absl::Cleanup curl_cleanup = curl_global_cleanup;

  curl_version_info_data *vinfo = curl_version_info(CURLVERSION_NOW);
  std::cout << "Ver: " << vinfo->version << "\n";

  bool ssl = vinfo->features & CURL_VERSION_SSL;
  if (!ssl) {
    std::cerr << "Missing SSL support\n";
  }

  std::set<std::string> protocols;
  for (auto p = vinfo->protocols; *p; p++) protocols.emplace(*p);

  if (protocols.find("https") == protocols.end()) {
    std::cerr << "https not included in supported protocols: ["
              << absl::StrJoin(protocols, ", ") << "]\n";
  }

  return (ssl) ? 0 : 1;
}
