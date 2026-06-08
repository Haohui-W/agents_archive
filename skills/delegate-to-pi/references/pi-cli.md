# Pi CLI Reference

This reference records the Pi options relevant to delegation from any primary agent. Refresh it with `pi --help` if the installed CLI changes.

## Core Invocation

```text
pi [options] [@files...] [messages...]
```

- `--print`, `-p`: run non-interactively and exit.
- `--provider <name>`: select a provider.
- `--model <pattern>`: select a model or `provider/model`; supports an optional thinking suffix.
- `--thinking <level>`: use `off`, `minimal`, `low`, `medium`, `high`, or `xhigh`.
- `--no-session`: do not save the run.
- `--mode text|json|rpc`: choose output mode.
- `--append-system-prompt <text-or-file>`: append task-specific instructions.

## Tool Control

Pi's built-in tools are:

- `read`
- `bash`
- `edit`
- `write`
- `grep`
- `find`
- `ls`

Use `--tools <comma-separated-list>` as an allowlist. Prefer `read,grep,find,ls` for analysis. Enable `bash,edit,write` only for a bounded implementation task that the primary agent will inspect and verify.

Other controls:

- `--no-tools`: disable every tool.
- `--no-builtin-tools`: disable built-ins while retaining extension tools.
- `--exclude-tools <list>`: disable selected tools.
- `--no-context-files`: skip automatic repository instruction files.

Keep context-file loading enabled by default so Pi follows repository instructions.

## Sessions

The helper uses `--no-session` for isolated delegation. For a task that benefits from continuity, invoke Pi manually through tmux with:

- `--name <name>`: create a named session.
- `--continue`: continue the previous session.
- `--session <path-or-id>`: use a specific session.
- `--session-id <id>`: use an exact project session ID.
- `--fork <path-or-id>`: branch from an existing session.
- `--session-dir <dir>`: override session storage.

Avoid continuing a session across unrelated tasks because stale context can contaminate the answer.

## Prompt Template

Give Pi this information:

```text
Objective:
Working directory:
Relevant files or errors:
Allowed scope:
Do not:
Expected output:
Verification:
```

For reviews, request findings ordered by severity with file and line evidence. For implementation, state exact writable paths and require a concise diff summary plus test output.

## tmux Contract

Use the fixed `agent-work` tmux session. The helper creates it when it does not exist. Pi jobs are long-running operations, so run them inside tmux rather than direct Bash. End every submitted command with a unique, visible completion marker and capture enough pane history to include the prompt, result, and marker.
