# Copyright (c) 2018, Benjamin Shropshire,
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
# 3. Neither the name of the copyright holder nor the names of its contributors
#    may be used to endorse or promote products derived from this software
#    without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

# implementation from:
# https://stackoverflow.com/a/7779766/1343
# http://www.math.utah.edu/docs/info/ld_2.html
# https://gcc.gnu.org/onlinedocs/gcc/Link-Options.html

"""
A Bazel/skylark rule for embedding files from the build environment into the
data section of a binary and making them accessible as a library.

This allows placing large test or binary artifacts to come from faw files (or
other build artifacts) rather than deal with escaping them into string literals.
"""

load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain", "use_cpp_toolchain")
load("@rules_cc//cc:action_names.bzl", "CPP_COMPILE_ACTION_NAME", "CPP_LINK_STATIC_LIBRARY_ACTION_NAME")

_ALLOWED = ("0123456789" +
            "ABCDEFGHIJKLMNOPQRSTUVWXYZ" +
            "abcdefghijklmnopqrstuvwxyz")

def _Clean(p):
    return "".join([
        p[c] if p[c] in _ALLOWED else "_"
        for c in range(len(p))
    ])

DISABLED_FEATURES = [
    "module_maps",  ## WHY?
]

def _Fallback(out, alt):
    if out:
        return out.basename
    else:
        return alt

def _cc_embed_data_impl(ctx):
    if not ctx.attr.srcs and not ctx.attr.deps: fail("One of srcs or deps must be non-empty")
    if ctx.attr.srcs and ctx.attr.deps: fail("Only one of srcs or deps may be non-empty")

    cc_toolchain = find_cpp_toolchain(ctx)

    # Construct a manifest to generate from.
    # This allows passing structured data from the ctx to the generator.
    def Munge(s):
        name = s.path;
        r = s.owner.workspace_root + "/"
        if name[:len(r)] == r: name = name[len(r):]
        r = s.root.path + "/"
        if name[:len(r)] == r: name = name[len(r):]

        return struct(
            name = name,
            path = s.path,
            src = name if not s.is_source else s.path,
            is_output = not s.is_source,
        )

    def GetPath(target, path):
        for b in path.split("."): target = getattr(target, b)
        return target

    _json = ctx.actions.declare_file(_Fallback(ctx.outputs.json, ctx.label.name + "_emebed_data.json"))

    if ctx.files.srcs:
        process = list(ctx.files.srcs)

    if ctx.attr.deps:
        process = [
            s
            for t, k in ctx.attr.deps.items()
            for s in GetPath(t, k).to_list()
        ]

    ctx.actions.write(output=_json, content=json.encode([
        Munge(s) for s in process
    ]))

    cc = ctx.actions.declare_file(_Fallback(ctx.outputs.cc, ctx.label.name + "_emebed_data.cc"))
    h = ctx.actions.declare_file(_Fallback(ctx.outputs.h, ctx.label.name + "_emebed_data.h"))

    prefix = "%s_%s" % (_Clean(ctx.label.package), _Clean(ctx.label.name))

    gen_src_args = ctx.actions.args()
    gen_src_args.add("--json_manifest=%s" % _json.path)
    gen_src_args.add("--h=%s" % h.path)
    gen_src_args.add("--cc=%s" % cc.path)
    gen_src_args.add("--gendir=%s" % ctx.genfiles_dir.path)
    gen_src_args.add("--workspace=%s" % ctx.workspace_name)
    if ctx.attr.namespace: gen_src_args.add("--namespace=%s" % ctx.attr.namespace)
    gen_src_args.add("--symbol_prefix=%s" % prefix)

    ctx.actions.run(
        inputs=[_json],
        outputs=[cc, h],
        executable=ctx.file._make_emebed_data,
        arguments=[gen_src_args],
    )

    ######################
    bin_o = ctx.actions.declare_file(ctx.attr.name + "_emebed_data.o")

    pack_args = ctx.actions.args()
    pack_args.add("-o%s" % bin_o.path)  # Output file name
    pack_args.add("-r")                 # Make relocatable output (don't resolve stuff).
    pack_args.add("--format=binary")    # Just read in the files.

    pack_args.add_all([f.path for f in process])

    ctx.actions.run(
        inputs=depset(process),
        outputs=[bin_o],
        executable=cc_toolchain.ld_executable,
        arguments=[pack_args],
    )

    ######################
    # https://bazel.build/configure/integrate-cpp#implement-starlark-rules
    # https://github.com/bazelbuild/rules_cc/blob/main/examples/my_c_compile/my_c_compile.bzl

    feature_configuration = cc_common.configure_features(
        ctx = ctx,
        cc_toolchain = cc_toolchain,
        requested_features = ctx.features,
        unsupported_features = DISABLED_FEATURES + ctx.disabled_features,
    )

    src_o = ctx.actions.declare_file(ctx.attr.name + "_interface.o")

    c_compiler_path = cc_common.get_tool_for_action(
        feature_configuration = feature_configuration,
        action_name = CPP_COMPILE_ACTION_NAME,
    )
    c_compile_variables = cc_common.create_compile_variables(
        feature_configuration = feature_configuration,
        cc_toolchain = cc_toolchain,
        user_compile_flags = ctx.fragments.cpp.copts + ctx.fragments.cpp.cxxopts,
        source_file = cc.path,
        include_directories = depset(transitive=[
            dep[CcInfo].compilation_context.quote_includes
            for dep in ctx.attr._cc_deps
        ]),
        output_file = src_o.path,
    )
    command_line = cc_common.get_memory_inefficient_command_line(
        feature_configuration = feature_configuration,
        action_name = CPP_COMPILE_ACTION_NAME,
        variables = c_compile_variables,
    )
    env = cc_common.get_environment_variables(
        feature_configuration = feature_configuration,
        action_name = CPP_COMPILE_ACTION_NAME,
        variables = c_compile_variables,
    )

    ctx.actions.run(
        executable = c_compiler_path,
        arguments = command_line,
        env = env,
        inputs = depset(
            [cc],
            transitive = [cc_toolchain.all_files] + [
                dep[CcInfo].compilation_context.headers
                for dep in ctx.attr._cc_deps
            ],
        ),
        outputs = [src_o],
    )

    ######################
    # https://bazel.build/configure/integrate-cpp#implement-starlark-rules
    # https://github.com/bazelbuild/rules_cc/blob/main/examples/my_c_archive/my_c_archive.bzl

    output_lib = ctx.actions.declare_file(_Fallback(ctx.outputs.a, "lib%s.a" % ctx.label.name))

    linker_input = cc_common.create_linker_input(
        owner = ctx.label,
        libraries = depset(direct = [
            cc_common.create_library_to_link(
                actions = ctx.actions,
                feature_configuration = feature_configuration,
                cc_toolchain = cc_toolchain,
                static_library = output_lib,
            ),
        ]),
    )

    archiver_path = cc_common.get_tool_for_action(
        feature_configuration = feature_configuration,
        action_name = CPP_LINK_STATIC_LIBRARY_ACTION_NAME,
    )
    archiver_variables = cc_common.create_link_variables(
        feature_configuration = feature_configuration,
        cc_toolchain = cc_toolchain,
        output_file = output_lib.path,
        is_using_linker = False,
    )
    command_line = cc_common.get_memory_inefficient_command_line(
        feature_configuration = feature_configuration,
        action_name = CPP_LINK_STATIC_LIBRARY_ACTION_NAME,
        variables = archiver_variables,
    )
    archive_args = ctx.actions.args()
    archive_args.add_all(command_line)
    archive_args.add(src_o)
    archive_args.add(bin_o)

    env = cc_common.get_environment_variables(
        feature_configuration = feature_configuration,
        action_name = CPP_LINK_STATIC_LIBRARY_ACTION_NAME,
        variables = archiver_variables,
    )

    ctx.actions.run(
        executable = archiver_path,
        arguments = [archive_args],
        env = env,
        inputs = depset(
            direct = [src_o, bin_o],
            transitive = [
                cc_toolchain.all_files,
            ],
        ),
        outputs = [output_lib],
    )

    lib_info = CcInfo(
        compilation_context = cc_common.create_compilation_context(
            headers = depset(direct = [h]),
        ),
        linking_context = cc_common.create_linking_context(
            linker_inputs = depset(direct = [linker_input]),
        ),
    )

    ######################
    return [DefaultInfo(
        runfiles=ctx.runfiles(files = ctx.files.srcs + ctx.files.deps + ctx.files._make_emebed_data),
    ), cc_common.merge_cc_infos(
        cc_infos = [lib_info] + [dep[CcInfo] for dep in ctx.attr._cc_deps],
    )]

cc_embed_data = rule(
    doc = "Generate a library containing the contents of srcs.",

    implementation = _cc_embed_data_impl,
    attrs = {
        "namespace": attr.string(
            doc="If given, the C++ namespace to generate in.",
        ),
        "cc": attr.output(
            doc="The generated C++ source file. (This must be set for other rules to depend on individual output files.)",
        ),
        "h": attr.output(
            doc="The generated C++ header file. (This must be set for other rules to depend on individual output files.)",
        ),
        "a": attr.output(
            doc="The generated cc_library archive. (This must be set for other rules to depend on individual output files.)",
        ),
        "srcs": attr.label_list(
            doc="The files to embed.",
            allow_files=True,
        ),
        "deps": attr.label_keyed_string_dict(
            doc="""A map from build rules to embed to a path (e.g. "files") on
            the Target object that yeilds a depset of files. (Figuring out what
            this path should be more or less requiers mucking around with rule
            implementations. Sorry.)""",
        ),
        "json": attr.output(),
        "_make_emebed_data": attr.label(
            doc="The C++ file generater.",
            allow_single_file=True,
            default=":make_emebed_data",
        ),
        "_cc_toolchain": attr.label(  # used by find_cpp_toolchain()
            default = Label("@bazel_tools//tools/cpp:current_cc_toolchain"),
        ),
        "_cc_deps": attr.label_list(
            providers = [CcInfo],
            default = [
                "@com_google_absl//absl/strings",
                "@com_google_absl//absl/types:span",
            ],
        ),
    },
    fragments = ["cpp"],
    toolchains = use_cpp_toolchain(),
)
