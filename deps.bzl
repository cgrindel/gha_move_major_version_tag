"""Dependencies for gha_move_major_version_tag."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def gha_move_major_version_tag_dependencies():
    """Loads the dependencies for `rules_swiftformat`."""
    maybe(
        http_archive,
        name = "bazel_skylib",
        urls = [
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.4.2/bazel-skylib-1.4.2.tar.gz",
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.4.2/bazel-skylib-1.4.2.tar.gz",
        ],
        sha256 = "66ffd9315665bfaafc96b52278f57c7e2dd09f5ede279ea6d39b2be471e7e3aa",
    )

    http_archive(
        name = "cgrindel_bazel_starlib",
        sha256 = "888483f8e8e481bcd3a601b7d5d6641bd62782fd6b6700a91a6603f8c8aba257",
        strip_prefix = "bazel-starlib-0.16.1",
        urls = [
            "http://github.com/cgrindel/bazel-starlib/archive/v0.16.1.tar.gz",
        ],
    )
