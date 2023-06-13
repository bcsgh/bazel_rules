#include "curl/curl.h"
#include "gtest/gtest.h"

namespace {

TEST(CurlTest, Version) {
  const auto *data = curl_version_info(CURLVERSION_NOW);

  EXPECT_STREQ("7.86.1-DEV", data->version);
}

}  // namespace
