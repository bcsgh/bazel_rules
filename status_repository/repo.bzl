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

_GIT_COMMIT_BZL = """
GIT = "{commit}"
"""

def _status_repository_impl(ctx):
    BUILD = [_STATUS_REPO_BUILD_TPL]
    BZL = []

    git = ctx.which("git")
    if git:
        HEAD = ctx.execute([git, "-C", ctx.workspace_root, "rev-parse", "HEAD"])
    else:
        HEAD = None

    if HEAD and 0 == HEAD.return_code:
        BUILD += [_GIT_COMMIT_SETTING.format(commit = HEAD.stdout.strip())]
        BZL += [_GIT_COMMIT_BZL.format(commit = HEAD.stdout.strip())]
    elif ctx.attr.alt_git_commit:
        BUILD += [_GIT_COMMIT_SETTING.format(commit = ctx.attr.alt_git_commit)]
        BZL += [_GIT_COMMIT_BZL.format(commit = ctx.attr.alt_git_commit)]
    ctx.file("BUILD", "\n\n".join(BUILD))
    ctx.file("git.bzl", "\n\n".join(BZL))

    return


status_repository = repository_rule(
    doc = """Create a repository that contains bits of information collected
       from the workspace that's not otherwise avalable to build rules.

       NOTE: this tends to be somewhat brittle as bazel is aggresive about
       caching much of this. To force a refesh, run `bazel sync --configure`.

       This infromation is exposed via "setting" rules.

       - `//:git-commit`: The current git commit.
    """,

    implementation = _status_repository_impl,
    local = True,
    configure = True,

    attrs = {
        "alt_git_commit": attr.string(doc="The value to use for :git-commit if the real value isn't avalable."),
        "_git_head": attr.label_list(default = [
            "@//:.git/HEAD",  # force update if git's head updates.
        ]),
    }
)
