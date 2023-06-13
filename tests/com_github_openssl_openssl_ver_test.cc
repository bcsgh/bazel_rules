#include "gtest/gtest.h"
#include "openssl/opensslv.h"

namespace {

TEST(OpenSSLTest, Version) {
  EXPECT_EQ(OPENSSL_VERSION_MAJOR, 3);
  EXPECT_EQ(OPENSSL_VERSION_MINOR, 2);
  EXPECT_EQ(OPENSSL_VERSION_PATCH, 0);
}

}  // namespace
