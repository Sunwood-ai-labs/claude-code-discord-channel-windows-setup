param(
    [string]$EnvPath = (Join-Path $PSScriptRoot "..\.env")
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if (-not (Test-Path $EnvPath)) {
    throw ".env file not found at $EnvPath"
}

$lines = @(Get-Content -Path $EnvPath | Where-Object { -not [string]::IsNullOrWhiteSpace($_) -and $_ -notmatch "^\s*#" })
$tokenLine = $lines | Where-Object { $_ -match "^\s*DISCORD_BOT_TOKEN\s*=" } | Select-Object -First 1

if ($tokenLine) {
    $token = ($tokenLine -replace "^\s*DISCORD_BOT_TOKEN\s*=\s*", "").Trim()
} elseif ($lines.Count -eq 1) {
    $token = $lines[0].Trim()
} else {
    throw "DISCORD_BOT_TOKEN was not found in $EnvPath"
}

$token = $token.Trim('"').Trim("'")
if ([string]::IsNullOrWhiteSpace($token)) {
    throw "DISCORD_BOT_TOKEN is empty in $EnvPath"
}

$setScript = Join-Path $PSScriptRoot "Set-DiscordBotToken.ps1"
powershell -ExecutionPolicy Bypass -File $setScript -Token $token
