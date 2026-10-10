#!/bin/sh
# Set up IT連携マップ (RenkeiMap) in the agent CLIs installed on this machine:
#   1. the read-only MCP server  https://renkeimap.jp/mcp
#   2. the skill (SKILL.md: when to use which tool, how to cite the sources)
# Default: print what would run and change nothing.  --apply: run it.  --mcp-only: leave the skill out.
# Safe to re-run: what is already there is skipped (the MCP server by its URL, the skill by its name).
set -u

NAME="renkeimap"
URL="https://renkeimap.jp/mcp"
APPLY=0
SKILL=1
for a in "$@"; do
  case "${a}" in
    --apply) APPLY=1 ;;
    --mcp-only) SKILL=0 ;;
    *) echo "Unknown option: ${a} (use --apply, --mcp-only)"; exit 2 ;;
  esac
done

# The skill folder is the parent of this script's folder (skills/renkeimap). It is there when the
# repository was cloned; if only this script was downloaded, the skill is left out and we say so.
SRC="$(cd "$(dirname "$0")/.." && pwd)"
if [ "${SKILL}" -eq 1 ] && [ ! -f "${SRC}/SKILL.md" ]; then
  echo "SKILL.md not found next to this script; setting up the MCP server only."
  echo "For the skill, clone https://github.com/MaxOurC/renkeimap and run this script from there."
  SKILL=0
fi

CLAUDE_SKILLS="${CLAUDE_CONFIG_DIR:-${HOME}/.claude}/skills"
# agy (the Antigravity CLI) loads global skills from ~/.gemini/config/skills, not ~/.gemini/antigravity/skills (checked 2026-10-10).
AGY_SKILLS="${HOME}/.gemini/config/skills"
CODEX_SKILLS="${CODEX_HOME:-${HOME}/.codex}/skills"

has() { command -v "$1" >/dev/null 2>&1; }
# Every CLI prints the server URL in its list; the URL is the identity (any name pointing at it counts,
# including a server that came with the plugin or extension from this repository).
# The lists are read from / : inside a clone of this repository, Claude Code also lists the repository's
# own .mcp.json, which applies only in that folder. Gemini CLI prints its list on stderr, so read both streams.
listing() { (cd / && "$@" 2>&1); }
connected() { listing "$1" mcp list | grep -qF "${URL}"; }
# The skill counts as there if it is in the client's skill folder or came with our plugin/extension.
skill_there() {
  case "$1" in
    claude) [ -f "${CLAUDE_SKILLS}/${NAME}/SKILL.md" ] || listing claude plugin list | grep -qw "${NAME}" ;;
    gemini) listing gemini skills list | grep -qw "${NAME}" || listing gemini extensions list | grep -qw "${NAME}" ;;
    agy)    [ -f "${AGY_SKILLS}/${NAME}/SKILL.md" ] || listing agy plugin list | grep -qw "${NAME}" ;;
    codex)  [ -f "${CODEX_SKILLS}/${NAME}/SKILL.md" ] ;;
  esac
}

failed=""
# One client failing must not stop the others; the failures are listed at the end.
run() {
  if [ "${APPLY}" -eq 0 ]; then echo "would run: $*"; return 0; fi
  echo "+ $*"
  "$@" || { failed="${failed} $1"; return 1; }
}
# Copy the skill folder into a client's skill folder.
copy_skill() { run mkdir -p "$1" && run cp -R "${SRC}" "$1/${NAME}"; }

found=0
for c in claude gemini agy codex; do
  has "${c}" || continue
  found=1
  if connected "${c}"; then echo "${c}: MCP server already connected"; else
    case "${c}" in
      claude) run claude mcp add --transport http --scope user "${NAME}" "${URL}" ;;
      gemini) run gemini mcp add --transport http --scope user "${NAME}" "${URL}" ;;
      agy)    run agy mcp add "${NAME}" "${URL}" ;;
      codex)  run codex mcp add "${NAME}" --url "${URL}" ;;
    esac
  fi
  [ "${SKILL}" -eq 1 ] || continue
  if skill_there "${c}"; then echo "${c}: skill already there"; continue; fi
  case "${c}" in
    claude) copy_skill "${CLAUDE_SKILLS}" ;;
    gemini) run gemini skills install "${SRC}" --scope user --consent ;;
    agy)    copy_skill "${AGY_SKILLS}" ;;
    codex)  copy_skill "${CODEX_SKILLS}" ;;
  esac
done

if [ "${found}" -eq 0 ]; then echo "No supported agent CLI found (claude, gemini, agy, codex)."; exit 1; fi
if [ "${APPLY}" -eq 0 ]; then echo "Nothing changed. Re-run with --apply to set it up, then start a new session."; exit 0; fi
if [ -n "${failed}" ]; then echo "Failed:${failed}. Run the command shown above by hand to see why."; exit 1; fi
echo "Done. Start a new session so the agent sees the renkeimap tools and skill."
