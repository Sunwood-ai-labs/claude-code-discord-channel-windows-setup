# Claude Code Discord Channel セットアップ詳細レポート

作業日: 2026-03-20 (JST)  
作業ディレクトリ: `D:\Prj\remote-cc`

## 0. 作業開始時の依頼

今回の作業は、次の依頼から開始しました。

```text
下記のセットアップをして

https://github.com/anthropics/claude-plugins-official/blob/main/external_plugins/discord/README.md
```

つまり、Anthropic 公式の Discord plugin README を出発点として、Windows 環境上で Claude Code の Discord channel を実際に動作する状態まで持っていくことが目的でした。

## 1. 目的

最終的な目標は次の 6 点でした。

1. Claude Code から `--channels plugin:discord@claude-plugins-official` で起動できること
2. Discord bot token を適切な場所へ保存できること
3. Discord 側で real pairing が成功すること
4. Discord から送ったメッセージに Claude が返信すること
5. Windows 環境で再利用できる形にスクリプト化すること
6. どこで躓き、どう直したのかを README とレポートへ残すこと

## 2. 作業体制

この作業では、Codex 側で役割を分けながら進めました。役割イメージは次の通りです。

- 全体管理役
  - 公式手順の確認、作業順序の整理、最終判断を担当
- 要件監査役
  - 公式 README、channels docs、plugin manifest を確認して前提条件を整理
- ローカル検証役
  - Windows 上で plugin が実際に起動するか、process tree と実行経路を確認
- 反証役
  - 「本当に起動しているのか」「表示だけで成功扱いしていないか」を疑って検証

結果として、最初の見立てで見落とした点を途中で修正しながら、最終的には pairing と返信確認まで到達しました。

## 3. 初期状態

作業開始時点の状態は次の通りでした。

- ワークスペースはほぼ空
- Claude Code は `2.1.76`
- Bun は未導入
- `discord@claude-plugins-official` plugin は未導入
- Discord token は未設定
- 現在のシェルには `ANTHROPIC_BASE_URL` など API-billing 用の環境変数が残っていた

このため、README の手順をそのままなぞるだけではなく、Windows 固有の詰まりどころを一つずつ潰す必要がありました。

## 4. 実施したこと

### 4-1. 公式情報の確認

まず次の情報を確認しました。

- Discord plugin README
- Claude Code channels docs
- plugin の `.mcp.json`
- plugin の `server.ts`
- `package.json`

この確認で、次の前提を整理しました。

- Discord plugin は Bun で起動する
- token は `C:\Users\Aslan\.claude\channels\discord\.env` に `DISCORD_BOT_TOKEN=...` の形で入る
- access 制御は `access.json` で管理される
- channels は `Claude Code v2.1.80+` と `claude.ai` login が必要

### 4-2. Claude Code の更新

最初は marketplace 上で `discord@claude-plugins-official` が見えず、README 通りの導入がそのまま進みませんでした。

対応:

- Claude Code を `2.1.76` から `2.1.80` へ更新

更新後は marketplace から plugin を認識できるようになり、導入が進められる状態になりました。

### 4-3. Bun と plugin の導入

次に Bun を導入し、plugin を user scope でインストールしました。

対応:

- Bun `1.3.11` を導入
- `discord@claude-plugins-official` を user scope でインストール

plugin の本体は次の配下に展開されることを確認しました。

- `C:\Users\Aslan\.claude\plugins\cache\claude-plugins-official\discord\0.0.1`

### 4-4. 補助スクリプトの整備

README を読むだけでは何度も同じ確認や修正が必要になりそうだったため、再利用できる PowerShell スクリプトを整備しました。

作成・整備した主なファイル:

- `D:\Prj\remote-cc\README.md`
- `D:\Prj\remote-cc\README.ja.md`
- `D:\Prj\remote-cc\SETUP_REPORT.md`
- `D:\Prj\remote-cc\scripts\Get-DiscordChannelStatus.ps1`
- `D:\Prj\remote-cc\scripts\Set-DiscordBotToken.ps1`
- `D:\Prj\remote-cc\scripts\Import-DiscordBotTokenFromProjectEnv.ps1`
- `D:\Prj\remote-cc\scripts\Start-ClaudeDiscord.ps1`
- `D:\Prj\remote-cc\scripts\Login-ClaudeAiForChannels.ps1`
- `D:\Prj\remote-cc\scripts\Fix-DiscordPluginWindows.ps1`

これにより、token 取り込み、状態確認、再ログイン、起動、Windows 固有修正を再実行しやすくしました。

## 5. どこで躓いたか

今回の作業では、大きく 3 回つまずきました。

### 5-1. `--channels ignored` が出た

最初に Claude Code を起動したとき、次の表示が出ました。

- `--channels ignored (plugin:discord@claude-plugins-official)`
- `Channels are not currently available`

原因を調べると、問題は 2 つありました。

1. 起動シェルに API-billing 用の `ANTHROPIC_*` 環境変数が残っていて、Claude が `glm-5 / API Usage Billing` モードで起動していた
2. `claude.ai` OAuth が失効していた

確認できた失効日時:

- 失効していた `claude.ai` OAuth の期限: `2026-03-19 09:39:41 JST`

対応:

- `scripts/Login-ClaudeAiForChannels.ps1` を追加し、`claude auth login --claudeai` を clean な環境で実行できるようにした
- `scripts/Start-ClaudeDiscord.ps1` を修正し、channels 起動前に `ANTHROPIC_*` API-billing overrides を外すようにした
- 起動前に `claude.ai` OAuth の期限を確認する処理も追加した

再ログイン後の有効期限:

- 更新後の `claude.ai` OAuth 期限: `2026-03-20 22:17:47 JST`

この修正後、Claude Code 側に次の表示が出るようになりました。

```text
Listening for channel messages from: plugin:discord@claude-plugins-official
```

ここで初めて、channels 自体は有効になりました。

### 5-2. Claude は channels を聞いているのに bot が online にならない

次の問題は、Claude Code 側が channels を listen していても、Discord bot が online にならなかったことです。

最初は「起動したように見える」状態でしたが、実際には plugin runtime が落ちていました。

調査の結果、plugin 実行時に次のエラーが出ていました。

```text
'bun' is not recognized as an internal or external command
```

つまり、plugin の `.mcp.json` は `command: "bun"` を前提としていた一方で、Claude から見える PATH 上では `bun` が解決できていませんでした。

対応:

1. `C:\Users\Aslan\.local\bin\bun.cmd` を作成
   - 実体の `C:\Users\Aslan\.bun\bin\bun.exe` を呼ぶ wrapper として用意
2. plugin の `.mcp.json` を修正
   - `command: "bun"` から `command: "C:\\Users\\Aslan\\.local\\bin\\bun.cmd"` へ変更
3. cache 側と marketplace 側の両方に同じ修正を適用

修正後は process tree 上で次の形を確認できました。

- `claude.exe`
  - `cmd.exe`
    - `bun.exe`

これにより、「plugin サーバー自体が本当に起動している」ことを確認できました。

### 5-3. `DISCORD_BOT_TOKEN required` が出た

`bun` 問題を解消したあと、次は plugin 実行時に次のエラーが出ました。

```text
discord channel: DISCORD_BOT_TOKEN required
```

しかし、見た目上は `C:\Users\Aslan\.claude\channels\discord\.env` に token を置いていました。ここでさらに 2 つの原因が見つかりました。

#### (a) `.env` が BOM 付きで書かれていた

PowerShell の書き方によっては `.env` の先頭に BOM が入り、plugin 側の簡易 parser では `DISCORD_BOT_TOKEN=...` を正しく読めないことがありました。

対応:

- `scripts/Set-DiscordBotToken.ps1` を修正し、`.env` を BOM なしで書くように変更

#### (b) plugin 側の `.env` 読み込みが Windows に弱かった

plugin の `server.ts` は次の点で Windows に弱い実装でした。

- CRLF の `\r` を含んだまま解釈する可能性がある
- 空文字や余分な空白に弱い

対応:

- plugin の `server.ts` を修正
  - 行末の `\r` を除去
  - 空環境変数を除外
  - `DISCORD_BOT_TOKEN?.trim()` で token を読むよう補正

この修正後、plugin 起動時の `DISCORD_BOT_TOKEN required` は解消され、token が正しく使われるようになりました。

## 6. 実際に成功確認できたこと

最終的に、real Discord pairing と real message exchange まで確認できました。

成功ログの要点:

- `14:34`
  - Discord bot が pairing を要求
  - Claude Code 側で `/discord:access pair cdd6ad` を実行
  - bot が `Paired! Say hi to Claude.` と返答
- `14:36`
  - Discord 側から `こんにちは` を送信
  - bot が次の内容で正常応答

```text
こんにちは、maki_maki_aiさん！ペアリング承認されました。何かお手伝いできることはありますか？
```

この時点で、次の 6 点を実証できました。

1. Claude Code の channels session が生きている
2. Discord plugin サーバーが Windows 上で起動している
3. bot token が正しく読み込まれている
4. pairing が成功している
5. Discord から Claude への inbound message が届いている
6. Claude から Discord への outbound reply が返っている

## 7. 追加・変更したファイル

### ワークスペース内

- `D:\Prj\remote-cc\.gitignore`
- `D:\Prj\remote-cc\LICENSE`
- `D:\Prj\remote-cc\README.md`
- `D:\Prj\remote-cc\README.ja.md`
- `D:\Prj\remote-cc\SETUP_REPORT.md`
- `D:\Prj\remote-cc\scripts\Get-DiscordChannelStatus.ps1`
- `D:\Prj\remote-cc\scripts\Set-DiscordBotToken.ps1`
- `D:\Prj\remote-cc\scripts\Import-DiscordBotTokenFromProjectEnv.ps1`
- `D:\Prj\remote-cc\scripts\Start-ClaudeDiscord.ps1`
- `D:\Prj\remote-cc\scripts\Login-ClaudeAiForChannels.ps1`
- `D:\Prj\remote-cc\scripts\Fix-DiscordPluginWindows.ps1`
- `D:\Prj\remote-cc\docs\package.json`
- `D:\Prj\remote-cc\docs\package-lock.json`
- `D:\Prj\remote-cc\docs\.vitepress\config.mts`
- `D:\Prj\remote-cc\docs\index.md`
- `D:\Prj\remote-cc\docs\guide\windows-setup.md`
- `D:\Prj\remote-cc\docs\guide\scripts.md`
- `D:\Prj\remote-cc\docs\guide\troubleshooting.md`
- `D:\Prj\remote-cc\docs\ja\index.md`
- `D:\Prj\remote-cc\docs\ja\guide\windows-setup.md`
- `D:\Prj\remote-cc\docs\ja\guide\scripts.md`
- `D:\Prj\remote-cc\docs\ja\guide\troubleshooting.md`
- `D:\Prj\remote-cc\docs\public\icon.svg`
- `D:\Prj\remote-cc\docs\public\hero.svg`
- `D:\Prj\remote-cc\.github\workflows\docs.yml`

### ワークスペース外で調整した実環境ファイル

- `C:\Users\Aslan\.local\bin\bun.cmd`
- `C:\Users\Aslan\.claude\plugins\cache\claude-plugins-official\discord\0.0.1\.mcp.json`
- `C:\Users\Aslan\.claude\plugins\marketplaces\claude-plugins-official\external_plugins\discord\.mcp.json`
- `C:\Users\Aslan\.claude\plugins\cache\claude-plugins-official\discord\0.0.1\server.ts`
- `C:\Users\Aslan\.claude\plugins\marketplaces\claude-plugins-official\external_plugins\discord\server.ts`

## 8. 運用メモ

日常運用では、次のスクリプトを使えば十分です。

- 起動

```powershell
.\scripts\Start-ClaudeDiscord.ps1
```

- 状態確認

```powershell
.\scripts\Get-DiscordChannelStatus.ps1
```

- project `.env` から token を再取り込み

```powershell
.\scripts\Import-DiscordBotTokenFromProjectEnv.ps1
```

- channels 用の `claude.ai` 再ログイン

```powershell
.\scripts\Login-ClaudeAiForChannels.ps1
```

- plugin update 後の Windows 修正再適用

```powershell
.\scripts\Fix-DiscordPluginWindows.ps1
```

## 9. このチャットの生ログの場所

今回のメインチャット本体の raw log は、Codex の session JSONL として次に保存されています。

- `C:\Users\Aslan\.codex\sessions\2026\03\20\rollout-2026-03-20T13-45-17-019d098f-e045-7b93-a23c-c3890c8fec30.jsonl`

このスレッドの thread ID は次です。

- `019d098f-e045-7b93-a23c-c3890c8fec30`

今回の作業で使った subagent 側の raw log も、次の JSONL に保存されています。

- `C:\Users\Aslan\.codex\sessions\2026\03\20\rollout-2026-03-20T13-49-24-019d0993-a760-7c32-9aca-841ced1d027e.jsonl`
- `C:\Users\Aslan\.codex\sessions\2026\03\20\rollout-2026-03-20T13-49-31-019d0993-c03b-7ad3-9d16-ebc1457f4053.jsonl`
- `C:\Users\Aslan\.codex\sessions\2026\03\20\rollout-2026-03-20T13-50-02-019d0994-3b65-7b62-96b4-cad5bdb85032.jsonl`
- `C:\Users\Aslan\.codex\sessions\2026\03\20\rollout-2026-03-20T13-50-07-019d0994-4f9b-7501-96d1-df11fd3a8e06.jsonl`
- `C:\Users\Aslan\.codex\sessions\2026\03\20\rollout-2026-03-20T13-58-21-019d099b-d990-72f1-b8ed-60349a4274c1.jsonl`
- `C:\Users\Aslan\.codex\sessions\2026\03\20\rollout-2026-03-20T13-58-27-019d099b-eda2-75f1-a703-1384878c3ea6.jsonl`

索引は次です。

- `C:\Users\Aslan\.codex\session_index.jsonl`

## 10. 最終状態

このセットアップは、単なる「起動確認」ではなく、次の内容まで確認済みです。

- Windows 上での channels 起動条件の切り分け
- Claude Code の auth / provider 問題の修正
- Bun 解決失敗の修正
- token 読み込み失敗の修正
- real Discord pairing 成功
- real message exchange 成功

これにより、このリポジトリは Windows 用の Claude Code Discord channel セットアップ方法として、そのまま再利用できる状態になりました。
