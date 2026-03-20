# スクリプト一覧

## `Get-DiscordChannelStatus.ps1`

次を表示します。

- Claude Code のバージョン
- Bun のバージョン
- Discord plugin の状態
- token の設定状態
- access policy の件数

## `Set-DiscordBotToken.ps1`

`DISCORD_BOT_TOKEN` を次へ保存します。

```text
C:\Users\<you>\.claude\channels\discord\.env
```

あわせて、Discord channel plugin が使う `access.json` の初期構造も整えます。

## `Import-DiscordBotTokenFromProjectEnv.ps1`

この repo の `.env` から token を読み取り、`Set-DiscordBotToken.ps1` へ渡します。

対応形式:

- `DISCORD_BOT_TOKEN=...`
- token 単体の 1 行ファイル

## `Start-ClaudeDiscord.ps1`

Windows 向け前処理を含めて Discord channels を起動します。

主な処理:

- Claude Code のバージョン確認
- Claude.ai login 期限確認
- `ANTHROPIC_*` API-billing overrides の除去
- Discord plugin install 状態確認
- `claude --channels plugin:discord@claude-plugins-official` 実行

## `Login-ClaudeAiForChannels.ps1`

次を実行します。

```powershell
claude auth login --claudeai
```

同時に、channels を邪魔する API-billing 系環境変数を現在の process から外します。

## `Fix-DiscordPluginWindows.ps1`

plugin update 後に必要になる Windows 固有修正を再適用します。

- `bun.cmd` 経由で plugin を起動するよう補正
- plugin 側 `.env` token 読み込み処理を補正
