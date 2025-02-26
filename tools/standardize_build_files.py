#!/usr/bin/env python3
import os
import re
import glob

def convert_to_camel_case(name):
    # Convert directory path to CamelCase module name
    parts = name.split('/')
    return ''.join(p.capitalize() for p in parts)

def generate_build_file(directory):
    module_parts = directory.split('Sources/')[-1].split('/')
    module_name = ''.join(part.capitalize() for part in module_parts)
    
    build_content = '''load("@build_bazel_rules_swift//swift:swift.bzl", "swift_library")

swift_library(
    name = "{}",
    srcs = glob(
        ["**/*.swift"],
        allow_empty = True,
    ),
    copts = [
        "-target",
        "arm64-apple-macos14.0",
        "-strict-concurrency=complete",
        "-enable-actor-data-race-checks",
        "-warn-concurrency",
    ],
    module_name = "{}",
    visibility = ["//visibility:public"],
    deps = [
        "//Sources/ErrorHandling",
        "//Sources/UmbraLogging",
    ],
)
'''.format(module_name, module_name)

    build_file = os.path.join(directory, 'BUILD.bazel')
    with open(build_file, 'w') as f:
        f.write(build_content)
    print(f"Generated {build_file}")

def main():
    root_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    sources_dir = os.path.join(root_dir, 'Sources')
    
    # Find all directories that might need BUILD files
    for root, dirs, files in os.walk(sources_dir):
        if any(f.endswith('.swift') for f in files):
            generate_build_file(root)

if __name__ == '__main__':
    main()
