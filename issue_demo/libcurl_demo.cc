#include <iostream>
#include <string>

#include "absl/cleanup/cleanup.h"
#include "absl/strings/str_cat.h"
#include "curl/curl.h"

using CurlWrietCallback = size_t (*)(char *, size_t , size_t , void *);

int main(int argc, char **argv) {
  curl_global_init(CURL_GLOBAL_ALL);
  absl::Cleanup curl_cleanup = [] {
    curl_global_cleanup();
  };

  CURL *curl_handle = curl_easy_init();
  if(!curl_handle) return 1;
  absl::Cleanup handle_cleanup = [&curl_handle] {
    curl_easy_cleanup(curl_handle);
  };

  curl_version_info_data *vinfo = curl_version_info( CURLVERSION_NOW );
  std::cout << "Ver: " << vinfo->version << "\n";

  std::cout << "SSL?: " << bool(vinfo->features & CURL_VERSION_SSL) << "\n";
  std::cout << "*SSL?: " << bool(vinfo->features & CURL_VERSION_MULTI_SSL) << "\n";
  if (vinfo->features & CURL_VERSION_SSL) std::cout << "SSL ver: " << vinfo->ssl_version << "\n";

  for (auto p = vinfo->protocols ; *p ; p++) std::cout << std::string{*p} << "\n";

  CurlWrietCallback callback = +[](char *in, size_t s, size_t c, void *o) -> size_t {
    size_t realsize = s * c;
    std::cerr << ">" << realsize << "\n";
    std::string* buff = static_cast<std::string*>(o);
    absl::StrAppend(buff, std::string_view{in, realsize});
    return realsize;
  };
  std::string chunk;

  curl_easy_setopt(curl_handle, CURLOPT_URL, "https://example.com");
  curl_easy_setopt(curl_handle, CURLOPT_FOLLOWLOCATION, 1L);
  curl_easy_setopt(curl_handle, CURLOPT_WRITEFUNCTION, callback);
  curl_easy_setopt(curl_handle, CURLOPT_WRITEDATA, (void *)&chunk);
  curl_easy_setopt(curl_handle, CURLOPT_USERAGENT, "libcurl-agent/1.0");
  curl_easy_setopt(curl_handle, CURLOPT_SSLCERTTYPE, "PEM");
  curl_easy_setopt(curl_handle, CURLOPT_SSL_VERIFYPEER, 1L);

  CURLcode res = curl_easy_perform(curl_handle);

  if(res != CURLE_OK) {
    std::cerr << "error: " << curl_easy_strerror(res) << std::endl;
  } else {
    std::cout << "Size: " <<  chunk.size() << "\n" << "Data: " << chunk << std::endl;
  }

  return 0;
}
