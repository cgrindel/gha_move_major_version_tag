"""Dependencies for gha_move_major_version_tag."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def gha_move_major_version_tag_dependencies():
    """Loads the dependencies for `rules_swiftformat`."""
    maybe(
        http_archive,
        name = "bazel_skylib",
        urls = [
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.9.2/bazel-skylib-1.9.2.tar.gz",
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.9.2/bazel-skylib-1.9.2.tar.gz",
        ],
        sha256 = "37cdfbc6faefea94f7b37760a305c98c08981116c2bc9e821e3b423221fad8c8",
    )

    http_archive(
        name = "cgrindel_bazel_starlib",
        sha256 = "7e4590e30e9968a72875397bbc796adfe6547602d2c8947c6f1613c66fcb7140",
        strip_prefix = "bazel-starlib-0.30.0",
        urls = [
            "http://github.com/cgrindel/bazel-starlib/archive/v0.30.0.tar.gz",
        ],
    )
