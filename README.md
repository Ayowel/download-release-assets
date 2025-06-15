# Get release assets

This action downloads a specific release's asset by matching asset name.

## Usage

Download asset from the latest release:

```yaml
- name: Get the latest release's archive
  uses: ayowel/get-assets-action@v1
  with:
    asset: release-archive.zip
```

Download asset from a specific release to a different file:

```yaml
- uses: ayowel/get-assets-action@v1
  with:
    release: v8.3.7
    repository: renpy/renpy
    asset: "renpy-.+-rapt.zip$"
    output: renpy-rapt.zip
```

Download asset from a private repository using personal access token:

```yaml
- uses: ayowel/get-assets-action@v1
  with:
    token: {{ secrets.GITHUB_PAT }}
    repository: renpy/renpy
    asset: "renpy-.+-rapt.zip$"
```

## Inputs

| Name | Required | Description | Default |
| ---- | :-------: | ----------- | ------- |
| **repository** |  | Repository name with owner, defaults to the current repository. For example, ayowel/get-assets-action. | `${{ github.repository }}` |
| **asset** | * | Asset file name. This can be a regex pattern. | `true` |
| **output** |  | Path and name of the downloaded asset. If empty, defaults to the asset's name | `''` |
| **token** |  | A GitHub token to use the GitHub API. | `${{ github.token }}` |
| **release** |  | Release version to download, default to latest. | `'latest'` |
| **api-url** |  | GitHub's API URL. | `${{ github.api_url }}` |
| **require-release** |  | Whether the step should fail if no release is found. | `'true'` |
| **require-asset** |  | Whether the step should fail if no asset is found. | `'true'` |

## Outputs

| Name | Description | Condition |
| ---- | ----------- | --------- |
| **found** | Whether the asset was found. |  |
| **found-release** | Whether the release was found. |  |
| **release-name** | Title of the release. | If found-release is `'true'` and the release has a name |
| **release-tag-name** | Tag of the release. | If found-release is `'true'` |
| **release-id** | ID of the release. | If found-release is `'true'` |
| **asset-name** | Name of the asset in the release. | If found is `'true'` |
| **asset-url** | URL of the asset in the release. | If found is `'true'` |
| **asset-id** | ID of the asset in the release. | If found is `'true'` |
| **asset-digest** | Digest of the asset in the release. | If found is `'true'` and the api provides a digest for the asset |
