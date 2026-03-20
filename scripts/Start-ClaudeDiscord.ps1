param(
    [switch]$EnsurePluginInstalled,

    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$ClaudeArgs
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ClaudeArgs = @($ClaudeArgs)

function Ensure-BunOnPath {
    $bun = Get-Command bun -ErrorAction SilentlyContinue
    if ($bun) {
        return $bun.Source
    }

    $fallback = Join-Path $HOME ".bun\bin\bun.exe"
    if (Test-Path $fallback) {
        $env:Path = "{0};{1}" -f (Split-Path $fallback -Parent), $env:Path
        return $fallback
    }

    throw "Bun is not installed. Install it first with the official installer."
}

function Get-RequiredVersion {
    return [version]"2.1.80"
}

function Get-InstalledClaudeVersion {
    $raw = & claude --version
    if ($raw -match "(\d+\.\d+\.\d+)") {
        return [version]$matches[1]
    }

    throw "Could not parse Claude Code version from: $raw"
}

function Clear-ChannelsBlockingAnthropicEnv {
    $vars = @(
        "ANTHROPIC_API_KEY",
        "ANTHROPIC_AUTH_TOKEN",
        "ANTHROPIC_BASE_URL",
        "ANTHROPIC_MODEL",
        "ANTHROPIC_SMALL_FAST_MODEL",
        "ANTHROPIC_DEFAULT_OPUS_MODEL",
        "ANTHROPIC_DEFAULT_SONNET_MODEL",
        "ANTHROPIC_DEFAULT_HAIKU_MODEL"
    )

    $removed = @()
    foreach ($name in $vars) {
        if (Test-Path "Env:$name") {
            Remove-Item "Env:$name" -ErrorAction SilentlyContinue
            $removed += $name
        }
    }

    return $removed
}

function Get-ClaudeAiCredentialExpiry {
    $credentialsPath = Join-Path $HOME ".claude\.credentials.json"
    if (-not (Test-Path $credentialsPath)) {
        return $null
    }

    try {
        $credentials = Get-Content -Raw -Path $credentialsPath | ConvertFrom-Json
    } catch {
        return $null
    }

    if (-not $credentials.claudeAiOauth) {
        return $null
    }

    return [DateTimeOffset]::FromUnixTimeMilliseconds([int64]$credentials.claudeAiOauth.expiresAt)
}

function Test-DiscordTokenConfigured {
    if ($env:DISCORD_BOT_TOKEN) {
        return $true
    }

    $envPath = Join-Path $HOME ".claude\channels\discord\.env"
    if (-not (Test-Path $envPath)) {
        return $false
    }

    foreach ($line in Get-Content -Path $envPath) {
        if ($line -match "^DISCORD_BOT_TOKEN=") {
            return $true
        }
    }

    return $false
}

[void](Ensure-BunOnPath)
$removedAnthropicVars = @(Clear-ChannelsBlockingAnthropicEnv)

$installedVersion = Get-InstalledClaudeVersion
$requiredVersion = Get-RequiredVersion
if ($installedVersion -lt $requiredVersion) {
    throw "Claude Code $requiredVersion or later is required for channels. Found: $installedVersion"
}

$authStatus = & claude auth status | ConvertFrom-Json
if (-not $authStatus.loggedIn) {
    throw "Claude Code is not logged in. Run 'claude auth login' first."
}

$claudeAiExpiry = Get-ClaudeAiCredentialExpiry
if ($null -eq $claudeAiExpiry) {
    throw "Channels require a claude.ai login, but no local claude.ai OAuth credentials were found. Run .\\scripts\\Login-ClaudeAiForChannels.ps1 first."
}

if ($claudeAiExpiry -le [DateTimeOffset]::UtcNow) {
    $localExpiry = $claudeAiExpiry.ToLocalTime().ToString("yyyy-MM-dd HH:mm:ss zzz")
    throw "Channels require a valid claude.ai login. The local claude.ai OAuth token expired at $localExpiry. Run .\\scripts\\Login-ClaudeAiForChannels.ps1 first."
}

$plugins = & claude plugin list --json | ConvertFrom-Json
$discordPlugin = $plugins | Where-Object { $_.id -eq "discord@claude-plugins-official" }
if (-not $discordPlugin) {
    if ($EnsurePluginInstalled) {
        Write-Host "Installing discord@claude-plugins-official..."
        & claude plugin install discord@claude-plugins-official
        $plugins = & claude plugin list --json | ConvertFrom-Json
        $discordPlugin = $plugins | Where-Object { $_.id -eq "discord@claude-plugins-official" }
    } else {
        throw "Discord plugin is not installed. Install it with 'claude plugin install discord@claude-plugins-official' or rerun this script with -EnsurePluginInstalled."
    }
}

if (-not $discordPlugin) {
    throw "Discord plugin is not installed."
}

if (-not $discordPlugin.enabled) {
    throw "Discord plugin is installed but disabled. Enable it with 'claude plugin enable discord@claude-plugins-official'."
}

if (-not (Test-DiscordTokenConfigured)) {
    throw "DISCORD_BOT_TOKEN is not configured. Run .\\scripts\\Set-DiscordBotToken.ps1 -Token <token> first."
}

$arguments = @("--channels", "plugin:discord@claude-plugins-official") + $ClaudeArgs
Write-Host "Starting Claude Code with Discord channel support..."
if ($removedAnthropicVars.Count -gt 0) {
    Write-Host "Cleared API-billing env overrides: $($removedAnthropicVars -join ', ')"
}
Write-Host ("claude " + ($arguments -join " "))

& claude @arguments
