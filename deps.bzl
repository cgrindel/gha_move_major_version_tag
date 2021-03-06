"""Dependencies for gha_move_major_version_tag."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def gha_move_major_version_tag_dependencies():
    """Loads the dependencies for `rules_swiftformat`."""
    maybe(
        http_archive,
        name = "bazel_skylib",
        urls = [
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.1.1/bazel-skylib-1.1.1.tar.gz",
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.1.1/bazel-skylib-1.1.1.tar.gz",
        ],
        sha256 = "c6966ec828da198c5d9adbaa94c05e3a1c7f21bd012a0b29ba8ddbccb2c93b0d",
    )

    http_archive(
        name = "cgrindel_bazel_starlib",
        sha256 = "dbc0cedf19e560ac9763a4dd60e1b7ab981692f9b647c03f5340bc64d8032a80",
        strip_prefix = "bazel-starlib-0.6.1",
        urls = [
            "http://github.com/cgrindel/bazel-starlib/archive/v0.6.1.tar.gz",
        ],
    )
