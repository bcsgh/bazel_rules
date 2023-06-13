#include "ev.h"
#include "gtest/gtest.h"

namespace {

TEST(LibEVTest, Version) {
  EXPECT_EQ(ev_version_major(), 4);
  EXPECT_EQ(ev_version_minor(), 22);

  EXPECT_EQ(ev_version_major(), EV_VERSION_MAJOR);
  EXPECT_EQ(ev_version_minor(), EV_VERSION_MINOR);
}

}  // namespace
