# data — IT連携マップの索引データ

**English summary.** An index of the Japanese business systems published on [RenkeiMap](https://renkeimap.jp/): which data routes each system has (API, CSV, screen, MCP), how its official API is authenticated and who issues the key, where the vendor publishes its API spec and its status page. Every row has the date we checked it, a source URL, and the RenkeiMap page with the details. Licensed under CC BY 4.0 — credit "IT連携マップ" with a link to https://renkeimap.jp/.

---

このフォルダは、[IT連携マップ](https://renkeimap.jp/) が公開している業務システムの **索引** です。どの行も、確かめた日・出典の URL・詳しい内容がある renkeimap.jp の URL を持っています。

ここに置くのは「どこに何があるか」までです。説明・原文・細かい条件は、各行の `url` か、[MCP サーバー](https://renkeimap.jp/mcp) で引いてください。

## ファイル

| ファイル | 中身 |
|---|---|
| `systems.json` | 公開している系統の一覧と、方式（API・CSV の取り込み／書き出し・画面・MCP・書類）ごとの有無 |
| `auth.json` | 公式 API の認証: 方式・鍵や許可を誰が発行するか・鍵の置き場所・有効期限が書かれているか・IP 制限 |
| `official-specs.json` | 提供元が公開している API の仕様と、公式 MCP サーバーの接続先 |
| `status-pages.json` | 提供元が稼働状況や障害を告知している場所 |

どのファイルも、正本の台帳から生成しています。手では書いていません。

## 欄の読み方

| 欄 | 意味 |
|---|---|
| `slug` | renkeimap.jp での識別子。`url` は `https://renkeimap.jp/system/<slug>` |
| `methods[].method` | `api`・`csv_import`・`csv_export`・`screen`・`mcp`・`document` |
| `methods[].read` / `write` | その方式で読める／書けると確かめた操作があるか。`false` は「確かめられていない」で、「できない」ではない |
| `methods[].grade` | 確認等級（下の表）。その方式で確かめた主張のうち、いちばん高い等級 |
| `checked_on` | 確かめた日 |
| `source_url` | 根拠にした公開のページ |
| `basis` | `vendor` は提供元の文書、`measured` は編集部が公開のページを見て確かめたもの |
| `family` | 認証の型: `api_key`（画面で鍵を発行）・`oauth2`（利用者がブラウザで許可）・`vendor`（提供元への申請や審査が要る）。`null` は確かめられていない |
| `who_issues` | 鍵や許可を発行する人: `user` 利用者・`admin` 管理者・`vendor` 提供元。`null` は確かめられていない |
| `expiry_stated` | 鍵や許可の有効期限が提供元の文書に書かれているか。期限そのものは `detail_url` で |
| `detail_url` | 鍵や許可の発行の手順（renkeimap.jp） |

### 確認等級

| 等級 | 名 | 条件 |
|---|---|---|
| 3 | 単一の間接情報 | 第三者の情報が 1 本（iPaaS の実装・販売店・記事） |
| 4 | 複数一致／一次の記述 | 種類の異なる出所が 2 本以上一致、または提供元自身の説明 |
| 5 | 一次仕様に明記 | 提供元の仕様書・API リファレンス・公的な様式に書いてある |
| 6 | 実行して確認 | 実際に動かして確かめた |

このデータには、確かめられた主張（等級 3 以上）だけを載せています。見つからなかったことは載せていません。

## 載せていないもの

- 公開していない系統（名前も載せていません）
- 提供元の文書の文そのもの（引用）と、編集部の説明文
- 利用者のデータ、鍵や許可の値

## 鮮度

仕様は変わります。`checked_on` より後に変わっていることがあります。気づいた点は https://renkeimap.jp/request へ。

## ライセンス

[CC BY 4.0](LICENSE)。使うときは「IT連携マップ」と https://renkeimap.jp/ へのリンクを表示してください。
