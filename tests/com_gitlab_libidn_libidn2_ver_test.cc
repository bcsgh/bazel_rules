#include "gtest/gtest.h"
#include "idn2.h"

namespace {

TEST(LibIDNTest, Version) {
  EXPECT_STREQ(IDN2_VERSION, "2.3.4");
  EXPECT_STREQ(idn2_check_version(nullptr), IDN2_VERSION);
}

}  // namespace
