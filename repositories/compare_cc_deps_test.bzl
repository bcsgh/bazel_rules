def _compare_cc_deps_test_impl(ctx):
    WS = ctx.attr.glob[0].files.to_list()[0].owner.workspace_name

    #print(WS)
    files = [
        f
        for f in depset(transitive = [s.files for s in ctx.attr.glob]).to_list()
        if WS == f.owner.workspace_name
    ]
    #print("FILES", len(ctx.attr.glob), len(files))

    headers = [
        h
        for h in depset(transitive = [x[CcInfo].compilation_context.headers for x in ctx.attr.hdrs]).to_list()
        if WS == h.owner.workspace_name
    ]
    #print("HEADEARS", len(ctx.attr.hdrs), len(headers))

    sources = [
        s
        for s in depset(transitive = [x.files for x in ctx.attr.srcs]).to_list()
        if WS == s.owner.workspace_name
    ]
    #print("SOURCES", len(ctx.attr.srcs), len(sources))

    #print(len(files), "?=", len(headers) + len(sources), "=", len(headers), "+", len(sources))

    side_f = dict([(k, 0) for k in files])
    side_r = dict([(k, 0) for k in headers + sources])

    only_f = [x for x in side_f.keys() if x not in side_r]
    only_r = [x for x in side_r.keys() if x not in side_f]
    only_r = []  ### Disable this

    MSG = ["#!/bin/sh", "cat >&2 << EOF"]

    if only_f:
        print("Will error: missing %s files" % len(only_f))
        MSG += ["Files not found in Deps:\n"]
        MSG += [
            "%s %s" % (f.owner.workspace_name, f.owner.name)
            for f in only_f
        ]
        MSG += ["\n"]

    if only_r:
        print("Will error: missing %s deps" % len(only_r))
        MSG += ["Deps not found in Files:\n"]
        MSG += [
            "%s %s" % (f.owner.workspace_name, f.owner.name)
            for f in only_r
        ]
        MSG += ["\n"]

    exe = ctx.actions.declare_file("%s.script" % ctx.label.name)

    if only_f or only_r:
        MSG += ["EOF", "exit 1"]

        ctx.actions.write(exe, "\n".join(MSG), is_executable = True)
        #fail("Missing files!")

    else:
        ctx.actions.write(exe, "", is_executable = True)

    return DefaultInfo(executable = exe)

compare_cc_deps_test = rule(
    implementation = _compare_cc_deps_test_impl,
    test = True,
    attrs = {
        "glob": attr.label_list(allow_files = True),
        "hdrs": attr.label_list(providers = [CcInfo]),
        "srcs": attr.label_list(providers = []),
    },
)
