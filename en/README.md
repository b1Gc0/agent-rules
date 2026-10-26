# English Rules

Clause-by-clause English counterparts of the Chinese rules in the parent directory. Replies still default to Simplified Chinese; change that line in `claude/rules/communication.md` (and the matching section in `codex/AGENTS.md`) if you want English replies.

| File | Purpose | Install location |
|---|---|---|
| [claude/CLAUDE.md](claude/CLAUDE.md) | General collaboration, scientific evidence, and physical analysis | `~/.claude/CLAUDE.md` |
| [claude/rules/research-coding.md](claude/rules/research-coding.md) | Script structure, comments, units, error handling, plotting, and verification | `~/.claude/rules/research-coding.md` |
| [claude/rules/writing-style.md](claude/rules/writing-style.md) | READMEs, papers, reports, and other reader-facing documents | `~/.claude/rules/writing-style.md` |
| [claude/rules/communication.md](claude/rules/communication.md) | Answers, progress updates, and completion reports | `~/.claude/rules/communication.md` |
| [codex/AGENTS.md](codex/AGENTS.md) | Complete Codex version: all of the above plus a planning-and-approval workflow | `~/.codex/AGENTS.md` |

Merge these into your existing files rather than overwriting them, and replace the first-person research background with your own. For Codex, the Research Code, Writing Style, and Communication sections can be appended on their own; the Planning and Approval section is a personal workflow that requires a plan and approval before file changes, debugging, or delegation. Start a new session after installing and check that the rules are loaded.

The research-code, writing, and communication rules exist in four copies (Claude and Codex, Chinese and English). Change all four together.
