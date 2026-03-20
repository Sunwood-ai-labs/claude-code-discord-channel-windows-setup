# スクリプト一覧

## `Get-DiscordChannelStatus.ps1`

次を表示します。

- Claude Code のバージョン
- Bun のバージョン
- Discord plugin の導入状態
- token のマスク付き状態
- access policy の件数

## `Set-DiscordBotToken.ps1`

`DISCORD_BOT_TOKEN` を次へ保存します。

```text
C:\Users\<you>\.claude\channels\discord\.env
```

あわせて、Discord channel plugin が使う `access.json` の初期構造も準備します。

## `Import-DiscordBotTokenFromProjectEnv.ps1`

この repo の `.env` から token を読み取り、`Set-DiscordBotToken.ps1` へ安全に渡します。

対応形式:

- `DISCORD_BOT_TOKEN=...`
- token だけが 1 行で書かれたファイル

## `Start-ClaudeDiscord.ps1`

Windows 向けの安全な Discord channels 起動経路を実行します。

主な処理:

- Claude Code のバージョン確認
- Claude.ai login の有効期限確認
- `ANTHROPIC_*` API-billing overrides の除去
- Discord plugin の導入確認
- `claude --channels plugin:discord@claude-plugins-official` の起動

任意のスイッチ:

- `-DangerouslySkipPermissions`
  - その session に対して `--dangerously-skip-permissions` を付けて Claude を起動します

## `Login-ClaudeAiForChannels.ps1`

次を起動します。

```powershell
claude auth login --claudeai
```

channels を阻害する API-billing 環境変数を外した状態でログインし直せます。

## `Fix-DiscordPluginWindows.ps1`

plugin 更新後に必要な Windows 固有修正を再適用します。

- `bun.cmd` 経由で plugin を起動するよう補正
- plugin 実行時の `.env` token 読み込み処理を修正
- fetched DM channel で `recipientId` が欠けた場合の allowlist 判定も補修
