#include "gtest/gtest.h"
#include "json/json.h"

namespace {

TEST(JsonCppTest, Version) {
  EXPECT_STREQ("1.9.5", JSONCPP_VERSION_STRING);
}

}  // namespace
