load("//repositories:repositories.bzl", "load_skylib", "load_absl")

def get_deps():
    load_skylib()
    load_absl()

def gen_proto_api(name, js=None, h=None):
    native.genrule(
        name = name,
        outs = [js, h],
        cmd = " ".join([
            "$(location @bazel_rules//proto_api:gen_metadata_tool)",
            "--js=$(location %s)" % js,
            "--h=$(location %s)" % h,
        ]),
        tools = ["@bazel_rules//proto_api:gen_metadata_tool"],
    )
