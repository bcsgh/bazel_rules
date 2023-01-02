load("@bazel_rules//repositories:repositories.bzl", "jsoncpp", "load_skylib", "load_absl")

def get_deps():
    "A WORKSPACE macro to set up the external dependencies of cc_embed_data()."
    load_skylib()
    load_absl()
    jsoncpp()

