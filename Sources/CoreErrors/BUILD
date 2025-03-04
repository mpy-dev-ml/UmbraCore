load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "CoreErrors",
    srcs = glob(["*.swift"]),
    copts = ["-enable-library-evolution"],
    module_name = "CoreErrors",
    visibility = ["//visibility:public"],
)

filegroup(
    name = "CoreErrorsSources",
    srcs = glob(["*.swift"]),
    visibility = ["//visibility:public"],
)
