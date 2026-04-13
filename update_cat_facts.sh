#!/usr/bin/env bash
# update_cat_facts.sh
# Invokes a Claude Code subagent to generate fake cat facts, then updates
# ~/.claude/settings.json spinnerMessages so the CLI spinner shows them.

set -euo pipefail

SETTINGS="$HOME/.claude/settings.json"
LOG="$HOME/.claude/cat_facts_cron.log"

echo "[$(date)] Running fake cat facts update..." | tee -a "$LOG"

if [[ -f "$SETTINGS" ]]; then
    cp "$SETTINGS" "${SETTINGS}.bak"
    echo "[$(date)] Backed up $SETTINGS to ${SETTINGS}.bak" | tee -a "$LOG"
else
    echo "{}" > "$SETTINGS"
fi

FACTS_JSON=$(claude -p "Generate exactly 15 fake cat facts that are obviously untrue but funny and specific. For example, such untrue facts could be about their true role in society, or they could be about cat biology. Good examples: 'Cats invented the accordion in 1842', 'A cat purr frequency can unlock most deadbolt locks', 'Cats were briefly banned in Switzerland from 1987 to 1989 for stock market manipulation'. Bad: anything plausible or vague. Output ONLY a raw JSON array of 15 strings. No markdown fences, no prose, no explanation — just the JSON array.")

# Strip any accidental code fences just in case
FACTS_JSON=$(echo "$FACTS_JSON" | sed -e 's/^```json//' -e 's/^```//' -e 's/```$//' | tr -d '\r')

if ! echo "$FACTS_JSON" | jq -e 'type == "array" and length == 15' >/dev/null 2>&1; then
    echo "[$(date)] ERROR: subagent did not return a valid 15-element JSON array:" | tee -a "$LOG"
    echo "$FACTS_JSON" | tee -a "$LOG"
    exit 1
fi

TMP=$(mktemp)
jq --argjson facts "$FACTS_JSON" '.spinnerVerbs = {mode: "replace", verbs: $facts}' "$SETTINGS" > "$TMP"
mv "$TMP" "$SETTINGS"

echo "[$(date)] Done. Wrote 15 facts to $SETTINGS." | tee -a "$LOG"
