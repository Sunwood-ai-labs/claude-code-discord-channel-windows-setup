# Windows セットアップ

## 前提条件

- Claude Code `v2.1.80` 以上
- 有効な `claude.ai` login
- Discord Application / Bot
- `Message Content Intent` の有効化
- Bun のインストール

## 手順 1. Discord bot を準備する

1. Discord Developer Portal で Application と Bot を作成する
2. `Message Content Intent` を有効にする
3. Bot を自分が参加しているサーバーへ招待する

## 手順 2. Bot token を保存する

project の `.env` を使う場合:

```powershell
.\scripts\Import-DiscordBotTokenFromProjectEnv.ps1
```

直接 token を渡す場合:

```powershell
.\scripts\Set-DiscordBotToken.ps1 -Token "<your-bot-token>"
```

## 手順 3. channels 用に Claude.ai login を更新する

```powershell
.\scripts\Login-ClaudeAiForChannels.ps1
```

これは、普段 API-billing 用の `ANTHROPIC_*` 変数を使っている環境で特に重要です。

## 手順 4. Discord channel 付きで Claude Code を起動する

```powershell
.\scripts\Start-ClaudeDiscord.ps1
```

成功すると、次の表示が出ます。

```text
Listening for channel messages from: plugin:discord@claude-plugins-official
```

## 手順 5. pairing する

1. Discord で bot に DM を送る
2. Claude Code 側に pairing 指示が出る
3. 次を実行する

```text
/discord:access pair <code>
```

4. 成功後は次で allowlist に切り替える

```text
/discord:access policy allowlist
```

## 手順 6. 状態確認する

```powershell
.\scripts\Get-DiscordChannelStatus.ps1
```

ここで plugin、token、DM policy、allowlist 件数などを確認できます。
