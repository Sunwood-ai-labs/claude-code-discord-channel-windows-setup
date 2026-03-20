# Claude Code Discord Channel セットアップ詳細レポート

作成日: 2026-03-20 (JST)
作業ディレクトリ: `D:\Prj\remote-cc`

## 0. 作業開始時の依頼

今回の作業は、次のユーザープロンプトを起点として開始した。

```text
下記のセットアップをして

https://github.com/anthropics/claude-plugins-official/blob/main/external_plugins/discord/README.md
```

## 1. 目的

Anthropic 公式の Discord channel plugin を、この Windows 環境の Claude Code で実際に動く状態まで持っていくことを目的として作業を実施した。

単に README のコマンドをなぞるだけではなく、以下まで到達することを完了条件とした。

1. Claude Code から `--channels plugin:discord@claude-plugins-official` で起動できること
2. Discord bot token を安全に設定できること
3. Discord 側で real pairing が成功すること
4. Discord からのメッセージに Claude が応答すること
5. 将来の再起動や plugin update に備えて、作業内容をスクリプトとレポートに残すこと

## 2. エージェント体制

今回の作業では、Codex Spark Eclipse Legion の流れに沿って複数レーンで進めた。

- Manager: 全体方針の決定、実装、検証、最終統合
- `ルナ・シオン / 蒼路の要件監査官`
  - 公式 README / ACCESS / plugin manifest を読み、要件と blocking point を整理
- `ノア・ヴェイル / 境界を開く装填術師`
  - Windows での local plugin loading と `--channels` の成立条件を検証
- `アイラ・モーヴ / 静謐の意匠監査官`
  - UI 変更有無を確認し、Material Design review は `not_applicable` と判断
- Devil's Advocate
  - 見落とし、運用リスク、未検証点を洗い出し

## 3. 初期状態

作業開始時点での状況は次の通りだった。

- ワークスペースはほぼ空で、運用用スクリプトや手順書は存在しなかった
- Claude Code は `2.1.76`
- Bun は未導入
- `discord@claude-plugins-official` plugin は未インストール
- Discord token も未設定
- さらに、このマシンのシェル環境には `ANTHROPIC_BASE_URL` などの API-billing 用環境変数が入っていた

この状態では、公式 README どおりに進めてもそのまま成功する保証はないと判断した。

## 4. 実施した作業の流れ

### 4-1. 公式要件の確認

まず、公式の以下を確認した。

- Discord plugin README
- ACCESS.md
- plugin manifest (`.mcp.json`, `plugin.json`)
- `package.json`
- Claude Code channels 公式ドキュメント

ここで分かった主要要件は次の通り。

- Discord plugin は Bun ベースで起動する
- bot token は `C:\Users\Aslan\.claude\channels\discord\.env` の `DISCORD_BOT_TOKEN=...` で読む
- access 制御は `C:\Users\Aslan\.claude\channels\discord\access.json` で管理する
- channels は `Claude Code v2.1.80+` かつ `claude.ai` login が必要

### 4-2. Claude Code の更新

当初は marketplace 上で `discord@claude-plugins-official` が見えず、README の install 手順が通らなかった。

調査の結果、原因は Claude Code のバージョン不足だった。

実施内容:

- Claude Code を `2.1.76` から `2.1.80` へ更新

更新後は marketplace に `discord@claude-plugins-official` が現れ、plugin install が実行可能になった。

### 4-3. Bun と plugin の導入

次に Bun を導入し、plugin 本体をインストールした。

実施内容:

- Bun `1.3.11` を導入
- `discord@claude-plugins-official` を user scope でインストール

この段階で plugin のファイル群は `C:\Users\Aslan\.claude\plugins\cache\claude-plugins-official\discord\0.0.1` に展開された。

### 4-4. 補助スクリプトと README の整備

そのまま毎回手で設定するのは再現性が低いため、以下をワークスペースに整備した。

- `README.md`
- `scripts/Get-DiscordChannelStatus.ps1`
- `scripts/Set-DiscordBotToken.ps1`
- `scripts/Import-DiscordBotTokenFromProjectEnv.ps1`
- `scripts/Start-ClaudeDiscord.ps1`
- `scripts/Login-ClaudeAiForChannels.ps1`
- `scripts/Fix-DiscordPluginWindows.ps1`

これにより、token 取り込み、状態確認、起動、再ログイン、Windows 向け再補正が一通りスクリプト化された。

## 5. 実際に詰まったポイントと対応

今回の作業は、README を一回流すだけでは終わらず、複数の問題で段階的に詰まった。

### 5-1. 問題その1: `--channels ignored`

Claude Code 自体は起動したが、次の表示が出て channels が無効になった。

- `--channels ignored (plugin:discord@claude-plugins-official)`
- `Channels are not currently available`

調査した結果、原因は 2 つあった。

1. 起動シェルに API-billing 用の `ANTHROPIC_*` 環境変数があり、Claude が `glm-5 · API Usage Billing` モードで起動していた
2. `claude.ai` OAuth が失効していた

失効日時:

- 失効していた `claude.ai` OAuth 期限: `2026-03-19 09:39:41 JST`

対応:

- `scripts/Login-ClaudeAiForChannels.ps1` を追加し、`claude auth login --claudeai` を clean な環境で起動できるようにした
- `scripts/Start-ClaudeDiscord.ps1` を修正し、channels 起動前に `ANTHROPIC_*` API-billing overrides を外すようにした
- 同スクリプトで `claude.ai` OAuth の期限を事前検査するようにした

再ログイン後の有効期限:

- 更新後の `claude.ai` OAuth 期限: `2026-03-20 22:17:47 JST`

この対応により、Claude Code 側では `Listening for channel messages from: plugin:discord@claude-plugins-official` が表示される状態まで到達した。

### 5-2. 問題その2: bot が online にならない

channels は有効になったように見えたが、Discord bot 自体が online にならず、ユーザーから「Bot起動してないけど！」というフィードバックがあった。

ここで Claude process tree と debug log を調べたところ、Discord plugin の MCP サーバー起動時に次のエラーが出ていた。

- `'bun' is not recognized as an internal or external command`

つまり、plugin の `.mcp.json` は `command: "bun"` を呼んでいるが、Claude から見える PATH 上で `bun` が解決できていなかった。

対応:

1. `C:\Users\Aslan\.local\bin\bun.cmd` を追加
   - 実体の `C:\Users\Aslan\.bun\bin\bun.exe` を呼び出す wrapper
2. plugin の `.mcp.json` を修正
   - `command: "bun"` から `command: "C:\\Users\\Aslan\\.local\\bin\\bun.cmd"` へ変更
3. 同じ修正を cache 側と marketplace 側の両方へ適用

この修正後、Claude process tree は次の形に変わった。

- `claude.exe`
  - `cmd.exe`
    - `bun.exe`

これは、前回存在しなかった Discord plugin サーバープロセスが、今回初めて実際に起動したことを意味する。

### 5-3. 問題その3: token を置いても `DISCORD_BOT_TOKEN required` と出る

`bun` 問題を解消したあとも、plugin を直実行すると次のエラーが出た。

- `discord channel: DISCORD_BOT_TOKEN required`

しかし実際には `C:\Users\Aslan\.claude\channels\discord\.env` に token は存在していた。

調査した結果、問題は 2 段あった。

#### (a) `.env` が BOM 付きで書かれていた

PowerShell の通常書き込みでは `.env` の先頭に BOM が付き、plugin の単純な正規表現パーサが `DISCORD_BOT_TOKEN=...` を読めなかった。

対応:

- `scripts/Set-DiscordBotToken.ps1` を修正し、`.env` を BOM なし ASCII で書くように変更

#### (b) plugin 側の `.env` 読み込みが弱かった

plugin の `server.ts` は、

- CRLF の `\r`
- 空文字の継承環境変数

に弱く、Windows では token を取りこぼす可能性があった。

対応:

- plugin の `server.ts` を修正
  - 行末の `\r` を除去してからパース
  - 継承環境変数が `''` の場合も `.env` で上書き
  - `DISCORD_BOT_TOKEN?.trim()` で token を取得

この修正後、plugin サーバーの直実行は `DISCORD_BOT_TOKEN required` を出さず、一定時間起動し続けるようになった。

## 6. 最終的に確認できたこと

最終的には、real Discord pairing と real message exchange まで確認できた。

確認ログの要点:

- `14:34`
  - Discord bot が pairing を要求
  - Claude Code 側で `/discord:access pair <pairing-code>` を実行
- pairing 後
  - Discord bot が `Paired! Say hi to Claude.` と返答
- `14:36`
  - Discord 側から `こんにちは` を送信
  - bot が次の内容で正常応答
    - `こんにちは、maki_maki_aiさん！ペアリング承認されました。何かお手伝いできることはありますか？`

この時点で確認できた成功事項は次の通り。

1. Claude Code 側 channels セッションが成立している
2. Discord plugin サーバーが実際に Windows 上で起動している
3. bot token が正しく読まれている
4. pairing が成功している
5. Discord -> Claude の inbound message が届いている
6. Claude -> Discord の outbound reply が返っている

## 7. 変更・追加したファイル

ワークスペース内:

- `D:\Prj\remote-cc\README.md`
- `D:\Prj\remote-cc\SETUP_REPORT.md`
- `D:\Prj\remote-cc\scripts\Get-DiscordChannelStatus.ps1`
- `D:\Prj\remote-cc\scripts\Set-DiscordBotToken.ps1`
- `D:\Prj\remote-cc\scripts\Import-DiscordBotTokenFromProjectEnv.ps1`
- `D:\Prj\remote-cc\scripts\Start-ClaudeDiscord.ps1`
- `D:\Prj\remote-cc\scripts\Login-ClaudeAiForChannels.ps1`
- `D:\Prj\remote-cc\scripts\Fix-DiscordPluginWindows.ps1`

ワークスペース外で手を入れた箇所:

- `C:\Users\Aslan\.local\bin\bun.cmd`
- `C:\Users\Aslan\.claude\plugins\cache\claude-plugins-official\discord\0.0.1\.mcp.json`
- `C:\Users\Aslan\.claude\plugins\marketplaces\claude-plugins-official\external_plugins\discord\.mcp.json`
- `C:\Users\Aslan\.claude\plugins\cache\claude-plugins-official\discord\0.0.1\server.ts`
- `C:\Users\Aslan\.claude\plugins\marketplaces\claude-plugins-official\external_plugins\discord\server.ts`

## 8. 運用上の注意

日常運用では、基本的に次のスクリプトだけ覚えておけば良い。

- 起動:

```powershell
.\scripts\Start-ClaudeDiscord.ps1
```

- 状態確認:

```powershell
.\scripts\Get-DiscordChannelStatus.ps1
```

- `.env` から token 再取り込み:

```powershell
.\scripts\Import-DiscordBotTokenFromProjectEnv.ps1
```

- channels 用再ログイン:

```powershell
.\scripts\Login-ClaudeAiForChannels.ps1
```

- plugin update 後の Windows 修正再適用:

```powershell
.\scripts\Fix-DiscordPluginWindows.ps1
```

## 9. 最終評価

今回のセットアップは、単なる「起動確認」ではなく、以下まで完了した。

- Windows 固有の起動問題の切り分け
- Claude Code 側の auth / provider 条件整理
- Bun 解決問題の修正
- token 読み込み問題の修正
- real Discord pairing 成功
- real message exchange 成功

結論として、この環境の Claude Code Discord channel セットアップは成功しており、実運用可能な状態に到達した。

## 10. このチャットの生ログ保存場所

今回のメインチャット本体の raw log は、Codex の session JSONL として次に保存されている。

- `C:\Users\Aslan\.codex\sessions\2026\03\20\rollout-2026-03-20T13-45-17-019d098f-e045-7b93-a23c-c3890c8fec30.jsonl`

このスレッドの thread ID は次の通り。

- `019d098f-e045-7b93-a23c-c3890c8fec30`

今回の作業で使った subagent の raw log も、同じく JSONL で保存されている。

- `C:\Users\Aslan\.codex\sessions\2026\03\20\rollout-2026-03-20T13-49-24-019d0993-a760-7c32-9aca-841ced1d027e.jsonl`
- `C:\Users\Aslan\.codex\sessions\2026\03\20\rollout-2026-03-20T13-49-31-019d0993-c03b-7ad3-9d16-ebc1457f4053.jsonl`
- `C:\Users\Aslan\.codex\sessions\2026\03\20\rollout-2026-03-20T13-50-02-019d0994-3b65-7b62-96b4-cad5bdb85032.jsonl`
- `C:\Users\Aslan\.codex\sessions\2026\03\20\rollout-2026-03-20T13-50-07-019d0994-4f9b-7501-96d1-df11fd3a8e06.jsonl`
- `C:\Users\Aslan\.codex\sessions\2026\03\20\rollout-2026-03-20T13-58-21-019d099b-d990-72f1-b8ed-60349a4274c1.jsonl`
- `C:\Users\Aslan\.codex\sessions\2026\03\20\rollout-2026-03-20T13-58-27-019d099b-eda2-75f1-a703-1384878c3ea6.jsonl`

補助的に、session 一覧の索引は次にある。

- `C:\Users\Aslan\.codex\session_index.jsonl`

また、Codex 全体のログ DB は次に存在するが、今回の「このチャットの生ログ」を直接見る用途では、まず上記の session JSONL を見るのが分かりやすい。

- `C:\Users\Aslan\.codex\logs_1.sqlite`
