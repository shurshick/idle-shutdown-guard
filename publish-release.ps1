param(
  [string]$RepoName = "idle-shutdown-guard",
  [string]$Tag = "v0.1.0"
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
  throw "GitHub CLI 'gh' is not installed or is not in PATH."
}

$repoPath = (Resolve-Path -LiteralPath $PSScriptRoot).Path
Set-Location -LiteralPath $repoPath

git config --global --add safe.directory ($repoPath -replace "\\", "/") | Out-Null

gh auth status

$remotes = @(git remote)
if ($remotes -notcontains "origin") {
  gh repo create $RepoName --private --source . --remote origin --push
} else {
  git push -u origin main
}

git push origin $Tag

$archivePath = Resolve-Path -LiteralPath (Join-Path $repoPath "..\idle-shutdown-guard-0.1.0.tar.gz")

$releaseTags = @(gh release list --json tagName --jq ".[].tagName")
if ($releaseTags -contains $Tag) {
  gh release upload $Tag $archivePath --clobber
} else {
  gh release create $Tag $archivePath `
    --title "idle-shutdown-guard $Tag" `
    --notes-file RELEASE.md
}

gh repo view --web
