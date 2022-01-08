#!/usr/bin/env bash

# --- begin runfiles.bash initialization v2 ---
# Copy-pasted from the Bazel Bash runfiles library v2.
set -uo pipefail; f=bazel_tools/tools/bash/runfiles/runfiles.bash
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null || \
  source "$0.runfiles/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  { echo>&2 "ERROR: cannot find $f"; exit 1; }; f=; set -e
# --- end runfiles.bash initialization v2 ---

# MARK - Load Deps

assertions_sh_location=cgrindel_bazel_starlib/shlib/lib/assertions.sh
assertions_sh="$(rlocation "${assertions_sh_location}")" || \
  (echo >&2 "Failed to locate ${assertions_sh_location}" && exit 1)
source "${assertions_sh}"

git_sh_location=cgrindel_bazel_starlib/shlib/lib/git.sh
git_sh="$(rlocation "${git_sh_location}")" || \
  (echo >&2 "Failed to locate ${git_sh_location}" && exit 1)
source "${git_sh}"

move_major_version_tag_sh_location=cgrindel_gha_move_major_version_tag/move_major_version_tag.sh
move_major_version_tag_sh="$(rlocation "${move_major_version_tag_sh_location}")" || \
  (echo >&2 "Failed to locate ${move_major_version_tag_sh_location}" && exit 1)

starting_dir="${PWD}"

# MARK - Set up the repo_dir

repo_dir="${PWD}/test_repo"
rm -rf repo_dir
mkdir -p "${repo_dir}"
cd "${repo_dir}"

do_move() {
  local release_tag="${1}"
  "${move_major_version_tag_sh}" \
    --no_push_tag \
    --release_tag "${release_tag}" \
    --repo_dir "${repo_dir}"
}

# MARK - Create git repository

git init -b main
git config user.name "Test User"
git config user.email "test@doesnotexist.org"

foo_path="${repo_dir}/foo.txt"
touch "${foo_path}"
git add "$(basename "${foo_path}")"
git commit -a -m "Commit foo.txt"


# MARK - Test no previous major tag

initial_release_tag="v998.0.0"
expected_major_tag="v998"
create_git_release_tag "${initial_release_tag}"
do_move "${initial_release_tag}"
git_tag_exists "${expected_major_tag}" || fail "Expected ${expected_major_tag} to exist."
release_commit="$(get_git_commit_hash "${initial_release_tag}")"
major_tag_commit="$(get_git_commit_hash "${expected_major_tag}")"
assert_equal "${release_commit}" "${major_tag_commit}" "Commits should match."


# MARK - Test with previous major tag

# echo "More text." >> "${foo_path}"
# git commit -a -m "Commit foo.txt"

fail "IMPLEMENT ME!"
