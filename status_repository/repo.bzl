# Copyright (c) 2023, Benjamin Shropshire,
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

_STATUS_REPO_BUILD_TPL = """
load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo", "string_setting")
"""

_GIT_COMMIT_SETTING = """
string_setting(
    name = "git-commit",
    build_setting_default = "{commit}",
    visibility = ["//visibility:public"],
)
"""

def _status_repository_impl(ctx):
    BUILD = [_STATUS_REPO_BUILD_TPL]

    git = ctx.which("git")
    if git:
        HEAD = ctx.execute([git, "-C", ctx.workspace_root, "rev-parse", "HEAD"])
        if 0 == HEAD.return_code:
            BUILD += [_GIT_COMMIT_SETTING.format(commit = HEAD.stdout.strip())]

    ctx.file("BUILD", "\n\n".join(BUILD))

    return


status_repository = repository_rule(
    doc = """Create a repository that contains bits of information collected
       from the workspace that's not otherwise avalable to build rules.

       This infromation is exposed via "setting" rules.
       In general, values that don't exist or can't be found in the current context are not generated.

       - `//:git-commit`: The current git commit.
    """,

    implementation = _status_repository_impl,
    local = True,
    configure = True,
)
