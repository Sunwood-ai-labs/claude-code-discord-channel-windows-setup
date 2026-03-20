# トラブルシュート

## `--channels ignored` が出る

よくある原因:

- Claude Code が `2.1.80` 未満
- `claude.ai` login が失効している
- `ANTHROPIC_*` 環境変数のせいで API-billing モードになっている

対処:

```powershell
.\scripts\Login-ClaudeAiForChannels.ps1
.\scripts\Start-ClaudeDiscord.ps1
```

## bot が online にならない

Windows では次が原因になりやすいです。

- plugin 実行時に Bun が解決できていない
- plugin update で Windows 固有修正が消えた
- token が Claude 側 `.env` に正しく反映されていない

対処:

```powershell
.\scripts\Fix-DiscordPluginWindows.ps1
.\scripts\Import-DiscordBotTokenFromProjectEnv.ps1
.\scripts\Start-ClaudeDiscord.ps1
```

## `DISCORD_BOT_TOKEN required` が出る

次に token があるか確認します。

```text
C:\Users\<you>\.claude\channels\discord\.env
```

そのうえで、再取り込みします。

```powershell
.\scripts\Import-DiscordBotTokenFromProjectEnv.ps1
```

## pairing は通るが返信が来ない

次を確認します。

- bot が正しく招待されているか
- `Message Content Intent` が有効か
- DM policy / allowlist が送信者を弾いていないか
- channels 付きの Claude セッションが動き続けているか
