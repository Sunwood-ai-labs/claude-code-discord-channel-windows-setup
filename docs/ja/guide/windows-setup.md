# Windows セットアップ

## 前提条件

- Claude Code `v2.1.80` 以上
- 有効な `claude.ai` ログイン
- Discord Application と Bot
- `Message Content Intent` の有効化
- Bun のインストール

## 手順 1. Discord bot を準備する

1. Discord Developer Portal で Application と Bot を作成する
2. `Message Content Intent` を有効化する
3. bot を自分が参加しているサーバーへ招待する

## 手順 2. Bot token を保存する

project の `.env` に token がある場合:

```powershell
.\scripts\Import-DiscordBotTokenFromProjectEnv.ps1
```

直接 token を渡す場合:

```powershell
.\scripts\Set-DiscordBotToken.ps1 -Token "<your-bot-token>"
```

## 手順 3. 必要に応じて Claude.ai login を更新する

```powershell
.\scripts\Login-ClaudeAiForChannels.ps1
```

普段のシェルで API-billing 用の `ANTHROPIC_*` 環境変数を使っている場合は、特に重要です。

## 手順 4. Discord channel 付きで Claude Code を起動する

```powershell
.\scripts\Start-ClaudeDiscord.ps1
```

成功すると、次の表示が出ます。

```text
Listening for channel messages from: plugin:discord@claude-plugins-official
```

この session をデンジャラスモード付きで起動したい場合:

```powershell
.\scripts\Start-ClaudeDiscord.ps1 -DangerouslySkipPermissions
```

## 手順 5. pairing する

1. Discord で bot に DM を送る
2. Claude Code 側に pairing 指示が表示される
3. 次を実行する

```text
/discord:access pair <code>
```

4. pairing 成功後、必要に応じて allowlist へ切り替える

```text
/discord:access policy allowlist
```

## 手順 6. 状態を確認する

状態確認は次です。

```powershell
.\scripts\Get-DiscordChannelStatus.ps1
```

次のような情報を確認できます。

- plugin が導入済みか
- token が設定されているか
- DM policy の状態
- allowlist と pending の件数
