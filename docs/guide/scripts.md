# Scripts

## `Get-DiscordChannelStatus.ps1`

Shows:

- Claude Code version
- Bun version
- Discord plugin installation state
- masked token status
- access policy counts

## `Set-DiscordBotToken.ps1`

Writes `DISCORD_BOT_TOKEN` into:

```text
C:\Users\<you>\.claude\channels\discord\.env
```

It also prepares the default `access.json` structure used by the Discord channel plugin.

## `Import-DiscordBotTokenFromProjectEnv.ps1`

Reads the token from this repo's `.env` and forwards it to `Set-DiscordBotToken.ps1`.

Supported formats:

- `DISCORD_BOT_TOKEN=...`
- a single-line token file

## `Start-ClaudeDiscord.ps1`

Runs the Windows-safe startup path for Discord channels.

It:

- checks Claude Code version
- checks Claude.ai login validity
- removes `ANTHROPIC_*` API-billing overrides from the current process
- verifies that the Discord plugin is installed
- starts `claude --channels plugin:discord@claude-plugins-official`

## `Login-ClaudeAiForChannels.ps1`

Launches:

```powershell
claude auth login --claudeai
```

after clearing API-billing variables that can interfere with channels.

## `Fix-DiscordPluginWindows.ps1`

Reapplies the Windows-specific fixes required after plugin updates:

- force the plugin to launch through `bun.cmd`
- repair `.env` token loading in the plugin runtime
