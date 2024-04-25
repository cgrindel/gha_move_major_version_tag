"""Dependencies for gha_move_major_version_tag."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def gha_move_major_version_tag_dependencies():
    """Loads the dependencies for `rules_swiftformat`."""
    maybe(
        http_archive,
        name = "bazel_skylib",
        urls = [
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.6.0/bazel-skylib-1.6.0.tar.gz",
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.6.0/bazel-skylib-1.6.0.tar.gz",
        ],
        sha256 = "41449d7c7372d2e270e8504dfab09ee974325b0b40fdd98172c7fbe257b8bcc9",
    )

    http_archive(
        name = "cgrindel_bazel_starlib",
        sha256 = "b05401644174f70467ee7ea823ea9e8033080bc5612c0bcc319a670fd43e5f32",
        strip_prefix = "bazel-starlib-0.20.2",
        urls = [
            "http://github.com/cgrindel/bazel-starlib/archive/v0.20.2.tar.gz",
        ],
    )
