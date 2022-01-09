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

# MARK - Locate Deps

fail_sh_location=cgrindel_bazel_starlib/shlib/lib/fail.sh
fail_sh="$(rlocation "${fail_sh_location}")" || \
  (echo >&2 "Failed to locate ${fail_sh_location}" && exit 1)
source "${fail_sh}"

env_sh_location=cgrindel_bazel_starlib/shlib/lib/env.sh
env_sh="$(rlocation "${env_sh_location}")" || \
  (echo >&2 "Failed to locate ${env_sh_location}" && exit 1)
source "${env_sh}"

git_sh_location=cgrindel_bazel_starlib/shlib/lib/git.sh
git_sh="$(rlocation "${git_sh_location}")" || \
  (echo >&2 "Failed to locate ${git_sh_location}" && exit 1)
source "${git_sh}"

# MARK - Check for Required Software

required_software="Both git and Github CLI (gh) are required to run this utility."
is_installed gh || fail "Could not find Github CLI (gh)." "${required_software}"
is_installed git || fail "Could not find git." "${required_software}"

# MARK - Process Flags

get_usage() {
  local utility="$(basename "${BASH_SOURCE[0]}")"
  echo "$(cat <<-EOF
Create or move a major version release release_tag.

Usage:
${utility} [--remote <remote>] [--major_ver_tag <major_ver_tag>] [--no_push_tag] 
           --release_tag <release_tag> 
           --repo_dir <repository_directory>
EOF
  )"
}

push_tag=true

args=()
while (("$#")); do
  case "${1}" in
    "--help")
      show_usage
      exit 0
      ;;
    --repo_dir)
      repo_dir="${2}"
      shift 2
      ;;
    --release_tag)
      release_tag="${2}"
      shift 2
      ;;
    --major_ver_tag)
      major_ver_tag="${2}"
      shift 2
      ;;
    --no_push_tag)
      push_tag=false
      shift 1
      ;;
    --remote)
      remote="${2}"
      shift 2
      ;;
    *)
      args+=("${1}")
      shift 1
      ;;
  esac
done


[[ -z "${release_tag:-}" ]] && usage_error "Expected a version release_tag. (e.g v1.2.3)"
is_valid_release_tag "${release_tag}" || fail "Invalid version release_tag. Expected it to start with 'v'."

[[ -z "${repo_dir}" ]] && usage_error "Expected a repo_dir."

# MARK - Determine the major version tag.

if [[ -z "${major_ver_tag:-}" ]]; then
  # Searches for the first period and selects everything before it.
  # If there is no period, the whole thing is selected.
  major_ver_tag="${release_tag%%.*}"
fi

[[ "${release_tag}" == "${major_ver_tag}" ]] && fail "The major version tag is identical to the release tag."

# MARK - Change to the repository directory

cd "${repo_dir}"

# MARK - Check for the existence of the major tag.

if git_tag_exists "${major_ver_tag}"; then
  orig_commit="$(get_git_commit_hash "${major_ver_tag}")"
  echo "Removing ${major_ver_tag} at ${orig_commit}."
  delete_git_tag "${major_ver_tag}"
fi

# MARK - Create the major version tag with the new commit

new_commit="$(get_git_commit_hash "${release_tag}")"
echo "Creating ${major_ver_tag} at ${new_commit}." 
git tag -a -m "Major release tag ${major_ver_tag}." "${major_ver_tag}" "${new_commit}"

# MARK -  Push to remote

if [[ "${push_tag}" == true ]]; then
  push_cmd=( push_git_tag_to_remote "${major_ver_tag}" )
  [[ -z "${remote:-}" ]] || push_cmd+=( "${remote}" )
  echo "Pushing ${major_ver_tag} to ${remote:-origin}."
  "${push_cmd[@]}"
else
  echo "Skipping push of ${major_ver_tag} to ${remote:-origin}."
fi


