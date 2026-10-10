---
name: renkeimap
description: Connect or move data between Japanese business systems (kintone, freee, SmartHR, Money Forward, e-Gov, ...) through the vendors' official routes, and look up their facts on IT連携マップ (RenkeiMap) — which route works between two systems, each system's official MCP server / API / auth, current status and past incidents, and what a vendor error means. Use when the user asks things like 「kintone の顧客を freee に登録して」, "kintone と freee は連携できる？", "◯◯ は今障害？", "このエラーは何？". Connects the read-only RenkeiMap MCP server (https://renkeimap.jp/mcp) first if its tools are not available.
---

# IT連携マップ (RenkeiMap)

A third-party ledger of Japanese business systems. Every fact carries a source URL and a survey date. The MCP server is
read-only, needs no account or key, and sees only the tool arguments (system names or slugs) — never put personal or
company data into them.

## 1. Tools available?

Tools whose names contain `renkeimap_` (any prefix, e.g. `mcp__renkeimap__renkeimap_plan`) are connected — go to step 2.
Only if they are missing: show the user the command for their client, ask, then tell them to restart the client.

| Client | Command |
| --- | --- |
| Claude Code | `claude mcp add --transport http --scope user renkeimap https://renkeimap.jp/mcp` |
| Codex | `codex mcp add renkeimap --url https://renkeimap.jp/mcp` |
| Antigravity (agy) | `agy mcp add renkeimap https://renkeimap.jp/mcp` |
| Gemini CLI | `gemini mcp add --transport http --scope user renkeimap https://renkeimap.jp/mcp` |

`scripts/connect.sh` in this skill's folder does the same for every client installed on the machine (it prints the
commands and changes nothing unless run with `--apply`).

## 2. Move or copy data from system A to system B

1. Call `renkeimap_plan` once: `from` and `to` as the user wrote them, and `agent` = your client
   (`claude-code`, `codex`, `antigravity` or `gemini-cli`). Do not call other renkeimap tools for this
   (the one exception is in step 3).
   If the answer has `ask: true`, show the user its `candidates` and ask which system they mean.
2. Connect each side with your client's lines in `clients`, exactly as returned (never a URL found by a web search).
   A side may have two lines for your client — a remote line and a local line. Each line's note says which mode it is
   for: use the remote line when you run interactively and the local line when you run with `-p` (non-interactive).
   When both sides use the same server, there is one set of lines (`also` names the other side): add it once.
   The sign-in steps for a remote line are in `clients_remote_steps`.
3. `human` lists, per route, the steps only the user can do — the best route first (`route.legend` says what the
   `api`／`csv`／`fill` values mean). Follow the first line that your client can use, and ask the user only for those
   steps (for example "approve once in the browser", "issue an API token with レコード閲覧 only"). Check that a
   variable is set with `[ -n "$NAME" ] && echo set` — never run `env`, `printenv` or `echo $NAME`, which print the
   value, and do not open your client's settings files (they can hold keys). Never ask for a key or token in the chat.
   If the line you take points to `renkeimap_connect`, call it once for that side with the short default (no `detail`).
   Do not ask for `detail:"full"`.
4. Follow every item of `write_rules` before and while writing, and report the way it says. Cite the `source` line.

## 3. Other questions — call only the tool asked for

| The user asks | Tool |
| --- | --- |
| Which system a name means | `renkeimap_find_system` |
| Whether two systems can exchange data, and by which method (a question, not a move) | `renkeimap_pair` |
| Facts about one system (API, auth, CSV, limits) | `renkeimap_system_facts` |
| Side-by-side comparison of 2–5 systems | `renkeimap_compare` |
| Is it down now, and what to do | `renkeimap_brief` (takes a name or a slug) |
| The current status only | `renkeimap_status` |
| Past incidents and announced maintenance | `renkeimap_status_history` |
| What a vendor error message means | `renkeimap_hintpack` |
| How to connect INTO one system, in full detail | `renkeimap_connect` with `detail: "full"` |

## 4. Rules for the answer

- Cite: 出典: IT連携マップ, the survey date, the URL (each tool response has the line).
- Status is RenkeiMap's outside observation, not the vendor's announcement; give the vendor's status page as the official source.
- Past incidents from `renkeimap_status_history` are the vendor's own records, collected word for word — say so.
- Unsurveyed means unknown — say so, do not guess.
- Calls are limited per client: no loops over many systems.
- Answer in the user's language.
