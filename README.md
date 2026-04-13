# claude-cat-facts

Replaces the Claude Code spinner verbs with absurd, AI-generated fake cat facts.

A small shell script that invokes `claude -p` as a one-shot subagent to generate 15 obviously-untrue cat facts, then patches `~/.claude/settings.json` so the CLI spinner cycles through them instead of the defaults.

## What it does

1. Backs up `~/.claude/settings.json` to `settings.json.bak`.
2. Asks Claude to produce a JSON array of 15 fake cat facts (e.g. *"Cats invented the accordion in 1842"*).
3. Validates the output with `jq` (must be a 15-element array).
4. Writes them into `spinnerVerbs` as `{mode: "replace", verbs: [...]}`.
5. Logs every run to `~/.claude/cat_facts_cron.log`.

## Requirements

- `claude` (Claude Code CLI) on your `PATH`
- `jq`
- `bash`

## Usage

```sh
./update_cat_facts.sh
```

Start a new Claude Code session afterward to see the new spinner messages.

## Running on a schedule

Add to your crontab to refresh the facts daily at 9am:

```cron
0 9 * * * /path/to/claude-cat-facts/update_cat_facts.sh
```

## Restoring defaults

```sh
cp ~/.claude/settings.json.bak ~/.claude/settings.json
```

## License

MIT — see [LICENSE](LICENSE).
