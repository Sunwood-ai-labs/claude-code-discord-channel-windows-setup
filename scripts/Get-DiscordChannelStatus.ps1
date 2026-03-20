Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Get-BunCommand {
    $command = Get-Command bun -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    $fallback = Join-Path $HOME ".bun\bin\bun.exe"
    if (Test-Path $fallback) {
        return $fallback
    }

    return $null
}

function Read-DiscordEnv {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path $Path)) {
        return @{}
    }

    $values = @{}
    foreach ($line in Get-Content -Path $Path) {
        if ($line -match "^\s*([A-Za-z_][A-Za-z0-9_]*)=(.*)$") {
            $values[$matches[1]] = $matches[2]
        }
    }

    return $values
}

function Get-MaskedValue {
    param(
        [AllowNull()]
        [string]$Value
    )

    if ([string]::IsNullOrEmpty($Value)) {
        return "<not set>"
    }

    if ($Value.Length -le 6) {
        return ("*" * $Value.Length)
    }

    return "{0}{1}" -f $Value.Substring(0, 6), ("*" * 6)
}

function Get-EntryCount {
    param(
        $Value
    )

    if ($null -eq $Value) {
        return 0
    }

    if ($Value -is [System.Collections.IDictionary]) {
        return @($Value.Keys).Count
    }

    if ($Value -is [System.Management.Automation.PSCustomObject]) {
        return @($Value.PSObject.Properties | Where-Object { $_.MemberType -eq "NoteProperty" }).Count
    }

    if ($Value -is [System.Array]) {
        return $Value.Count
    }

    return 0
}

function Get-EntryNames {
    param(
        $Value
    )

    if ($null -eq $Value) {
        return @()
    }

    if ($Value -is [System.Collections.IDictionary]) {
        return @($Value.Keys)
    }

    if ($Value -is [System.Management.Automation.PSCustomObject]) {
        return @($Value.PSObject.Properties | Where-Object { $_.MemberType -eq "NoteProperty" } | ForEach-Object { $_.Name })
    }

    return @()
}

function Get-ListValues {
    param(
        $Value
    )

    if ($null -eq $Value) {
        return @()
    }

    if ($Value -is [string]) {
        return @($Value)
    }

    if ($Value -is [System.Collections.IDictionary]) {
        return @()
    }

    if ($Value -is [System.Collections.IEnumerable]) {
        return @($Value)
    }

    return @($Value)
}

$claudeVersion = (& claude --version)
$bunPath = Get-BunCommand
$bunVersion = if ($bunPath) { & $bunPath --version } else { "<missing>" }
$pluginList = (& claude plugin list --json | ConvertFrom-Json)
$discordPlugin = $pluginList | Where-Object { $_.id -eq "discord@claude-plugins-official" }

$channelRoot = Join-Path $HOME ".claude\channels\discord"
$envPath = Join-Path $channelRoot ".env"
$accessPath = Join-Path $channelRoot "access.json"
$envValues = Read-DiscordEnv -Path $envPath

if (Test-Path $accessPath) {
    $access = Get-Content -Raw -Path $accessPath | ConvertFrom-Json
} else {
    $access = [pscustomobject]@{
        dmPolicy = "pairing"
        allowFrom = @()
        groups = @{}
        pending = @{}
    }
}

$allowIds = @(Get-ListValues -Value $access.allowFrom | Where-Object { -not [string]::IsNullOrWhiteSpace([string]$_) })
$allowCount = $allowIds.Count
$groupCount = Get-EntryCount -Value $access.groups
$pendingCount = Get-EntryCount -Value $access.pending

Write-Host "Claude Code : $claudeVersion"
Write-Host "Bun         : $bunVersion"
Write-Host "Plugin       : $([bool]$discordPlugin)"
if ($discordPlugin) {
    Write-Host "Plugin Path  : $($discordPlugin.installPath)"
    Write-Host "Plugin State : enabled=$($discordPlugin.enabled)"
}
Write-Host "Token        : $(Get-MaskedValue -Value $envValues["DISCORD_BOT_TOKEN"])"
Write-Host "DM Policy    : $($access.dmPolicy)"
Write-Host "Allowlist    : $allowCount"
Write-Host "Groups       : $groupCount"
Write-Host "Pending      : $pendingCount"

if ($allowCount -gt 0) {
    Write-Host "Allowlist IDs: $($allowIds -join ', ')"
}

$groupIds = @(Get-EntryNames -Value $access.groups)
if ($groupIds.Count -gt 0) {
    Write-Host "Group IDs    : $($groupIds -join ', ')"
}

$pendingCodes = @(Get-EntryNames -Value $access.pending)
if ($pendingCodes.Count -gt 0) {
    Write-Host "Pending Codes: $($pendingCodes -join ', ')"
}
