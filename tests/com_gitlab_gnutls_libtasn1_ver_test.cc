#include "libtasn1.h"
#include "gtest/gtest.h"

namespace {

TEST(GnuTlsTest, Version) {
  EXPECT_STREQ(ASN1_VERSION, "4.19.0");
  EXPECT_STREQ(ASN1_VERSION, asn1_check_version(nullptr));
}

}  // namespace
