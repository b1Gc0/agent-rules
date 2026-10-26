# Codex 规则 A/B 测试材料

本目录归档了 2026-10-25 的一次小样本对比：MATLAB 科研脚本和英文 Discussion 两类任务，安装规则前后各运行两次，共 8 次主会话。

**这是一次使用案例，不是严格的模型能力评测。**完整生成结果都保留在下面；图片只摘录了其中的部分内容。

## 从哪里看

- [代码对比图](figures/ab-compare-code.png) / [文本对比图](figures/ab-compare-text.png)
- [原始测试方案](reports/protocol.original.md)
- [原始结果报告](reports/results.original.md)
- **[归档复核与更正](reports/archive-notes.md)**：阅读报告和图之前请先看，原报告有一处叠加 hedge 的误记，词表也在分析阶段扩大过。
- [MATLAB prompt](prompts/matlab.txt) / [写作 prompt](prompts/text.txt)

| 任务 | 安装前 | 安装后 |
|---|---|---|
| MATLAB 第 1 次 | [代码](before/matlab-1/fresnel_film.m) / [回复](before/matlab-1/reply.txt) | [代码](after/matlab-1/fresnel_film.m) / [回复](after/matlab-1/reply.txt) |
| MATLAB 第 2 次 | [代码](before/matlab-2/fresnel_film.m) / [回复](before/matlab-2/reply.txt) | [代码](after/matlab-2/fresnel_film.m) / [回复](after/matlab-2/reply.txt) |
| Discussion 第 1 次 | [全文](before/text-1/discussion.md) / [回复](before/text-1/reply.txt) | [全文](after/text-1/discussion.md) / [回复](after/text-1/reply.txt) |
| Discussion 第 2 次 | [全文](before/text-2/discussion.md) / [回复](before/text-2/reply.txt) | [全文](after/text-2/discussion.md) / [回复](after/text-2/reply.txt) |

## 测试条件与版本

- 在 Codex app 中手动新建会话运行，不是使用原方案设想的 CLI `--ephemeral` 运行；主会话记录的模型标识为 `gpt-6-astra`，reasoning effort 为 `high`，权限为 `workspace-write`、`on-request`。这里仅记录工具报告的标识，不据此推断底层模型身份。
- 每个条件、每个任务重复两次，使用相同任务内容。写作 prompt 的粘贴存在空行差异，并非严格字节相同。
- [before.full.md](rules/before.full.md) 来自安装前的全局规则备份。
- [after.reconstructed.full.md](rules/after.reconstructed.full.md) 根据保留的最终草稿，撤回测试后新增的三条规则重建；**不是测试当时保存的逐字快照**。本地会话的指令记录部分出现编码乱码，不将其发布为可靠快照。
- 当前仓库根目录的规则又做过三项调整：MATLAB 直接构造 cyclic 色表、不检查写死的参数、未要求时不自行添加引用。这三项不属于已完成 A/B 测试的结论。
- Claude Code、Python 和 Mathematica 没有进行这轮 A/B 测试。

## 输入数据不是实测结果

[SiN_index.csv](fixtures/SiN_index.csv) 是用于测试的合成折射率表，使用 Cauchy 形式生成：

```text
n = 1.98 + 0.012 / wavelength^2    (wavelength in micrometres)
```

波长为 400–1000 nm、间隔 10 nm，折射率保留四位小数。任务要求扫描到 1100 nm，目的是观察 agent 如何处理超出数据覆盖范围的情况，而不是提供经验证的 Si3N4 材料模型。

THG prompt 的器件和效率数值也是人为构造的写作测试情境，不代表本仓库作者获得了这些实验结果。生成文本中的参考文献是 agent 自行添加的，不等于这些测试数值来自该文献。

## 复查与复用

- MATLAB：打开任一 `matlab-*` 目录运行 `fresnel_film.m`，同目录已包含输入表。注意 before 代码会导出图片和数据，after 代码包含 `clear; close all; clc;`。建议在独立的 MATLAB 会话或副本目录中运行。
- 图片：在安装了 NumPy、Matplotlib 的 Python 环境中，进入 `figures/`，分别运行 `make_fig_code.py`、`make_fig_text.py`。脚本会重建同名 PNG。原始图片和绘图脚本作为历史展示材料保留，部分解释需结合归档更正说明阅读。
- 想重新让 agent 生成代码或文字，应复制 prompt 和输入表到仓库之外的空目录、开启新会话。不要从本仓库内部运行生成测试，否则仓库中的现行规则、既有答案和报告可能影响结果。

## 归档与隐私

代码、Discussion、CSV、prompt 和原报告保留原内容；`reply.txt` 仅将含本机用户名和目录的绝对链接改成同目录相对链接。未上传完整会话日志、认证文件、个人记忆库、两份约 31 MB 的 `.mat` 或六张计算输出 PNG；两张对比说明图保留。

[manifest.sha256](manifest.sha256) 记录本目录归档文件的 SHA-256（不包含清单自身），方便检查下载后的内容。
