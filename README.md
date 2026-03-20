<p align="center">
  <img src="./docs/public/hero.svg" width="220" alt="Windows setup kit illustration for Claude Code Discord channels">
</p>

<h1 align="center">Claude Code Discord Channel Windows Setup</h1>

<p align="center">
  Windows-first setup kit for running the official Claude Code Discord channel plugin reliably,
  including token import, channel startup, Windows-specific fixes, and troubleshooting.
</p>

<p align="center">
  <a href="./README.md">English</a>
  |
  <a href="./README.ja.md">Japanese</a>
</p>

<p align="center">
  <a href="https://github.com/Sunwood-ai-labs/claude-code-discord-channel-windows-setup/actions/workflows/docs.yml">
    <img src="https://github.com/Sunwood-ai-labs/claude-code-discord-channel-windows-setup/actions/workflows/docs.yml/badge.svg" alt="Docs workflow">
  </a>
  <img src="https://img.shields.io/badge/platform-Windows-0078D4" alt="Windows">
  <img src="https://img.shields.io/badge/Claude%20Code-v2.1.80%2B-6C47FF" alt="Claude Code 2.1.80+">
  <img src="https://img.shields.io/badge/Bun-1.3.11%2B-F9F1E1" alt="Bun 1.3.11+">
  <a href="./LICENSE">
    <img src="https://img.shields.io/badge/license-MIT-green" alt="MIT License">
  </a>
</p>

## Overview

This repository turns the official Discord channel plugin setup into a repeatable Windows workflow for Claude Code.
It includes PowerShell helpers for token import, startup, status checks, Claude.ai relogin, and Windows-specific plugin fixes.

## Quick Start

1. Create a Discord application and bot in the Discord Developer Portal.
2. Enable `Message Content Intent`.
3. Invite the bot to a server you are in.
4. Put your token in the project `.env`, or pass it directly to the token setup script.
5. Run the setup helpers below.

```powershell
.\scripts\Import-DiscordBotTokenFromProjectEnv.ps1
.\scripts\Login-ClaudeAiForChannels.ps1
.\scripts\Start-ClaudeDiscord.ps1
```

If you want to launch Claude in dangerous mode for the session:

```powershell
.\scripts\Start-ClaudeDiscord.ps1 -DangerouslySkipPermissions
```

If you want Claude Code to open a different workspace:

```powershell
.\scripts\Start-ClaudeDiscord.ps1 -WorkspacePath "D:\Prj\remote-cc-ws"
```

6. DM the bot on Discord.
7. When Claude shows a pairing code, run:

```text
/discord:access pair <code>
```

8. After pairing succeeds, lock the policy down:

```text
/discord:access policy allowlist
```

## Included Scripts

| Script | Purpose |
| --- | --- |
| `scripts/Get-DiscordChannelStatus.ps1` | Check Claude Code, Bun, plugin, token, and access-policy state |
| `scripts/Set-DiscordBotToken.ps1` | Save `DISCORD_BOT_TOKEN` into Claude's Discord channel `.env` |
| `scripts/Import-DiscordBotTokenFromProjectEnv.ps1` | Read the token from this repo's `.env` and forward it safely |
| `scripts/Start-ClaudeDiscord.ps1` | Launch Claude Code with `--channels plugin:discord@claude-plugins-official`, with optional dangerous mode and workspace override |
| `scripts/Login-ClaudeAiForChannels.ps1` | Re-authenticate with `claude.ai` when channels are blocked by expired login |
| `scripts/Fix-DiscordPluginWindows.ps1` | Reapply Windows-specific plugin fixes after plugin updates |

## Windows Notes

- Channels require a valid `claude.ai` login, not only API-billing credentials.
- The startup helper clears `ANTHROPIC_*` overrides that can force Claude Code into API-billing mode.
- If the Discord plugin stops coming online after an update, rerun:

```powershell
.\scripts\Fix-DiscordPluginWindows.ps1
```

## Documentation

- Project docs: [GitHub Pages docs](https://sunwood-ai-labs.github.io/claude-code-discord-channel-windows-setup/)
- English guide: [docs/guide/windows-setup.md](./docs/guide/windows-setup.md)
- Japanese guide: [docs/ja/guide/windows-setup.md](./docs/ja/guide/windows-setup.md)
- Docs setup report: [docs/guide/setup-report.md](./docs/guide/setup-report.md)
- Detailed setup report: [SETUP_REPORT.md](./SETUP_REPORT.md)

## Repository Layout

```text
.
|-- docs/                         VitePress documentation site
|-- scripts/                      PowerShell helpers for setup and repair
|-- README.md                     English overview
|-- README.ja.md                  Japanese overview
|-- SETUP_REPORT.md               Detailed setup report
`-- LICENSE                       MIT license
```

## License

This repository is released under the [MIT License](./LICENSE).
