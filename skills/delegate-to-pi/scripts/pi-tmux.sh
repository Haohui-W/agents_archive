#!/usr/bin/env bash
set -euo pipefail

SESSION="agent-work"

ensure_session() {
  if ! tmux has-session -t "$SESSION" 2>/dev/null; then
    tmux new-session -d -s "$SESSION"
  fi
}

usage() {
  cat <<'EOF'
Usage:
  pi-tmux.sh submit PROMPT [WORKDIR]
  pi-tmux.sh submit-write PROMPT [WORKDIR]
  pi-tmux.sh capture [LINES]
  pi-tmux.sh interrupt
EOF
}

case "${1:-}" in
  submit|submit-write)
    if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
      usage >&2
      exit 2
    fi

    prompt=$2
    workdir=${3:-"$PWD"}
    if [ ! -d "$workdir" ]; then
      echo "Workdir does not exist: $workdir" >&2
      exit 2
    fi

    prompt_file=$(mktemp "${TMPDIR:-/tmp}/pi-delegate.XXXXXX")
    chmod 600 "$prompt_file"
    printf '%s' "$prompt" >"$prompt_file"

    marker="===PI_DONE_$(date +%s)_$$==="
    if [ "$1" = "submit-write" ]; then
      tools="read,bash,edit,write,grep,find,ls"
    else
      tools="read,grep,find,ls"
    fi
    pi_args=(pi --no-session --print --tools "$tools")

    printf -v quoted_workdir '%q' "$workdir"
    printf -v quoted_prompt_file '%q' "$prompt_file"
    printf -v quoted_marker '%q' "$marker"
    printf -v pi_command '%q ' "${pi_args[@]}"

    command="cd $quoted_workdir && ${pi_command}\"\$(cat $quoted_prompt_file)\"; status=\$?; rm -f $quoted_prompt_file; printf '\\n%s status=%s\\n' $quoted_marker \"\$status\""
    ensure_session
    if ! tmux send-keys -t "$SESSION" "$command" Enter; then
      rm -f "$prompt_file"
      exit 1
    fi
    echo "Submitted to tmux session '$SESSION'. Completion marker: $marker"
    ;;

  capture)
    lines=${2:-200}
    if ! [[ "$lines" =~ ^[1-9][0-9]*$ ]]; then
      echo "LINES must be a positive integer." >&2
      exit 2
    fi
    ensure_session
    tmux capture-pane -t "$SESSION" -p -S "-$lines"
    ;;

  interrupt)
    ensure_session
    tmux send-keys -t "$SESSION" C-c
    ;;

  *)
    usage >&2
    exit 2
    ;;
esac
