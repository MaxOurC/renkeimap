# IT連携マップの MCP サーバーに繋ぐ

接続先: `https://renkeimap.jp/mcp`（Streamable HTTP・読み取りだけ・アカウントも鍵も不要）

- サーバーが受け取るのは道具の引数（システム名や識別子）だけです。会話の本文やファイルを送る道具はありません
- 接続元ごとに 1 日 500 回まで呼べます。探す道具は 1 回に 10 件までを返します
- 公式 MCP Registry の名前: `jp.renkeimap/renkeimap-info`（宣言は [server.json](server.json)）

## 道具

| 名前 | 何を返すか |
| --- | --- |
| `renkeimap_find_system` | システムを名前で探す |
| `renkeimap_system_facts` | 1 システムの事実（API・認証・接続の方式・出典） |
| `renkeimap_pair` | 2 システムのあいだでデータを渡せるか、どの方法で |
| `renkeimap_compare` | 複数のシステムを横に並べて比べる |
| `renkeimap_status` | いまの稼働状況（IT連携マップの観測） |
| `renkeimap_brief` | 探す・稼働状況・対処をまとめて 1 回で |
| `renkeimap_status_history` | 提供元が公開している過去の障害と、告知されたメンテナンス |
| `renkeimap_hintpack` | 画面に出たエラー文の意味と、最初に確かめること |

## 繋ぎ方

### いちばん簡単: スクリプトで繋ぐ（macOS・Linux）

```bash
sh skills/renkeimap/scripts/connect.sh
```

この機械に入っている Claude Code・Antigravity・Gemini CLI・Codex を探し、それぞれに MCP サーバーと SKILL を入れます（すでに在る物は飛ばします）。何も変えずに実行するコマンドを表示するので、よければ `--apply` を付けてもう一度実行してください。MCP サーバーだけなら `--mcp-only` を付けます。入れた後は、エージェントを新しいセッションで開き直してください。

スクリプトは、このリポジトリを取得したフォルダから実行してください（SKILL はスクリプトの隣のフォルダから写します）。

### エージェントごとに

| エージェント | MCP だけ繋ぐ | 使い方の説明（SKILL）も一緒に入れる |
| --- | --- | --- |
| Claude Code | `claude mcp add --transport http --scope user renkeimap https://renkeimap.jp/mcp` | `/plugin marketplace add MaxOurC/renkeimap` → `/plugin install renkeimap@renkeimap` |
| Antigravity（agy） | `agy mcp add renkeimap https://renkeimap.jp/mcp` | このリポジトリを取得して `agy plugin install <取得したフォルダ>` |
| Gemini CLI | `gemini mcp add --transport http --scope user renkeimap https://renkeimap.jp/mcp` | `gemini extensions install https://github.com/MaxOurC/renkeimap` |
| Codex | `codex mcp add renkeimap --url https://renkeimap.jp/mcp` | `skills/renkeimap` を `~/.codex/skills/renkeimap` に置く |

GitHub CLI があれば、SKILL だけをエージェントごとに入れることもできます: `gh skill install MaxOurC/renkeimap renkeimap --agent claude-code --scope user`（`--agent` は `gemini-cli`・`antigravity`・`codex` も可）。MCP サーバーは、SKILL が最初に使われるときに利用者に聞いてから繋ぎます。

## このリポジトリの中身

| ファイル | 何のためか |
| --- | --- |
| `skills/renkeimap/SKILL.md` | エージェント向けの説明（Agent Skills の形式）。どの質問でどの道具を使い、出典をどう書くか |
| `skills/renkeimap/scripts/connect.sh` | 入っているエージェントを探して MCP サーバーと SKILL を入れる |
| `.claude-plugin/plugin.json` ＋ `.mcp.json` | Claude Code のプラグイン（入れると MCP も繋がる） |
| `.claude-plugin/marketplace.json` | Claude Code のマーケットプレイス（このリポジトリから入れるため） |
| `plugin.json` ＋ `mcp_config.json` | Antigravity のプラグイン |
| `gemini-extension.json` | Gemini CLI の拡張 |

## 確かめたこと（2026-10-10）

| エージェント | 版 | 結果 |
| --- | --- | --- |
| Claude Code | 2.1.251 | `plugin validate` 通過。このリポジトリをマーケットプレイスとして追加 → インストール → 有効になることを、別の設定ディレクトリで確かめた（公開後のリポジトリからも同じ）。プラグインの中身は SKILL 1・MCP サーバー 1 |
| Antigravity（agy） | 1.3.2 | `plugin validate` 通過（SKILL 1・MCP サーバー 1）。プラグインを入れて「kintone と freee会計 は連携できる？」と聞くと、`renkeimap_find_system` → `renkeimap_pair` を呼び、出典（調査日と URL）付きで答えた |
| Gemini CLI | 0.46.0 | `extensions validate` 通過。`gemini extensions install https://github.com/MaxOurC/renkeimap` で入れると MCP サーバーと SKILL が一覧に出た。答えまでは確かめていない（個人の Google アカウントではこの CLI からモデルを呼べなくなっている） |
| GitHub CLI（`gh skill`） | 2.92.0 | `--agent` に claude-code・antigravity・gemini-cli・codex を渡すと、それぞれの SKILL のフォルダに置かれた（connect.sh と同じ場所） |
| Codex | 0.162.1 | `codex mcp add` で設定ファイルに書かれることを確かめた。SKILL を読むかは確かめていない |
| connect.sh | — | 別の HOME で、表示だけ・`--apply`（MCP と SKILL）・2 回目（在る物は飛ばす）・`--mcp-only`・SKILL.md が隣に無いとき・知らない旗、を確かめた（Claude Code・Gemini CLI・Antigravity）。Gemini CLI は `skills list` に SKILL が出た。Claude Code と Antigravity は SKILL のフォルダに置かれるところまでで、新しいセッションで読み込まれるかは確かめていない |

## 注意

- エージェントが道具を呼ぶとき、初回は許可を求められることがあります（読み取りだけの道具です）
- 稼働状況は IT連携マップが外から見た観測で、提供元の公式発表ではありません
- 答えに出典の URL と確かめた日が付きます。引用するときは、それも一緒に書いてください
