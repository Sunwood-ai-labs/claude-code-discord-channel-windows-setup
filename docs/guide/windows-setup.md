# Windows Setup

## Prerequisites

- Claude Code `v2.1.80` or later
- A valid `claude.ai` login
- A Discord application and bot
- `Message Content Intent` enabled
- Bun installed

## Step 1. Prepare the Discord bot

1. Create the application and bot in the Discord Developer Portal.
2. Enable `Message Content Intent`.
3. Invite the bot to a server you are in.

## Step 2. Store the bot token

If your repo `.env` already contains the token:

```powershell
.\scripts\Import-DiscordBotTokenFromProjectEnv.ps1
```

If you want to pass it directly:

```powershell
.\scripts\Set-DiscordBotToken.ps1 -Token "<your-bot-token>"
```

## Step 3. Refresh the Claude.ai login when needed

```powershell
.\scripts\Login-ClaudeAiForChannels.ps1
```

This is especially important when your shell normally uses API-billing environment variables and Claude Code starts in a non-`claude.ai` mode.

## Step 4. Start Claude Code with Discord channels

```powershell
.\scripts\Start-ClaudeDiscord.ps1
```

Successful startup shows:

```text
Listening for channel messages from: plugin:discord@claude-plugins-official
```

If you want to start the session with dangerous mode enabled:

```powershell
.\scripts\Start-ClaudeDiscord.ps1 -DangerouslySkipPermissions
```

## Step 5. Pair the bot

1. Send a DM to the bot on Discord.
2. Claude Code will show a pairing instruction.
3. Run:

```text
/discord:access pair <code>
```

4. After pairing succeeds, lock access down:

```text
/discord:access policy allowlist
```

## Step 6. Verify the setup

Use the status helper:

```powershell
.\scripts\Get-DiscordChannelStatus.ps1
```

You should see:

- plugin installed and enabled
- token present
- DM policy shown
- allowlist and pending counts
