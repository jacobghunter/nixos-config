# --- Configuration ---
$RepoPath = "C:\Users\Jacob\Code\nixos-config"
$OrcaSubPath = "orca"
$CommitMessage = "orca: auto-update profiles $(Get-Date -Format 'yyyy-MM-dd HH:mm')"

Set-Location $RepoPath

# 1. Pull latest changes to stay in sync
# --rebase keeps the history linear
git pull --rebase origin main

# 2. Check for local changes
$HasChanges = git status --short $OrcaSubPath

if ($HasChanges) {
    git add $OrcaSubPath
    git commit -m $CommitMessage
    git push origin main
    Write-Host "Sync complete!" -ForegroundColor Green
}
