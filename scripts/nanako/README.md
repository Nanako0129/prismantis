# Screenshots for PRs (nanako's tooling, not upstream)

Renders before/after scenes of prismantis in a real Claude Code session, the way the repo's
live-check skill does, but logged in so the model can reply and call tools.

One-time: log a separate config in, so your own settings, plugins and status line stay out.

```bash
CLAUDE_CONFIG_DIR=$HOME/.claude-shots claude    # then /login, then /exit
```

The account syncs your plugins and status line into that config; shoot.sh switches every
plugin but the one under test off and blanks the status line on each run.

- `shoot.sh <checkout> <name> <cols> <rows> '<options json>' '<steps json>' [claude args]`:
  one scene. Steps are `[seconds, keys]`; `SNAPS="3 4"` also renders the screen after those steps.
  Output goes to `$SHOTS_DIR` (default `~/.cache/prismantis-shots`), run in `$SHOT_CWD`.
- `batch.py [name ...]`: the scenes used for the 2026-11 PRs. It expects each branch exported to
  `$SHOTS_DIR/src/<branch>` (`git archive <branch> | tar -x -C …`) and crops each png with
  `crop.swift` (header and prompt cut off, trailing blank rows trimmed).
- Before publishing, read every image for paths, account names and usage figures.
