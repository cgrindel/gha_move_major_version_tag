# Move Major Version Tag GitHub Action

GitiHub Action to create or move a major version tag.  This is useful if you implement GitHub Action
custom actions and follow [the release
recommendations](https://docs.github.com/en/actions/creating-actions/releasing-and-maintaining-actions#developing-and-releasing-actions).

In GitHub Action parlance, a semver release tag looks like `v1.2.3`. The major version tag for this
release tag is `v1`. This action will delete the major version tag if it exists. Then, it will
create a major version tag pointing at the same commit as the release tag.

## Quickstart

A typical pattern is to implement a workflow that creates or moves a major version tag when a new
release is published. Under the `.github/workflows` directory, create a file called
`move_major_ver_tag_on_release.yml` with the following content:

```yaml
name: Move Major Version Tag on Release

on:
  release:
    types: [ published ]
  workflow_dispatch:
    inputs:
      release_tag:
        required: true
        type: string

jobs:
  move_major_version_tag:
    runs-on: ubuntu-20.04
    steps:

      # Checks out the code from your repository with all history for all 
      # branches and tags. This is important if the workflow is launched via
      # workspace_dispatch event. It ensures that we can find the release tag
      # and the major version tag.
      - uses: actions/checkout@v2
        with:
          # Fetch all history for all branches and tags
          fetch-depth: 0

      # Configures the git user config. This is necessary when making changes
      # to a git repository.
      - uses: cgrindel/gha_configure_git_user@v1

      # The release tag can come into the workflow via the release event or as
      # a workflow_dispatch event. This step finds the first non-empty value
      # and outputs it as `selected_value`.
      - name: Resolve release_tag
        id: resolve_release_tag
        uses: cgrindel/gha_select_value@v1
        with: 
          value0: ${{ github.event.release.tag_name }}
          value1: ${{ github.event.inputs.release_tag }}

      # Create or move the major version tag
      - uses: cgrindel/gha_move_major_version_tag@v1
        with:
          release_tag: ${{ steps.resolve_release_tag.outputs.selected_value }}

```

This workflow will run when a new release is published or if the workflow is [launched via a
`workflow_dispatch`
event](https://docs.github.com/en/actions/managing-workflow-runs/manually-running-a-workflow). 
