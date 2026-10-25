# agent-rules: 科研代码与写作全局规则For Codex/Claude Code

主要解决问题：大模型的“防御性编程”&“防御性写作”

``` 
- 防御性编程：到处加 try/catch、静默兜底、对自己写死的常数做检查。规则要求出错直接报错，不吞错误，不用默认值掩盖问题。
- 防御性写作：论文里堆 may、could，写 "cannot establish" 这类提前辩解的句子。规则要求去掉多余的辩解，保留近似条件、适用范围、单器件等必要的限定。
```

同时规定了科研代码脚本的默认风格：写成平铺的脚本、不导出文件只弹图窗、变量名对应公式符号、按数据性质选色表、注释用英文、脚本默认不保存数据、运行时间超过 5 分钟先问、MATLAB 脚本开头加 `clear; close all; clc;`等等，覆盖 Python、MATLAB、Mathematica三种语言。

## 文件内容

| 文件 | 内容 |
|---|---|
| [research-coding.md](research-coding.md) | 只含"科研代码规范"一节，约 120 行，**推荐** |
| [AGENTS.full.md](AGENTS.full.md) | 作者自己完整的 `~/.codex/AGENTS.md`，含个人的工作流设定，仅供参考 |

## 使用方法

优先采用追加方式使用文档；不要覆盖AGENTS.md或者CLAUDE.md，否则会破坏你自己已有的规则。

- **Codex**：把 `research-coding.md` 的内容追加到 `~/.codex/AGENTS.md` 末尾。
- **Claude Code**：复制到 `~/.claude/rules/research-coding.md`。

## 许可

[MIT](LICENSE)
