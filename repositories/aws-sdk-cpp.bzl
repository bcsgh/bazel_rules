load("@bazel_rules//repositories:compare_cc_deps_test.bzl", "compare_cc_deps_test")
load("@bazel_skylib//lib:selects.bzl", "selects")
load("@bazel_skylib//rules:common_settings.bzl", "bool_flag", "string_flag")
load("@bazel_skylib//rules:write_file.bzl", "write_file")

def flag_set(root, vals, default_value = None):
    string_flag(
        name = root,
        build_setting_default = default_value,
        values = vals,
    )

    [native.config_setting(
        name = "%s_%s" % (root, v),
        flag_values = {":%s" % root: v},
    ) for v in vals]

DEPS = {
    "access-management": ["cognito-identity", "iam"],
    "identity-management": ["cognito-identity", "sts"],
    "queues": ["sqs"],
    "s3-encryption": ["kms", "s3"],
    "text-to-speech": ["polly"],
    "transfer": ["s3"],
}

DEFAULTS = [
    "iam",
    "s3",
    "access-management",
    "identity-management",
]

SKIP = [
    #### needs special handeling.
    "text-to-speech",
]

def BUILD(apis = DEFAULTS):
    ALL = [
        d.rsplit("/", 1)[-2]
        for d in native.glob(
            ["**/src/aws-cpp-sdk-*/CMakeLists.txt"],
            exclude = [
                "src/aws-cpp-sdk-core/**",
                "tests/**",
            ],
        )
    ]

    mapping = dict([
        (d.split("-", 3)[-1], d)
        for d in ALL
    ])
    if len(mapping) != len(ALL): fail(len(mapping), len(ALL))

    write_file(
        # dump the list of all the API's that can be ask for.
        name = "all-aws-apis",
        content = sorted(mapping.keys()),
        out = "all-aws-apis.txt",
    )

    if apis:
        unknown = [k for k in apis if k not in mapping]
        if unknown: fail("Unknown APIs:", unknown)

        missing = [
            (k, a)
            for a in apis
            for k in DEPS.get(a, [])
            if k not in apis
        ]
        if missing:
            print(sorted(dict([(v, 0) for k, v in missing]).keys()))
            fail("Missing requiered APIs:\n%s" % "\n".join([
                ">>> %s needs %s" % (y, x)
                for x, y in dict(missing).items()
            ]))

        mapping = dict([
            (k, d)
            for k, d in mapping.items()
            if k in apis
        ])

    native.test_suite(
        name = "sources_tests",
        tests = [
            ":sources_test_core",
        ] + [
            ":sources_test.%s" % n
            for n in mapping.keys()
        ],
    )

    ############################################################################
    ############################################################################
    compare_cc_deps_test(
        name = "sources_test_core",
        glob = native.glob(
            [
                "src/aws-cpp-sdk-core/**/*.%s" % (e)
                for e in ["c", "cpp", "h", "inc"]
            ],
        ),
        hdrs = [":aws-sdk-cpp-core"],
        srcs = [
            ":aws-sdk-cpp-core.cpp",
            ####
            ":aws-sdk-cpp-core-crypto-bcrypt.cpp",
            ":aws-sdk-cpp-core-crypto-commoncrypto.cpp",
            ":aws-sdk-cpp-core-crypto-openssl.cpp",
            ####
            ":aws-sdk-cpp-core-http-crt.cpp",
            ":aws-sdk-cpp-core-http-curl.cpp",
            ":aws-sdk-cpp-core-http-windows.cpp",
            ####
            ":aws-sdk-cpp-core-net-windows.cpp",
            ":aws-sdk-cpp-core-net-linux.cpp",
            ":aws-sdk-cpp-core-net-none.cpp",
            ####
            ":aws-sdk-cpp-core-platform-android.cpp",
            ":aws-sdk-cpp-core-platform-linux.cpp",
            ":aws-sdk-cpp-core-platform-windows.cpp",
        ],
    )

    ############################################################################
    flag_set(
        root = "aws_http",
        vals = ["crt", "curl"],
        default_value = "crt",
    )

    HTTP_CRT_CPP =     ["src/aws-cpp-sdk-core/source/http/crt/*.cpp"]
    HTTP_CURL_CPP =    ["src/aws-cpp-sdk-core/source/http/curl/*.cpp"]
    HTTP_WINDOWS_CPP = ["src/aws-cpp-sdk-core/source/http/windows/*.cpp"]
    native.filegroup(
        name = "aws-sdk-cpp-core-http-crt.cpp",
        srcs = native.glob(HTTP_CRT_CPP),
    )
    native.filegroup(
        name = "aws-sdk-cpp-core-http-curl.cpp",
        srcs = native.glob(HTTP_CURL_CPP),
    )
    native.filegroup(
        name = "aws-sdk-cpp-core-http-windows.cpp",
        srcs = native.glob(HTTP_WINDOWS_CPP),
    )
    native.alias(
        name = "aws-sdk-cpp-core-http.cpp",
        actual = select({
            ":aws_http_crt": ":aws-sdk-cpp-core-http-crt.cpp",
            ":aws_http_curl": ":aws-sdk-cpp-core-http-curl.cpp",
            "@platforms//os:windows": "aws-sdk-cpp-core-http-windows.cpp",
        }),
    )
    native.cc_library(
        name = "aws-sdk-cpp-core-http",
        deps = select({
            ":aws_http_crt": ["@com_github_awslabs_aws_crt_cpp//:aws-crt-cpp"],
            ":aws_http_curl": ["@com_github_curl_curl//:curl"],
            "@platforms//os:windows": [],  # NOTE: not tested
        }),
    )

    ############################################################################
    flag_set(
        root = "aws_crypto",
        vals = ["bcrypt", "commoncrypto", "openssl"],
        default_value = "openssl",
    )

    CRYPTO_BCRYPT_CPP =  ["src/aws-cpp-sdk-core/source/utils/crypto/bcrypt/*.cpp"]
    CRYPTO_COMMON_CPP =  ["src/aws-cpp-sdk-core/source/utils/crypto/commoncrypto/*.cpp"]
    CRYPTO_OPENSSL_CPP = ["src/aws-cpp-sdk-core/source/utils/crypto/openssl/*.cpp"]
    native.filegroup(
        name = "aws-sdk-cpp-core-crypto-bcrypt.cpp",
        srcs = native.glob(CRYPTO_BCRYPT_CPP),
    )
    native.filegroup(
        name = "aws-sdk-cpp-core-crypto-commoncrypto.cpp",
        srcs = native.glob(CRYPTO_COMMON_CPP),
    )
    native.filegroup(
        name = "aws-sdk-cpp-core-crypto-openssl.cpp",
        srcs = native.glob(CRYPTO_OPENSSL_CPP),
    )
    native.alias(
        name = "aws-sdk-cpp-core-crypto.cpp",
        actual = select({
            ":aws_crypto_bcrypt": ":aws-sdk-cpp-core-crypto-bcrypt.cpp",
            ":aws_crypto_commoncrypto": ":aws-sdk-cpp-core-crypto-commoncrypto.cpp",
            ":aws_crypto_openssl": ":aws-sdk-cpp-core-crypto-openssl.cpp",
        }),
    )
    native.cc_library(
        name = "aws-sdk-cpp-core-crypto",
        deps = select({
            #":aws_crypto_bcrypt": [":not-implemented"],
            ":aws_crypto_commoncrypto": ["@com_github_apple_oss_common_crypto//:common_crypto"],
            ":aws_crypto_openssl": ["@com_github_openssl_openssl//:openssl"],
        }),
    )

    ############################################################################
    PLATFORM_ANDROID_CPP = ["src/aws-cpp-sdk-core/source/platform/android/*.cpp"]
    PLATFORM_LINUX_CPP =   ["src/aws-cpp-sdk-core/source/platform/linux-shared/*.cpp"]
    PLATFORM_WINDOWS_CPP = ["src/aws-cpp-sdk-core/source/platform/windows/*.cpp"]
    native.filegroup(
        name = "aws-sdk-cpp-core-platform-android.cpp",
        srcs = native.glob(PLATFORM_ANDROID_CPP),
    )
    native.filegroup(
        name = "aws-sdk-cpp-core-platform-linux.cpp",
        srcs = native.glob(PLATFORM_LINUX_CPP),
    )
    native.filegroup(
        name = "aws-sdk-cpp-core-platform-windows.cpp",
        srcs = native.glob(PLATFORM_WINDOWS_CPP),
    )
    native.alias(
        name = "aws-sdk-cpp-core-platform.cpp",
        actual = select({
            "@platforms//os:android": ":aws-sdk-cpp-core-platform-android.cpp",
            "@platforms//os:linux": ":aws-sdk-cpp-core-platform-linux.cpp",
            "@platforms//os:windows": ":aws-sdk-cpp-core-platform-windows.cpp",
        }),
    )

    ############################################################################
    NET_LINUX_CPP =   ["src/aws-cpp-sdk-core/source/net/linux-shared/*.cpp"]
    NET_WINDOWS_CPP = ["src/aws-cpp-sdk-core/source/net/windows/*.cpp"]
    NET_NONE_CPP =    ["src/aws-cpp-sdk-core/source/net/*.cpp"]
    native.filegroup(
        name = "aws-sdk-cpp-core-net-linux.cpp",
        srcs = native.glob(NET_LINUX_CPP),
    )
    native.filegroup(
        name = "aws-sdk-cpp-core-net-windows.cpp",
        srcs = native.glob(NET_WINDOWS_CPP),
    )
    native.filegroup(
        name = "aws-sdk-cpp-core-net-none.cpp",
        srcs = native.glob(NET_NONE_CPP),
    )
    native.alias(
        name = "aws-sdk-cpp-core-net.cpp",
        actual = select({
            "@platforms//os:linux": ":aws-sdk-cpp-core-net-linux.cpp",
            "@platforms//os:windows": ":aws-sdk-cpp-core-net-windows.cpp",
            "//conditions:default": ":aws-sdk-cpp-core-net-none.cpp",
        }),
    )

    ############################################################################
    native.filegroup(
        name = "aws-sdk-cpp-core.cpp",
        srcs = native.glob(
            [
                "src/aws-cpp-sdk-core/source/*.cpp",
                "src/aws-cpp-sdk-core/source/auth/*.cpp",
                "src/aws-cpp-sdk-core/source/auth/bearer-token-provider/*.cpp",
                "src/aws-cpp-sdk-core/source/auth/signer/*.cpp",
                "src/aws-cpp-sdk-core/source/auth/signer-provider/*.cpp",
                "src/aws-cpp-sdk-core/source/client/*.cpp",
                "src/aws-cpp-sdk-core/source/config/*.cpp",
                "src/aws-cpp-sdk-core/source/config/defaults/*.cpp",
                "src/aws-cpp-sdk-core/source/endpoint/*.cpp",
                "src/aws-cpp-sdk-core/source/endpoint/internal/*.cpp",
                "src/aws-cpp-sdk-core/source/external/cjson/*.cpp",
                "src/aws-cpp-sdk-core/source/external/tinyxml2/*.cpp",
                "src/aws-cpp-sdk-core/source/http/*.cpp",
                "src/aws-cpp-sdk-core/source/http/standard/*.cpp",
                "src/aws-cpp-sdk-core/source/internal/*.cpp",
                "src/aws-cpp-sdk-core/source/monitoring/*.cpp",
                "src/aws-cpp-sdk-core/source/net/*.cpp",
                "src/aws-cpp-sdk-core/source/utils/*.cpp",
                "src/aws-cpp-sdk-core/source/utils/base64/*.cpp",
                "src/aws-cpp-sdk-core/source/utils/component-registry/*.cpp",
                "src/aws-cpp-sdk-core/source/utils/crypto/*.cpp",
                "src/aws-cpp-sdk-core/source/utils/crypto/factory/*.cpp",
                "src/aws-cpp-sdk-core/source/utils/event/*.cpp",
                "src/aws-cpp-sdk-core/source/utils/json/*.cpp",
                "src/aws-cpp-sdk-core/source/utils/logging/*.cpp",
                "src/aws-cpp-sdk-core/source/utils/memory/*.cpp",
                "src/aws-cpp-sdk-core/source/utils/memory/stl/*.cpp",
                "src/aws-cpp-sdk-core/source/utils/stream/*.cpp",
                "src/aws-cpp-sdk-core/source/utils/threading/*.cpp",
                "src/aws-cpp-sdk-core/source/utils/xml/*.cpp",
                ####
                "src/aws-cpp-sdk-core/source/smithy/**/*.cpp",
            ],
            exclude =
                HTTP_CRT_CPP + HTTP_CURL_CPP + HTTP_WINDOWS_CPP +
                CRYPTO_BCRYPT_CPP + CRYPTO_COMMON_CPP + CRYPTO_OPENSSL_CPP +
                NET_LINUX_CPP + NET_WINDOWS_CPP + NET_NONE_CPP +
                PLATFORM_ANDROID_CPP + PLATFORM_LINUX_CPP + PLATFORM_WINDOWS_CPP +
                [],
        ),
    )

    native.cc_library(
        name = "aws-sdk-cpp-core",
        srcs = [
            ":aws-sdk-cpp-core.cpp",
            ":aws-sdk-cpp-core-crypto.cpp",
            ":aws-sdk-cpp-core-http.cpp",
            ":aws-sdk-cpp-core-net.cpp",
            ":aws-sdk-cpp-core-platform.cpp",
        ],
        hdrs = native.glob([
            "src/aws-cpp-sdk-core/include/aws/core/**/*.h",
            ####
            "src/aws-cpp-sdk-core/include/smithy/**/*.h",
        ]),
        includes = ["src/aws-cpp-sdk-core/include"],
        deps = [
            Label(":aws-cpp-sdk-config"),
            "@com_github_awslabs_aws_c_common//:aws-c-common",
            "@com_github_awslabs_aws_crt_cpp//:aws-crt-cpp",
            "@io_opentelemetry_cpp//api",
            "@io_opentelemetry_cpp//exporters/ostream:ostream_metric_exporter",
            "@io_opentelemetry_cpp//exporters/ostream:ostream_span_exporter",
            "@io_opentelemetry_cpp//sdk:headers",
            ":aws-sdk-cpp-core-crypto",
            ":aws-sdk-cpp-core-http",
        ],
        visibility = ["//visibility:public"],
    )

    ############################################################################
    ############################################################################

    if "text-to-speech" in mapping: _text_to_speach()

    for n, p in mapping.items():
        if n in SKIP: continue

        _generic_api(n, p)


def _generic_api(name, path):
    compare_cc_deps_test(
        name = "sources_test.%s" % name,
        glob = native.glob(
            [
                "%s/**/*.%s" % (path, e)
                for e in ["c", "cpp", "h", "inc"]
            ],
        ),
        hdrs = [":aws-sdk-cpp.%s" % name],
        srcs = [":aws-sdk-cpp.%s.cpp" % name],
    )

    native.filegroup(
        name = "aws-sdk-cpp.%s.cpp" % name,
        srcs = native.glob([
            "{p}/source/**/*.cpp".format(p = path)
        ]),
    )

    native.cc_library(
        name = "aws-sdk-cpp.%s" % name,
        srcs = [":aws-sdk-cpp.%s.cpp" % name],
        hdrs = native.glob([
            "{p}/include/aws/{n}/**/*.h".format(p = path, n = name)
        ]),
        includes = ["%s/include" % path],
        deps = [
            ":aws-sdk-cpp-core",
        ] + [
            ":aws-sdk-cpp.%s" % d
            for d in DEPS.get(name, [])
        ],
        visibility = ["//visibility:public"],
    )

def _text_to_speach():
    compare_cc_deps_test(
        name = "sources_test.text-to-speech",
        glob = native.glob([
            "src/aws-cpp-sdk-text-to-speech/**/*.%s" % e
            for e in ["c", "cpp", "h", "inc"]
        ]),
        hdrs = [":aws-sdk-cpp.text-to-speech-hdrs"],
        srcs = [
            ":aws-sdk-cpp.text-to-speech.cpp",
            ":aws-sdk-cpp.text-to-speech.apple.cpp",
            ":aws-sdk-cpp.text-to-speech.linux.cpp",
            ":aws-sdk-cpp.text-to-speech.windows.cpp",
        ],
    )

    ###########
    native.filegroup(
        name = "aws-sdk-cpp.text-to-speech.apple.cpp",
        srcs = ["src/aws-cpp-sdk-text-to-speech/source/text-to-speech/apple/CoreAudioPCMOutputDriver.cpp"],
    )
    native.filegroup(
        name = "aws-sdk-cpp.text-to-speech.linux.cpp",
        srcs = ["src/aws-cpp-sdk-text-to-speech/source/text-to-speech/linux/PulseAudioPCMOutputDriver.cpp"],
    )
    native.filegroup(
        name = "aws-sdk-cpp.text-to-speech.windows.cpp",
        srcs = ["src/aws-cpp-sdk-text-to-speech/source/text-to-speech/windows/WaveOutPCMOutputDriver.cpp"],
    )

    bool_flag(name = "pulse_audio", build_setting_default = False)
    native.config_setting(
        name = "pulse_audio_avalable",
        flag_values = {":pulse_audio": "true"},
    )
    native.alias(
        name = "aws-sdk-cpp.text-to-output-driver.cpp",
        actual = selects.with_or({
            ("@platforms//os:osx", "@platforms//os:ios"):
                ":aws-sdk-cpp.text-to-speech.apple.cpp",
            ":pulse_audio_avalable":  # TODO? "@platforms//os:linux":
                ":aws-sdk-cpp.text-to-speech.linux.cpp",
            "@platforms//os:windows":
                ":aws-sdk-cpp.text-to-speech.windows.cpp",
            "//conditions:default": ":not-implemented",
        }),
    )

    ###########
    native.filegroup(
        name = "aws-sdk-cpp.text-to-speech.cpp",
        srcs = native.glob(
            [
                "src/aws-cpp-sdk-text-to-speech/source/**/*.cpp",
            ],
            exclude = [
                "src/aws-cpp-sdk-text-to-speech/source/text-to-speech/apple/**",
                "src/aws-cpp-sdk-text-to-speech/source/text-to-speech/linux/**",
                "src/aws-cpp-sdk-text-to-speech/source/text-to-speech/windows/**",
                "src/aws-cpp-sdk-text-to-speech/source/text-to-speech/*/*OutputDriver.cpp",
            ],
        ),
    )

    native.cc_library(
        name = "aws-sdk-cpp.text-to-speech-hdrs",
        hdrs = native.glob([
            "src/aws-cpp-sdk-text-to-speech/include/aws/text-to-speech/**/*.h",
        ]),
        includes = ["src/aws-cpp-sdk-text-to-speech/include"],
    )

    native.cc_library(
        name = "aws-sdk-cpp.text-to-speech",
        tags = ["manual"],
        srcs = [
            ":aws-sdk-cpp.text-to-speech.cpp",
            ":aws-sdk-cpp.text-to-output-driver.cpp",
        ],
        deps = [
            ":aws-sdk-cpp-core",
            ":aws-sdk-cpp.text-to-speech-hdrs",
        ] + [
            ":aws-sdk-cpp.%s" % d
            for d in DEPS.get("text-to-speech", [])
        ],
        visibility = ["//visibility:public"],
    )
