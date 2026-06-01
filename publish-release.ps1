param(
  [string]$RepoName = "idle-shutdown-guard",
  [string]$Version = "0.2.0",
  [string]$Tag = "v$Version"
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
  throw "GitHub CLI 'gh' is not installed or is not in PATH."
}

$repoPath = (Resolve-Path -LiteralPath $PSScriptRoot).Path
Set-Location -LiteralPath $repoPath

git config --global --add safe.directory ($repoPath -replace "\\", "/") | Out-Null

gh auth status
if ($LASTEXITCODE -ne 0) {
  throw "GitHub CLI is not authenticated. Run: gh auth login -h github.com"
}

$remotes = @(git remote)
if ($remotes -notcontains "origin") {
  gh repo create $RepoName --private --source . --remote origin --push
} else {
  git push -u origin main
}

git push origin $Tag

$archivePath = Resolve-Path -LiteralPath (Join-Path $repoPath "..\idle-shutdown-guard-$Version.tar.gz")

$releaseTags = @(gh release list --json tagName --jq ".[].tagName")
if ($releaseTags -contains $Tag) {
  gh release edit $Tag `
    --title "idle-shutdown-guard $Tag" `
    --notes-file RELEASE.md
  gh release upload $Tag $archivePath --clobber
} else {
  gh release create $Tag $archivePath `
    --title "idle-shutdown-guard $Tag" `
    --notes-file RELEASE.md
}

gh repo view --web
