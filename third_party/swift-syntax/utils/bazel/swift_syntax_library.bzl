"""Convenience wrapper for swift_library targets using this repo's conventions"""

load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

def swift_syntax_library(name, deps = [], testonly = False):
    swift_library(
        name = name,
        srcs = native.glob(
            ["Sources/{}/**/*.swift".format(name)],
            exclude = ["**/*.docc/**"],
            allow_empty = False,
        ),
        module_name = name,
        deps = deps,
        testonly = testonly,
        copts = [
            "-target",
            "arm64-apple-macos14.0",
            "-strict-concurrency=complete",
            "-warn-concurrency",
            "-enable-actor-data-race-checks",
        ],
    )
