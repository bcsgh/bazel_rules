load("//repositories:repositories.bzl", "jsoncpp", "load_skylib", "load_absl")

def get_deps():
    "A WORKSPACE macro to set up the external dependencies of css_class_names_js()."
    load_skylib()
    load_absl()
    jsoncpp()
