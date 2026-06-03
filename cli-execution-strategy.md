---
name: cli-execution-strategy
description: 决定何时用 tmux 而非直接 Bash 执行命令，以及完整的 sudo 工作流
metadata:
  type: skill
---

# CLI 执行策略

## 何时用 tmux vs Bash

- **直接 Bash：** 简单的只读命令（grep、ls、cat、systemctl status、which、git log）
- **tmux：** 需要用户交互的操作（sudo 密码、y/n 提示）或长时间运行的任务

## 固定 tmux 会话

`claude-code:exec`。始终使用 `-t claude-code` —— 假定会话已存在，无需探测。

## 完整 sudo 工作流

1. 先检查免密 sudo：`sudo -n true 2>&1`
2. 若需要密码，发送命令链到 tmux：`tmux send-keys -t claude-code 'sudo cmd1 && sudo cmd2 && echo "===DONE==="' Enter`
3. 等待后抓取输出：`sleep 5 && tmux capture-pane -t claude-code -p -S -30 | grep -A 50 'cmd1'`
4. 始终在末尾加上明显标记（`===DONE===`）

## 已验证的模式

- 用 `&&` 串联多条 sudo 命令，只需输入一次密码
- 根据命令复杂度使用 `sleep 3-8`
- 用 `grep -A N` 或 `tail -N` 提取抓取输出的相关部分
- 简单命令用 `-S -10`，复杂输出用 `-S -60` 或更大值配合 `head`/`grep` 过滤
