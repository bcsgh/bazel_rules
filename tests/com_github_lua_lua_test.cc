#include <memory>

extern "C" {
#include "lauxlib.h"
#include "lua.h"
}

#include "gtest/gtest.h"

namespace {

TEST(LibLua, Version) {
  std::shared_ptr<lua_State> L{luaL_newstate(), &lua_close};
  EXPECT_EQ(505, lua_version(L.get()));
  EXPECT_EQ(LUA_VERSION_NUM, lua_version(L.get()));
}

}  // namespace
