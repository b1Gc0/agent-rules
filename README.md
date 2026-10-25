# agent-rules

给 Codex 和 Claude Code 用的科研代码与写作规则，专治两个毛病：**防御性编程**和**防御性写作**。

- 防御性编程：到处加 try/catch、静默兜底、对自己写死的常数做检查。规则要求出错直接报错，不吞错误，不用默认值掩盖问题。
- 防御性写作：论文里堆 may、could，写 "cannot establish" 这类提前辩解的句子。规则要求去掉多余的辩解，保留近似条件、适用范围、单器件等必要的限定。

另外还规定了科研脚本的风格：写成平铺的脚本、不导出文件只弹图窗、变量名对应公式符号、按数据性质选色表。覆盖 Python、MATLAB、Mathematica。

## 文件

| 文件 | 内容 |
|---|---|
| [research-coding.md](research-coding.md) | 只含"科研代码规范"一节，约 120 行，**推荐用这个** |
| [AGENTS.full.md](AGENTS.full.md) | 作者自己完整的 `~/.codex/AGENTS.md`，含个人的工作流设定，仅供参考 |

## 使用

追加，不要覆盖，否则会冲掉你自己已有的规则。

- **Codex**：把 `research-coding.md` 的内容追加到 `~/.codex/AGENTS.md` 末尾。新会话才会生效。
- **Claude Code**：复制到 `~/.claude/rules/research-coding.md`。新会话才会生效。

规则里有几处是作者个人偏好，用之前建议改成自己的：注释用英文、脚本默认不保存数据、运行时间超过 5 分钟先问、MATLAB 脚本开头加 `clear; close all; clc;`。

## 测试了什么

同一个 prompt，在 Codex（gpt-6-astra，high）上跑装规则前后各 2 次，任务有两个：

1. MATLAB 薄膜反射二维扫描（空气 / Si3N4 / SiO2）。
2. 写一段介质超表面 THG 的 Discussion。

结果：

- 代码：装规则前两次都存了 3 张 PNG 和一个 31 MB 的 `.mat`，相位图用了 hsv；装规则后只弹图窗，相位改用亮度恒定的色环，变量名不再带单位后缀。
- 写作：防御式否定从每段 4 处降到 1–2 处，叠加的 hedge 消失；单器件、只测 x 偏振、侧壁证据来自另一块样品等限定四段都保留了，没有夸大。
- 没有差异的：try/catch、超出数据范围时的提示、坐标轴标签。这几项装规则前就已经达标，规则管的是 Codex 本来就容易犯、但这次没犯的问题。

**这个测试的局限**：每组只跑了 2 次，每类只有 1 个任务，只测了 Codex，没有测 Claude Code，评分由作者本人完成、没有盲评。结论是方向一致，不是统计上的确定。

测试之后又加了三条规则，**没有经过验证**：MATLAB 里直接构造 cyclic 色表、不对写死的参数做 assert、没有要求时不自行添加参考文献。

## 依据

- Nguyen, [*Physics Is All You Need? A Case Study in Physicist-Supervised AI Development of Scientific Software*](https://arxiv.org/abs/2605.30353)（arXiv:2605.30353）：用 Claude Code 开发物理软件时，有效的监督做法包括明确禁止非物理的数值补丁，以及在多个参数点上验证。规则里"不加没有物理对应的修正系数"据此而来。
- OpenAI, [Codex Prompting Guide](https://developers.openai.com/cookbook/examples/gpt-5/codex_prompting_guide)：官方 starter prompt 里已有 "no broad catches or silent defaults" 的要求。

## 许可

[MIT](LICENSE)
