# --- Configuration ---
$RepoPath = "C:\Users\Jacob\Code\nixos-config"
$OrcaSubPath = "orca"
$LogFile = "$RepoPath\orca-sync-log.txt"
$Time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

try {
    Set-Location $RepoPath
    "[$Time] Starting Sync..." | Out-File -FilePath $LogFile -Append

    # 1. Clean up permission noise
    git config core.filemode false

    # 2. Pull changes safely
    # We use --rebase to keep history clean. If there's a conflict, 
    # it will fail safely rather than deleting files.
    git pull --rebase origin main 2>&1 | Out-File -FilePath $LogFile -Append

    # 3. Check for new OrcaSlicer changes
    $HasChanges = git status --short $OrcaSubPath
    if ($HasChanges) {
        git add $OrcaSubPath
        git commit -m "orca: auto-update profiles $Time"
        git push origin main 2>&1 | Out-File -FilePath $LogFile -Append
        "[$Time] Successfully pushed Orca changes." | Out-File -FilePath $LogFile -Append
    } else {
        "[$Time] No Orca changes to sync." | Out-File -FilePath $LogFile -Append
    }
} catch {
    "[$Time] ERROR: $_" | Out-File -FilePath $LogFile -Append
}
