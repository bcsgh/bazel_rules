#include "gtest/gtest.h"
#include "zlib.h"

namespace {

TEST(ZLibTest, Version) {
  EXPECT_STREQ("1.2.11", ZLIB_VERSION);
}

}  // namespace
