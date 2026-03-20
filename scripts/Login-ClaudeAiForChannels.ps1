Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

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

    foreach ($name in $vars) {
        Remove-Item "Env:$name" -ErrorAction SilentlyContinue
    }
}

Clear-ChannelsBlockingAnthropicEnv
& claude auth login --claudeai
