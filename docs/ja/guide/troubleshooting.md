# トラブルシュート

## `--channels ignored` が出る

よくある原因:

- Claude Code が `2.1.80` 未満
- `claude.ai` login が失効している
- `ANTHROPIC_*` 環境変数で API-billing モードになっている

試すこと:

```powershell
.\scripts\Login-ClaudeAiForChannels.ps1
.\scripts\Start-ClaudeDiscord.ps1
```

## bot が online にならない

Windows で多い原因:

- plugin 実行時に Bun が解決できていない
- plugin update により Windows 固有修正が上書きされた
- Claude 側の Discord `.env` に token が読み込まれていない

試すこと:

```powershell
.\scripts\Fix-DiscordPluginWindows.ps1
.\scripts\Import-DiscordBotTokenFromProjectEnv.ps1
.\scripts\Start-ClaudeDiscord.ps1
```

## `DISCORD_BOT_TOKEN required` が出る

次に token があるか確認してください。

```text
C:\Users\<you>\.claude\channels\discord\.env
```

その後、再取り込みします。

```powershell
.\scripts\Import-DiscordBotTokenFromProjectEnv.ps1
```

## `reply` が `channel is not allowlisted` になる

pairing 済みなのに DM channel が allowlist 外だと判断される場合は、plugin runtime 側で DM の相手情報が欠けている可能性があります。

試すこと:

```powershell
.\scripts\Fix-DiscordPluginWindows.ps1
.\scripts\Start-ClaudeDiscord.ps1 -DangerouslySkipPermissions
```

これで Windows 向け plugin 修正を再適用しつつ、最新の `access.json` を読む状態で Discord channel サーバーを起動し直せます。

## pairing は通るのに返信が出ない

次を確認してください。

- bot が正しく招待されているか
- `Message Content Intent` が有効か
- DM policy または allowlist により送信者が弾かれていないか
- channels 付きの Claude session がまだ起動中か
