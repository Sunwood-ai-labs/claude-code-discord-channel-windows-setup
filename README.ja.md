<p align="center">
  <img src="./docs/public/hero.svg" width="220" alt="Claude Code Discord channels の Windows セットアップイメージ">
</p>

<h1 align="center">Claude Code Discord Channel Windows Setup</h1>

<p align="center">
  公式の Claude Code Discord channel plugin を Windows 上で安定して動かすためのセットアップキットです。
  token 取り込み、channels 起動、Windows 固有の修正、トラブルシュートまでまとめています。
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

## 🚀 概要

このリポジトリは、Anthropic 公式の Discord channel plugin を Windows 上の Claude Code で再現性高くセットアップするためのものです。
PowerShell スクリプトにより、token 設定、起動、状態確認、`claude.ai` 再ログイン、Windows 固有修正をまとめて扱えます。

## ⚡ クイックスタート

1. Discord Developer Portal で Application と Bot を作成する
2. `Message Content Intent` を有効にする
3. Bot を参加中のサーバーへ招待する
4. project `.env` に token を入れるか、直接スクリプトに渡す
5. 次を順番に実行する

```powershell
.\scripts\Import-DiscordBotTokenFromProjectEnv.ps1
.\scripts\Login-ClaudeAiForChannels.ps1
.\scripts\Start-ClaudeDiscord.ps1
```

6. Discord で bot に DM を送る
7. Claude Code 側に pairing code が出たら次を実行する

```text
/discord:access pair <code>
```

8. pairing 成功後に allowlist へ切り替える

```text
/discord:access policy allowlist
```

## 🧰 同梱スクリプト

| スクリプト | 役割 |
| --- | --- |
| `scripts/Get-DiscordChannelStatus.ps1` | Claude Code / Bun / plugin / token / access policy の状態確認 |
| `scripts/Set-DiscordBotToken.ps1` | `DISCORD_BOT_TOKEN` を Claude 側 `.env` に保存 |
| `scripts/Import-DiscordBotTokenFromProjectEnv.ps1` | project `.env` から token を安全に取り込み |
| `scripts/Start-ClaudeDiscord.ps1` | `--channels plugin:discord@claude-plugins-official` で Claude を起動 |
| `scripts/Login-ClaudeAiForChannels.ps1` | channels 用に `claude.ai` ログインをやり直す |
| `scripts/Fix-DiscordPluginWindows.ps1` | plugin 更新後に Windows 固有修正を再適用 |

## 🪟 Windows での注意点

- channels は API-billing だけではなく `claude.ai` login を必要とします
- `ANTHROPIC_*` 環境変数が入っていると channels が無効化されることがあります
- plugin update 後に bot が online にならない場合は次を実行します

```powershell
.\scripts\Fix-DiscordPluginWindows.ps1
```

## 📚 ドキュメント

- GitHub Pages: [公開ドキュメント](https://sunwood-ai-labs.github.io/claude-code-discord-channel-windows-setup/)
- 英語ガイド: [docs/guide/windows-setup.md](./docs/guide/windows-setup.md)
- 日本語ガイド: [docs/ja/guide/windows-setup.md](./docs/ja/guide/windows-setup.md)
- 詳細レポート: [SETUP_REPORT.md](./SETUP_REPORT.md)

## 🗂 リポジトリ構成

```text
.
|-- docs/                         VitePress ドキュメント
|-- scripts/                      セットアップと修復用 PowerShell
|-- README.md                     英語 README
|-- README.ja.md                  日本語 README
|-- SETUP_REPORT.md               詳細作業レポート
`-- LICENSE                       MIT ライセンス
```

## 📄 ライセンス

このリポジトリは [MIT License](./LICENSE) で公開しています。
