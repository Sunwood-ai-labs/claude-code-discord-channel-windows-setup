# Troubleshooting

## `--channels ignored`

Typical causes:

- Claude Code is below `2.1.80`
- the `claude.ai` login is expired
- `ANTHROPIC_*` environment variables force API-billing mode

Try:

```powershell
.\scripts\Login-ClaudeAiForChannels.ps1
.\scripts\Start-ClaudeDiscord.ps1
```

## Bot is not online

Typical causes on Windows:

- Bun is not resolved from the plugin runtime
- the plugin `.mcp.json` became unreadable because of a BOM or bad encoding
- the Discord plugin update replaced Windows-specific fixes
- the token was not loaded into Claude's Discord `.env`

Try:

```powershell
.\scripts\Fix-DiscordPluginWindows.ps1
.\scripts\Import-DiscordBotTokenFromProjectEnv.ps1
.\scripts\Start-ClaudeDiscord.ps1
```

## `DISCORD_BOT_TOKEN required`

Check that the token exists in:

```text
C:\Users\<you>\.claude\channels\discord\.env
```

Then re-import it:

```powershell
.\scripts\Import-DiscordBotTokenFromProjectEnv.ps1
```

## `reply` says the channel is not allowlisted

If the Discord plugin says a DM channel is not allowlisted even though the sender is already paired, the plugin runtime may have lost the DM recipient mapping.

Try:

```powershell
.\scripts\Fix-DiscordPluginWindows.ps1
.\scripts\Start-ClaudeDiscord.ps1 -DangerouslySkipPermissions
```

This reapplies the Windows plugin patches and refreshes the Discord channel server with the latest `access.json`.

## Pairing works but replies do not appear

Check:

- the bot has been invited correctly
- `Message Content Intent` is enabled
- the DM policy or allowlist has not blocked the sender
- the Claude session is still running with channels enabled
