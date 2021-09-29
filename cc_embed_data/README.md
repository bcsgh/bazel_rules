# `cc_embed_data`


## Example:

### `src/BUILD`
```
load("//cc_embed_data:cc_embed_data.bzl", "cc_embed_data")

cc_embed_data(
    name = "cc_embed_example",
    srcs = [
      "foo.bin",
      #...
    ],
    namespace = "my_namespace",
)


cc_test(
    name = "cc_embed_example_usage",
    srcs = ["cc_embed_example_usage.cc"],
    data = SRCS,
    deps = [
        ":cc_embed_example",
        "@com_google_googletest//:gtest_main",
    ],
)

```

### `src/cc_embed_example_usage.cc`

```
#include <string_view>

#include "cc_embed_example_data.h"

void Use(std::string_view);
void Use(std::string_view, std::string_view);

int main() {
  // find one
  Use(my_namespace::src_foo_bin());

  // find all
  for (const auto& i : my_namespace::EmbedIndex()) {
    Use(i.first, i.second);
  }
  
  return 0;
}

```
