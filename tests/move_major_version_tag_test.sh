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

initial_major_ver_tag="v998"
initial_release_tag="v998.0.0"
create_git_release_tag "${initial_release_tag}"
do_move "${initial_release_tag}"
git_tag_exists "${initial_major_ver_tag}" || fail "Expected ${initial_major_ver_tag} to exist."
initial_release_commit="$(get_git_commit_hash "${initial_release_tag}")"
initial_major_ver_tag_commit="$(get_git_commit_hash "${initial_major_ver_tag}")"
assert_equal "${initial_release_commit}" "${initial_major_ver_tag_commit}" "Commits should match."


# MARK - Test with previous major tag

echo "More text." >> "${foo_path}"
git commit -a -m "Commit more text."

patch_release_tag="v998.0.1"
create_git_release_tag "${patch_release_tag}"
do_move "${patch_release_tag}"
git_tag_exists "${initial_major_ver_tag}" || fail "Expected ${initial_major_ver_tag} to exist."
patch_release_commit="$(get_git_commit_hash "${patch_release_tag}")"
initial_major_ver_tag_commit="$(get_git_commit_hash "${initial_major_ver_tag}")"
assert_equal "${patch_release_commit}" "${initial_major_ver_tag_commit}" \
  "Commits should match after patch release."


# MARK - Test Major Version Release

new_major_ver_tag="v999"
new_major_release_tag="v999.0.0"
create_git_release_tag "${new_major_release_tag}"
do_move "${new_major_release_tag}"
git_tag_exists "${new_major_ver_tag}" || fail "Expected ${new_major_ver_tag} to exist."
new_major_release_commit="$(get_git_commit_hash "${new_major_release_tag}")"
new_major_ver_tag_commit="$(get_git_commit_hash "${new_major_ver_tag}")"
assert_equal "${new_major_release_commit}" "${new_major_ver_tag_commit}" \
  "Commits should match after major release."

# Make sure that the initial major ver tag still points to patch release.
initial_major_ver_tag_commit="$(get_git_commit_hash "${initial_major_ver_tag}")"
assert_equal "${patch_release_commit}" "${initial_major_ver_tag_commit}" \
  "Initial major version tag commit should not have changed."
