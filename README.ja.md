<p align="center">
  <img src="./docs/public/hero.svg" width="220" alt="Claude Code Discord channel の Windows セットアップ案内">
</p>

<h1 align="center">Claude Code Discord Channel Windows Setup</h1>

<p align="center">
  公式 Claude Code Discord channel plugin を Windows 上で安定して使うための
  セットアップキットです。token 取り込み、channels 起動、Windows 固有修正、
  トラブルシュートまでまとめています。
</p>

<p align="center">
  <a href="./README.md">English</a>
  |
  <a href="./README.ja.md">日本語</a>
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

## 概要

このリポジトリは、公式 Discord channel plugin の導入を Windows 向けに再現しやすい形へ整理したものです。
PowerShell スクリプトにより、token 設定、channels 起動、状態確認、`claude.ai` 再ログイン、Windows 固有修正まで一連で扱えます。

## 最短手順

1. Discord Developer Portal で application と bot を作成する
2. `Message Content Intent` を有効化する
3. bot を自分がいるサーバーへ招待する
4. token を project の `.env` に置く、または直接スクリプトへ渡す
5. 次のスクリプトを実行する

```powershell
.\scripts\Import-DiscordBotTokenFromProjectEnv.ps1
.\scripts\Login-ClaudeAiForChannels.ps1
.\scripts\Start-ClaudeDiscord.ps1
```

この session をデンジャラスモードで起動したい場合:

```powershell
.\scripts\Start-ClaudeDiscord.ps1 -DangerouslySkipPermissions
```

別の workspace で Claude Code を開きたい場合:

```powershell
.\scripts\Start-ClaudeDiscord.ps1 -WorkspacePath "D:\Prj\remote-cc-ws"
```

6. Discord で bot に DM を送る
7. Claude Code に pairing code が表示されたら次を実行する

```text
/discord:access pair <code>
```

8. pairing 成功後、必要に応じて allowlist モードへ切り替える

```text
/discord:access policy allowlist
```

## 同梱スクリプト

| スクリプト | 役割 |
| --- | --- |
| `scripts/Get-DiscordChannelStatus.ps1` | Claude Code、Bun、plugin、token、access policy の状態確認 |
| `scripts/Set-DiscordBotToken.ps1` | `DISCORD_BOT_TOKEN` を Claude の Discord channel `.env` に保存 |
| `scripts/Import-DiscordBotTokenFromProjectEnv.ps1` | この repo の `.env` から token を安全に取り込む |
| `scripts/Start-ClaudeDiscord.ps1` | `claude --channels plugin:discord@claude-plugins-official` で起動し、必要ならデンジャラスモードや workspace 指定も付与 |
| `scripts/Login-ClaudeAiForChannels.ps1` | `claude.ai` の再ログインを補助 |
| `scripts/Fix-DiscordPluginWindows.ps1` | plugin 更新後に必要な Windows 固有修正を再適用 |

## Windows での注意点

- channels は API-billing だけでは使えず、有効な `claude.ai` ログインが必要です。
- `ANTHROPIC_*` 環境変数が残っていると API-billing モードに入り、channels が無効になることがあります。
- plugin 更新後に bot が online にならない場合は、次を再実行してください。

```powershell
.\scripts\Fix-DiscordPluginWindows.ps1
```

## ドキュメント

- プロジェクトサイト: [GitHub Pages docs](https://sunwood-ai-labs.github.io/claude-code-discord-channel-windows-setup/)
- 英語ガイド: [docs/guide/windows-setup.md](./docs/guide/windows-setup.md)
- 日本語ガイド: [docs/ja/guide/windows-setup.md](./docs/ja/guide/windows-setup.md)
- docs 詳細レポート: [docs/ja/guide/setup-report.md](./docs/ja/guide/setup-report.md)
- 詳細レポート: [SETUP_REPORT.md](./SETUP_REPORT.md)

## リポジトリ構成

```text
.
|-- docs/                         VitePress ドキュメントサイト
|-- scripts/                      セットアップと修復用 PowerShell
|-- README.md                     英語 README
|-- README.ja.md                  日本語 README
|-- SETUP_REPORT.md               詳細レポート
`-- LICENSE                       MIT ライセンス
```

## ライセンス

このリポジトリは [MIT License](./LICENSE) で公開しています。
