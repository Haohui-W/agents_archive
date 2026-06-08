---
name: run-cli-in-tmux
description: Run interactive, privileged, or long-running command-line tasks in the shared agent-work tmux session and reliably collect their output. Use for sudo password prompts, y/n confirmations, installers, development servers, watchers, migrations, lengthy builds or tests, and commands that must survive beyond a normal shell call. Do not use for short read-only or non-interactive commands that can run directly.
---

# Run CLI in tmux

Use the fixed `agent-work` tmux session for commands that need interaction or may run for a long time.

Prepare the target when needed:

```bash
tmux has-session -t agent-work 2>/dev/null || tmux new-session -d -s agent-work
```

## Choose Direct Shell or tmux

Run short, non-interactive commands directly, including `rg`, `ls`, `cat`, `which`, `git log`, and status checks.

Use tmux for:

- Password, confirmation, menu, or other terminal interaction.
- Long builds, tests, migrations, downloads, servers, and watchers.
- Commands whose output must be polled over time.
- Pi or another terminal agent running as a subprocess.

## Submit a Command

Append a unique completion marker to every finite command:

```bash
tmux send-keys -t agent-work \
  'long-command; rc=$?; printf "\n===DONE_task_name=== status=%s\n" "$rc"' \
  Enter
```

Use `&&` only when later commands must not run after failure. Preserve the final status when the result matters.

Avoid submitting another command to the same pane until the current command finishes or is explicitly interrupted. Do not type into a pane when the user may currently be interacting with it.

## Poll and Capture Output

Wait briefly, then capture recent history:

```bash
sleep 5
tmux capture-pane -t agent-work -p -S -60
```

Adjust the delay and history to the task:

- Use 3-8 seconds for ordinary commands.
- Use `-S -10` for short output.
- Use `-S -60` or more for builds and verbose failures.
- Filter captured output with `rg`, `tail`, or `head` when this preserves the relevant context.

Continue polling until the completion marker appears. For servers and watchers, verify the readiness message instead of waiting for completion.

Interrupt a stuck or no-longer-needed command with:

```bash
tmux send-keys -t agent-work C-c
```

Capture the pane again afterward to confirm termination.

## Run sudo Commands

Check non-interactive sudo first:

```bash
sudo -n true 2>&1
```

If sudo requires a password, submit the privileged sequence through tmux:

```bash
tmux send-keys -t agent-work \
  'sudo cmd1 && sudo cmd2; rc=$?; printf "\n===DONE_sudo_task=== status=%s\n" "$rc"' \
  Enter
```

Let the user enter the password in tmux. Never request, capture, store, repeat, or place a password in a command or prompt.

Chain related sudo commands when appropriate so one authentication window can cover the operation. Keep unrelated or risky commands separate so their effects remain reviewable.

## Verify the Result

After the marker appears:

1. Read the reported exit status and relevant output.
2. Run a direct status or verification command where possible.
3. Report important output to the user; do not assume they can see the tmux pane.
4. Leave persistent servers running only when the user requested them or the active task still needs them.

If tmux cannot create or access `agent-work`, state the concrete failure and use a direct non-interactive fallback only when it remains safe and satisfies the task.
