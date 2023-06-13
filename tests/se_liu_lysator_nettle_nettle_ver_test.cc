#include "gtest/gtest.h"
#include "nettle/version.h"

namespace {

TEST(NetTLETest, Version) {
  EXPECT_EQ(NETTLE_VERSION_MAJOR, 3);
  EXPECT_EQ(NETTLE_VERSION_MINOR, 8);
  EXPECT_EQ(NETTLE_VERSION_MAJOR, nettle_version_major());
  EXPECT_EQ(NETTLE_VERSION_MINOR, nettle_version_minor());
}

}  // namespace
