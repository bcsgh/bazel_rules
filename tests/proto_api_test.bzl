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

load("@bazel_skylib//rules:diff_test.bzl", "diff_test")
load("//proto_api:proto_api.bzl", "gen_proto_api")

def proto_api_suite(name):
    native.proto_library(
        name = "api",
        srcs = ["api.proto"],
        deps = ["//proto_api:api_meta_proto"],
    )

    gen_proto_api(
        name = "gen_metadata",
        proto = ":api",
        js = "gen_metadata.js",
        h = "gen_metadata.h",
        include_guard = "OVERRIDE_H_",
    )

    diff_test(
        name = "js_test",
        file1 = "gen_metadata.js",
        file2 = "gen_metadata.gold.js",
    )

    diff_test(
        name = "cc_test",
        file1 = "gen_metadata.h",
        file2 = "gen_metadata.gold.h",
    )

    # Suit
    native.test_suite(
        name = name,
        tests = [
            ":js_test",
            ":cc_test",
        ],
    )
