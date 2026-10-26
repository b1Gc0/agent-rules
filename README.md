# agent-rules：科研代码与写作全局规则 For Codex/Claude Code

主要解决问题：大模型的“防御性编程”&“防御性写作”

```
- 防御性编程：到处加 try/catch、静默兜底、对自己写死的常数做检查。规则要求出错直接报错，不吞错误，不用默认值掩盖问题。
- 防御性写作：论文里堆 may、could，写 "cannot establish" 这类提前辩解的句子。规则要求去掉多余的辩解，保留近似条件、适用范围、单器件等必要的限定。
```

同时规定了科研代码脚本的默认风格：写成平铺的脚本、不导出文件只弹图窗、变量名对应公式符号、按数据性质选色表、注释用英文、脚本默认不保存数据、预计运行时间超过 5 分钟时先询问用户、MATLAB 脚本开头加 `clear; close all; clc;` 等等，覆盖 Python、MATLAB、Mathematica 三种语言。

另有一部分规定与用户的沟通方式，以及科研证据和物理分析的原则。

## 文件内容

| 文件 | 内容 | 安装位置 |
|---|---|---|
| [claude/CLAUDE.md](claude/CLAUDE.md) | 通用协作、科研证据与物理分析 | `~/.claude/CLAUDE.md` |
| [claude/rules/research-coding.md](claude/rules/research-coding.md) | 脚本结构、注释、单位、错误处理、绘图与运行验证 | `~/.claude/rules/research-coding.md` |
| [claude/rules/writing-style.md](claude/rules/writing-style.md) | README、论文、报告等交付文档 | `~/.claude/rules/writing-style.md` |
| [claude/rules/communication.md](claude/rules/communication.md) | 问答、进度与完成汇报 | `~/.claude/rules/communication.md` |
| [codex/AGENTS.md](codex/AGENTS.md) | Codex 完整版：上面全部内容，加计划审批流程 | `~/.codex/AGENTS.md` |

[en/](en/) 下是逐条对应的英文版，回复仍默认用简体中文。

## 使用方法

不要直接覆盖已有的 `CLAUDE.md` 或 `AGENTS.md`，否则会破坏你自己已有的规则。

- **Claude Code**：把 `claude/rules/` 下需要的文件复制到 `~/.claude/rules/`；[claude/CLAUDE.md](claude/CLAUDE.md) 中需要的条目追加到 `~/.claude/CLAUDE.md`。
- **Codex**：把 [codex/AGENTS.md](codex/AGENTS.md) 中的“科研代码”“写作风格”“与用户沟通”三节追加到 `~/.codex/AGENTS.md`（设置了 `CODEX_HOME` 时在该目录下）。“计划与审批”一节是个人工作流设定：修改文件、调试、委派前都要先给计划、等批准，按需采用。

修改后新建会话，再检查规则是否加载。

## 维护

科研代码、写作、沟通三部分共有四份副本：`claude/rules/` 下的三个文件、`codex/AGENTS.md` 中对应的三节，以及 `en/` 下的英文对应文件；每次修改时最好同时修改四份文件，否则容易出现规则冲突。

Codex 中这三节只调整了标题层级，正文与 Claude 的文件逐句相同。

Claude 的 AskUserQuestion 澄清机制和 Codex 的计划审批流程是各自独有的，不需要同步。

## 许可

[MIT](LICENSE)
