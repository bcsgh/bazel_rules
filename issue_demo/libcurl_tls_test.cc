#include <iostream>
#include <set>
#include <string>

#include "absl/cleanup/cleanup.h"
#include "absl/strings/str_join.h"
#include "curl/curl.h"

int main(int argc, char **argv) {
  curl_global_init(CURL_GLOBAL_ALL);
  absl::Cleanup curl_cleanup = [] {
    curl_global_cleanup();
  };

  curl_version_info_data *vinfo = curl_version_info( CURLVERSION_NOW );
  std::cout << "Ver: " << vinfo->version << "\n";

  bool ssl = vinfo->features & CURL_VERSION_SSL;
  if (!ssl) {
    std::cerr << "Missing SSL support\n";
  }

  std::set<std::string> protocols;
  for (auto p = vinfo->protocols ; *p ; p++) protocols.emplace(*p);

  if (protocols.find("https") == protocols.end()) {
    std::cerr << "https not included in supported protocols: ["
              << absl::StrJoin(protocols, ", ") << "]\n";
  }

  return (ssl) ? 0 : 1;
}