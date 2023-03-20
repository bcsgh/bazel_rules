# Bazel CSS-to-JS constants rules.

This is a Bazel rule for converting from `closure_css_binary()` rules into a `closure_js_library()` that provides constant that provide the renamed CSS class names. This allows incorrect class names to be a build time error.

## Usage Pattern

The intended usage pattern for libraries that use this is as follows:

```
load("@io_bazel_rules_closure//closure:defs.bzl", "closure_js_library")
load("@io_bazel_rules_closure//closure/stylesheets:closure_css_binary.bzl", "closure_css_binary")
load("@io_bazel_rules_closure//closure/stylesheets:closure_css_library.bzl", "closure_css_library")
load("@bazel_rules//css_js:css_js.bzl", "css_class_names_js", "CSS_BINARY_MUNGE_DEFS")

## The CSS files that are needed by this JS library:
closure_css_library(
    name = "some_css",
    srcs = ["some.css"],
)

## Minify and rename stuff:
CSS_PREFIX = "something_"

closure_css_binary(
    name = "some_css_bin",
    deps = [":some_css"],
    defs = CSS_BINARY_MUNGE_DEFS + [
        "--css-renaming-prefix=" + CSS_PREFIX,
    ],
    visibility = ["//visibility:public"],
)

css_class_names_js(
    name = "some_css_js",
    css_binary = ":some_css_bin",
    module = "something.Css",
    prefix = CSS_PREFIX,
)

## The JS library
closure_js_library(
    name = "some_js",
    srcs = ["some.js"],
    deps = [
        ":css_js",
        # ...
    ],
    visibility = ["//visibility:public"],
)

```

The intended usage pattern for applications consuming the library is as follows:

```
load("@io_bazel_rules_closure//closure:defs.bzl", "closure_js_binary", "closure_js_library")
load("@io_bazel_rules_closure//closure/stylesheets:closure_css_binary.bzl", "closure_css_binary")
load("@io_bazel_rules_closure//closure/stylesheets:closure_css_library.bzl", "closure_css_library")
load("@bazel_rules//css_js:css_js.bzl", "css_class_names_js", "CSS_BINARY_MUNGE_DEFS")

## The CSS files that are needed by end user JS app:
closure_css_library(
    name = "local_css",
    srcs = ["local.css"],
)

## Minify and rename local stuff:
CSS_PREFIX = "local_"

closure_css_binary(
    name = "local_css_bin",
    deps = [":local_css"],
    defs = CSS_BINARY_MUNGE_DEFS + [
        "--css-renaming-prefix=" + CSS_PREFIX,
    ],
)

css_class_names_js(
    name = "local_css_js",
    css_binary = ":local_css_bin",
    module = "local.Css",
    prefix = CSS_PREFIX,
)

## The JS implementation.
closure_js_library(
    name = "local_js",
    srcs = ["local.js"],
    deps = [
        ":local_css_js",
        # ...
    ],
    visibility = ["//visibility:public"],
)

## Amagamate CSS stuff we depend on, but don't rename it (again).
closure_css_binary(
    name = "main_css_bin",
    deps = [
        "//lib:some_css_bin",
        # Any other libs ...
        ":local_css_bin",
    ],
    renaming = False,
    debug = select({":debug_build": True, "//conditions:default": False}),
)

closure_js_binary(
    name = "main_js_bin",
    entry_points = ["local.Start"],
    deps = [":local_js"],
)

## All the bits:
filegroup(
    name = "stuff",
    srcs = [
        "main_css_bin.css",
        "main_js_bin.js",
    ],
)
```