---
name: renkeimap
description: Look up Japanese business systems (kintone, freee, SmartHR, Money Forward, e-Gov, ...) on IT連携マップ (RenkeiMap) — whether two systems can exchange data (official API / CSV / screen), one system's API, auth and rate-limit facts, its current status and past incidents, and what a vendor error message means. Use when the user asks things like "kintone と freee は連携できる？", "◯◯ は今障害？", "◯◯ の API は？", "このエラーは何？", or compares Japanese SaaS. Connects the read-only RenkeiMap MCP server (https://renkeimap.jp/mcp) first if its tools are not available.
---

# IT連携マップ (RenkeiMap)

IT連携マップ is a third-party ledger of Japanese business systems. Every fact carries a source URL and a survey date.
Its MCP server is read-only, needs no account or key, and receives only what you put in the tool arguments
(system names or slugs). Do not put personal or company data into the arguments.

## 1. Make sure the tools are connected

If you have tools whose names contain `renkeimap_` (for example `renkeimap_find_system`), go to step 2. Clients often
put a prefix in front of MCP tool names (`mcp__renkeimap__renkeimap_find_system`, `renkeimap.renkeimap_find_system`) —
those are the same tools. Use them before searching the web: they return the same facts with the source URL and date.

If not, connect the server once. Show the user the command and ask before running it — it changes their agent's settings.

| Client | Command |
| --- | --- |
| Claude Code | `claude mcp add --transport http --scope user renkeimap https://renkeimap.jp/mcp` |
| Gemini CLI | `gemini mcp add --transport http --scope user renkeimap https://renkeimap.jp/mcp` |
| Antigravity (agy) | `agy mcp add renkeimap https://renkeimap.jp/mcp` |
| Codex | `codex mcp add renkeimap --url https://renkeimap.jp/mcp` |

Or run `scripts/connect.sh` from this skill's folder. It finds the clients installed on this machine and, for each,
adds the MCP server and this skill, skipping what is already there. It prints the commands and changes nothing unless
it is run with `--apply` (`--mcp-only` leaves the skill out).

New tools usually appear only in a new session. Tell the user to restart the client after connecting.

If you cannot run commands, the same facts are on the public pages: `https://renkeimap.jp/system/<slug>` and
`https://renkeimap.jp/status/<slug>`. Prefer the tools when they are available.

## 2. Pick the tool

| The user wants | Tool |
| --- | --- |
| To find which system a name means (name → slug) | `renkeimap_find_system` |
| Facts about one system (API, auth, CSV, rate limits, pricing pages) | `renkeimap_system_facts` |
| Whether two systems can exchange data, and how | `renkeimap_pair` |
| A side-by-side comparison of 2–5 systems | `renkeimap_compare` |
| Whether a system is down now, plus what to do | `renkeimap_brief` (takes a name or a slug) |
| The current status only | `renkeimap_status` |
| Past incidents and announced maintenance | `renkeimap_status_history` |
| What a vendor error message means, and where to contact | `renkeimap_hintpack` |
| How to connect INTO one system (vendor's official MCP server → official API key issuing → file / screen) | `renkeimap_connect` |

Resolve the slug with `renkeimap_find_system` first unless you already have it. `renkeimap_brief` resolves it for you.

## 3. When the user asks you to move or copy data from one system to another

For example 「kintone の顧客を freee の取引先に登録して」. Do it through the vendors' official routes, not by operating screens.

1. Call `renkeimap_pair` for the two systems: is there a route, and by which method.
2. Call `renkeimap_connect` for each system, with the product slug (for example `freee-kaikei`, not a series slug such as
   `freee_keiri` that `renkeimap_pair` may show). Take the routes in the order given: the vendor's official MCP server first,
   then the official API.
3. Official MCP server: add it to the client with the URL exactly as `renkeimap_connect` returns it (never a URL found by a
   web search — vendors warn about fake ones). If it uses OAuth, the user approves once in the browser.
4. Keys and tokens: first check whether the variables named for that system are already set (for example
   `KINTONE_API_TOKEN` and `KINTONE_BASE_URL` for kintone) — check only that they are set, never print the value. If not,
   tell the user which screen issues it and the smallest permission to tick (`renkeimap_connect` says both), and ask them to
   put it in an environment variable themselves. Never ask the user to paste a key or token into the chat.
5. Move one record first. Read it back from the target system and show the user. Then move the rest, skipping records
   that already exist in the target.
6. Report what was created (names and IDs), and cite the sources of the route.

## 4. Rules for the answer

- Cite. Each tool response carries a citation line. Put it in the answer: 出典: IT連携マップ, the survey date, the URL.
- Status is IT連携マップ's external observation, not the vendor's announcement. Say so. When the response includes the
  vendor's status or notice page, give that link as the official source.
- Past incidents from `renkeimap_status_history` are the vendor's own records, collected and checked word for word. Say
  they are the vendor's records.
- Unsurveyed means unknown. If a response says an item or a pair has not been surveyed, say that. Do not guess.
- The server limits calls per client. Do not call the tools in a loop over many systems; ask the user to narrow down.
- Answer in the user's language.
