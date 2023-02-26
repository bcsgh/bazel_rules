#ifndef BOILER_ENDPOINT_H_
#define BOILER_ENDPOINT_H_

// GENERATED CODE -- DO NOT EDIT!

namespace http_boiler_api {
struct Endpoint {
  static constexpr const char* JSON = "/json";
  static constexpr const char* ALL[] = {JSON, };
};
struct StaticEndpoint {
  static constexpr const char* ROOT = "/";
  static constexpr const char* MAIN_JS = "/main.js";
  static constexpr const char* ALL[] = {ROOT, MAIN_JS, };
};

}  // namespace http_boiler_api
#endif //  BOILER_ENDPOINT_H_
