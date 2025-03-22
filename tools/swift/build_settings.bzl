"""
Build settings for UmbraCore.
"""

BuildEnvironmentInfo = provider(
    doc = "Information about the current build environment",
    fields = {"is_local": "Boolean indicating whether this is a local build"},
)

def _build_environment_impl(ctx):
    return [BuildEnvironmentInfo(is_local = ctx.attr.is_local)]

build_environment = rule(
    implementation = _build_environment_impl,
    attrs = {
        "is_local": attr.bool(default = False),
    },
)
