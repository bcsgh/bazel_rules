#include <memory>

#include "gtest/gtest.h"
#include "p11-kit/p11-kit.h"

namespace {
constexpr auto Free = [](auto *x) { free(x); };

TEST(P11Kit, Version) {
  // TODO https://github.com/p11-glue/p11-kit/issues/523 Add verions API

  auto **mods = p11_kit_modules_load(nullptr, 0);
  ASSERT_NE(mods, nullptr);

  for (auto **m = mods; *m; m++) {
    std::shared_ptr<char> name{p11_kit_module_get_name(*m), free};
    EXPECT_STREQ(name.get(), "p11-kit-trust");

    std::shared_ptr<char> opp{p11_kit_config_option(*m, "module"), free};
    EXPECT_STREQ(opp.get(), "p11-kit-trust.so");
  }
}

}  // namespace
