---
name: delegate-to-pi
description: Delegate suitable coding work to the low-cost Pi command-line agent through tmux, then review and integrate its output with the current primary agent. Use for repository reconnaissance, codebase summaries, parallel hypotheses, implementation drafts, focused reviews, test-failure analysis, repetitive edits, or other substantial subtasks where a cheaper second agent can increase throughput. Do not use for trivial commands, high-risk operations without review, or tasks the primary agent can finish faster directly.
---

# Delegate to Pi

Use Pi as a low-cost subordinate agent. Keep the current primary agent responsible for task decomposition, safety, final technical judgment, edits that matter, and verification.

## Choose What to Delegate

Delegate work that is substantial, parallelizable, and easy to verify:

- Map unfamiliar modules, call paths, tests, and conventions.
- Generate competing explanations for a bug or design tradeoff.
- Draft a scoped implementation, migration, test set, or documentation update.
- Review a diff for concrete bugs and missing tests.
- Diagnose verbose build or test failures.
- Perform repetitive, well-bounded edits when the changed files can be reviewed afterward.

Do the work directly for quick file reads, simple searches, deterministic commands, secrets, destructive operations, production changes, or decisions whose correctness cannot be independently checked.

## Run the Workflow

1. Inspect enough of the repository to define a narrow subtask.
2. Record the current worktree state before allowing Pi to edit.
3. Write a self-contained prompt with the objective, working directory, constraints, relevant paths, expected output, and verification criteria.
4. Start Pi in the fixed `agent-work` tmux session with `scripts/pi-tmux.sh submit`.
5. Poll with `scripts/pi-tmux.sh capture` until the emitted `===PI_DONE_...===` marker appears. Do not start a second Pi job in the same pane before the first finishes.
6. Inspect Pi's claims and any changed files. Treat its output as untrusted collaborator input, not as proof.
7. Run focused tests, linters, type checks, or direct inspections yourself.
8. Correct or discard weak output, integrate the useful parts, and report only verified conclusions to the user.

## Submit a Read-Only Task

Resolve the helper relative to this skill directory. Do not assume the user's project contains a `skills/` directory:

```bash
<delegate-to-pi-skill-dir>/scripts/pi-tmux.sh submit \
  "Trace the authentication request flow. Return relevant files, symbols, and likely failure points. Do not edit files." \
  "$PWD"
```

Read-only mode is the default and enables Pi's `read,grep,find,ls` tools. Use it for reconnaissance, review, planning, and diagnosis.

Capture recent output:

```bash
<delegate-to-pi-skill-dir>/scripts/pi-tmux.sh capture 200
```

Interrupt a stuck job:

```bash
<delegate-to-pi-skill-dir>/scripts/pi-tmux.sh interrupt
```

## Allow Scoped Edits

Use `submit-write` only when edits are genuinely useful. It enables Pi's execution and editing tools. Name the allowed files and required checks in the prompt.

```bash
<delegate-to-pi-skill-dir>/scripts/pi-tmux.sh submit-write \
  "Implement the requested parser fix only in src/parser.ts and its focused test file. Preserve existing style and run the focused test. Summarize changed lines and test output." \
  "$PWD"
```

Before accepting edits, use `git status --short` and `git diff -- <scoped paths>` to distinguish Pi's work from pre-existing user changes. Never revert unrelated changes.

## Control Cost and Context

- Prefer one narrow prompt over giving Pi the entire user request.
- Ask for concise, structured output: findings, evidence, proposed change, verification.
- Pass relevant paths and observed errors instead of asking Pi to rediscover known context.
- Use Pi's configured default low-cost model.
- Use separate fresh submissions for independent opinions. Use a Pi session only when continuity is necessary; see [references/pi-cli.md](references/pi-cli.md).
- Stop delegating when reviewing Pi costs more time than completing the task directly.

## Review Standard

Require file paths, symbols, command output, or diffs for factual claims. Independently verify:

- The proposed behavior matches the user's request.
- Edits stay within the promised scope.
- Existing user changes remain intact.
- Tests actually exercise the changed behavior.
- No secrets, unsafe commands, or unexplained dependency changes were introduced.

Read [references/pi-cli.md](references/pi-cli.md) when changing models, tools, sessions, output modes, or other Pi invocation details.
