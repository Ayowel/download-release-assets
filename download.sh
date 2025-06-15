#!/usr/bin/env bash

set -eo pipefail

# Fix repository value for nektos/act runner.
# This also makes it possible to provide a git remote address
# instead of just the repository name.
if test "$GITHUB_REPOSITORY" != "${GITHUB_REPOSITORY%.git}"; then
  GITHUB_REPOSITORY="${GITHUB_REPOSITORY%.git}"
  if test "$GITHUB_REPOSITORY" != "${GITHUB_REPOSITORY#*@}"; then
    # Drop ssh format prefix
    GITHUB_REPOSITORY="${GITHUB_REPOSITORY##*:}"
  fi
  if test "$GITHUB_REPOSITORY" != "${GITHUB_REPOSITORY#*://}"; then
    # Drop http format protocol and domain
    GITHUB_REPOSITORY="${GITHUB_REPOSITORY#*://}"
    GITHUB_REPOSITORY="${GITHUB_REPOSITORY#*/}"
  fi
fi

CURL_OPTS=(
  -sL --fail
  -H "Authorization: Bearer ${GITHUB_TOKEN}"
)
CURL_JSON=(
  "${CURL_OPTS[@]}"
  -H "Accept: application/vnd.github.v3+json"
)
GH_REPO="${GITHUB_API_URL}/repos/${GITHUB_REPOSITORY}"

# Get information on the release
if ! release_info="$(curl "${CURL_JSON[@]}" "${GH_REPO}/releases/${TARGET_RELEASE}")"; then
  # An error occured, ensure that it is because there is no release and
  # not due to an API access issue.
  if releases_count="$(curl "${CURL_JSON[@]}" "${GH_REPO}/releases" |
      jq 'length' )" && test "$releases_count" -ge 0; then
    echo "Could not find release ${TARGET_RELEASE} in the repository."
    if test "$FAIL_IF_NO_RELEASE" == 'false'; then
      exit 0
    fi
  elif test -z "$releases_count"; then
    echo "Failed to access GitHub's API at '${releases_endpoint}'." >&2
  else
    echo "An unidentified error occured while attempting to get the releases at '${releases_endpoint}'." >&2
  fi
  exit 1
fi

# Extract release info as output
jq <<<"$release_info"
echo "found-release=true" >>"$GITHUB_OUTPUT"
for l in name tag_name id; do
  echo "release-${l//_/-}=\"$(<<<"$release_info" jq -r ".${l}")\"" >>"$GITHUB_OUTPUT"
done

# Search desired asset
if ! asset_info="$(<<<"$release_info" jq ".assets | .[] | select(.name | test(\"${TARGET_MATCH}\"))")" || test "$asset_info" == null; then
  echo "Asset not found."
  if test "$FAIL_IF_NO_FILE" == 'false'; then
    exit 0
  else
    exit 1
  fi
fi

# Extract asset info as output
for l in name url id digest; do
  echo "asset-${l//_/-}='$(<<<"$asset_info" jq -r ".${l}")'" >>"$GITHUB_OUTPUT"
done

# Download asset file
if test -z "$SAVE_NAME"; then
  SAVE_NAME="$(<<<"$asset_info" jq -r ".name")"
fi
asset_url="$(<<<"$asset_info" jq -r ".url")"
curl "${CURL_OPTS[@]}" \
    -H "Accept: application/octet-stream" \
    -o "${SAVE_NAME}" \
    "${asset_url}"

echo "found=true" >>"$GITHUB_OUTPUT"
