#include "gmp.h"
#include "gtest/gtest.h"

namespace {

TEST(GMP, Version) {
  EXPECT_EQ(6, __GNU_MP_VERSION);
  EXPECT_EQ(2, __GNU_MP_VERSION_MINOR);
  EXPECT_EQ(1, __GNU_MP_VERSION_PATCHLEVEL);
  EXPECT_STREQ("6.2.1", gmp_version);
}

}  // namespace
