# Portable Agent Skills

可供不同命令行 Agent 共用的指令与技能仓库。核心内容不依赖具体宿主：

- `AGENTS.md`：精简的通用规则。
- `skills/`：基于 `SKILL.md` 的独立技能。
- `scripts/install.sh`：将规则与技能链接到任意 Agent 配置目录。
- `CLAUDE.md`：Claude Code 所需的薄入口，仅引用通用规则。

## 安装

通用安装方式：

```bash
scripts/install.sh TARGET_DIR [CONTEXT_FILENAME]
```

例如：

```bash
scripts/install.sh "$HOME/.some-agent" AGENTS.md
```

仓库也提供常见宿主的轻量包装脚本：

```bash
scripts/sync-to-claude.sh
scripts/sync-to-codex.sh
scripts/sync-to-opencode.sh
scripts/sync-to-agents.sh
```

包装脚本使用各宿主的标准全局目录。其他宿主或自定义目录直接调用 `scripts/install.sh`。

tmux 类技能统一使用固定会话 `agent-work`。
