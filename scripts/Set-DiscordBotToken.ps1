param(
    [string]$Token,
    [switch]$Clear
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ($Clear -and $Token) {
    throw "Use either -Token or -Clear, not both."
}

if (-not $Clear -and [string]::IsNullOrWhiteSpace($Token)) {
    throw "Provide -Token <discord bot token> or use -Clear."
}

$channelRoot = Join-Path $HOME ".claude\channels\discord"
$envPath = Join-Path $channelRoot ".env"
$accessPath = Join-Path $channelRoot "access.json"
$approvedPath = Join-Path $channelRoot "approved"
$inboxPath = Join-Path $channelRoot "inbox"

New-Item -ItemType Directory -Force -Path $channelRoot | Out-Null
New-Item -ItemType Directory -Force -Path $approvedPath | Out-Null
New-Item -ItemType Directory -Force -Path $inboxPath | Out-Null

$lines = New-Object "System.Collections.Generic.List[string]"
if (Test-Path $envPath) {
    foreach ($line in Get-Content -Path $envPath) {
        [void]$lines.Add($line)
    }
}

for ($i = $lines.Count - 1; $i -ge 0; $i--) {
    if ($lines[$i] -match "^DISCORD_BOT_TOKEN=") {
        $lines.RemoveAt($i)
    }
}

if (-not $Clear) {
    $lines.Add("DISCORD_BOT_TOKEN=$($Token.Trim())")
}

if ($lines.Count -eq 0) {
    if (Test-Path $envPath) {
        Remove-Item -Force $envPath
    }
} else {
    $content = ($lines -join [Environment]::NewLine) + [Environment]::NewLine
    [System.IO.File]::WriteAllText($envPath, $content, [System.Text.ASCIIEncoding]::new())
}

$existingAccess = if (Test-Path $accessPath) {
    Get-Content -Raw -Path $accessPath | ConvertFrom-Json
} else {
    [pscustomobject]@{}
}

$mergedAccess = [ordered]@{
    dmPolicy = if ($existingAccess.PSObject.Properties["dmPolicy"]) { $existingAccess.dmPolicy } else { "pairing" }
    allowFrom = if ($existingAccess.PSObject.Properties["allowFrom"]) { @($existingAccess.allowFrom) } else { @() }
    groups = if ($existingAccess.PSObject.Properties["groups"]) { $existingAccess.groups } else { @{} }
    pending = if ($existingAccess.PSObject.Properties["pending"]) { $existingAccess.pending } else { @{} }
    mentionPatterns = if ($existingAccess.PSObject.Properties["mentionPatterns"]) { @($existingAccess.mentionPatterns) } else { @() }
    ackReaction = if ($existingAccess.PSObject.Properties["ackReaction"]) { $existingAccess.ackReaction } else { "" }
    replyToMode = if ($existingAccess.PSObject.Properties["replyToMode"]) { $existingAccess.replyToMode } else { "first" }
    textChunkLimit = if ($existingAccess.PSObject.Properties["textChunkLimit"]) { $existingAccess.textChunkLimit } else { 2000 }
    chunkMode = if ($existingAccess.PSObject.Properties["chunkMode"]) { $existingAccess.chunkMode } else { "newline" }
}

$mergedAccess | ConvertTo-Json -Depth 10 | Set-Content -Path $accessPath -Encoding utf8

if ($Clear) {
    Write-Host "Removed DISCORD_BOT_TOKEN from $envPath"
} else {
    $masked = if ($Token.Length -gt 6) { "{0}{1}" -f $Token.Substring(0, 6), ("*" * 6) } else { "*" * $Token.Length }
    Write-Host "Saved DISCORD_BOT_TOKEN to $envPath"
    Write-Host "Token        : $masked"
    Write-Host "Next step    : .\\scripts\\Start-ClaudeDiscord.ps1"
}
