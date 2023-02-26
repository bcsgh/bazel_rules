load("//repositories:repositories.bzl", "load_skylib", "load_absl")

def get_deps():
    load_skylib()
    load_absl()

def gen_proto_api(name, proto=None, js=None, h=None):
    native.genrule(
        name = name,
        srcs = [proto],
        outs = [js, h],
        cmd = " ".join([
            "$(location @bazel_rules//proto_api:gen_metadata_tool)",
            "--src=$(location %s)" % proto,
            "--js=$(location %s)" % js,
            "--h=$(location %s)" % h,
        ]),
        tools = ["@bazel_rules//proto_api:gen_metadata_tool"],
    )
