#include "Eigen/Dense"
#include "gtest/gtest.h"

namespace {

TEST(EigenTest, Version) {
  EXPECT_EQ(EIGEN_WORLD_VERSION, 3);
  EXPECT_EQ(EIGEN_MAJOR_VERSION, 4);
  EXPECT_EQ(EIGEN_MINOR_VERSION, 90);
}

}  // namespace
