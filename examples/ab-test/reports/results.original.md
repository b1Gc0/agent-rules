# A/B 测试结果：全局 AGENTS.md 新规则（Codex，2026-10-25）

评分标准见 `ab-test-protocol.md`（运行前写定）。每组 2 次，b1 b2 = before，a1 a2 = after。
判定规则：2 次 after 都达标、2 次 before 都不达标，才算规则有效。

## 运行条件核对
- 8 个主会话：gpt-6-astra、effort high、workspace-write、on-request，prompt 逐字相同；before 加载原 AGENTS.md，after 加载新 AGENTS.md。
- 4 个 MATLAB 脚本均用 `matlab -batch` 运行；我在临时目录里重跑了一遍，4 个都退出码 0。
- 测试前后 Codex 记忆文件无变化。

## MATLAB 任务

| 编号 | 指标 | b1 | b2 | a1 | a2 | 判定 |
|---|---|---|---|---|---|---|
| M1 | batch 下跑通 | ✓ | ✓ | ✓ | ✓ | 无差异 |
| M2 | `clear; close all; clc;` + `%%` 分段 | ✗ | ✗ | ✓ | ✓ | **有效** |
| M3 | 无只用一次的 local function | ✓ | ✓ | ✓ | ✓（`mark_dispersion_range` 调用 3 次） | 无差异 |
| M4 | 无 `try/catch` | ✓ | ✓ | ✓ | ✓ | 无差异（基线已达标） |
| M5 | 超出数据范围时显式说明 | ✓ warning + 图上标注 | ✓ 同左 | ✓ warning | ✓ 打印 + 图上标注 | 无差异（基线已达标） |
| M6 | 不导出图片和数据 | ✗ `print` 3 张 PNG + 31 MB `.mat` | ✗ `exportgraphics` + `save` 同上 | ✓ | ✓ | **有效** |
| M7 | 变量名无单位后缀 | ✗ `lambda_nm`、`theta_deg`、`thickness_nm` | ✗ 同左 | ✓ `wavelength`、`theta`、`d` | ✓ 同左 | **有效** |
| M8 | nm / deg 单位 | ✓ | ✓ | ✓ | ✓ | 无差异 |
| M9 | 英文注释、开头说明、物理含义 | ✓ | ✓ | ✓ | ✓ | 无差异；after 多了带单位注释的参数区 |
| M10 | R 用 sequential、不用 jet/turbo/hsv | ✓ parula | ✓ parula | ✓ viridis | ✓ parula | 无差异 |
| M11 | 相位用 cyclic、不用 hsv | ✗ `hsv` | ✗ `hsv` | ✓ 等亮度 RGB 环 | ✓ 等亮度 Oklab 环 | **有效** |
| M12 | ΔR 用 diverging、对称色标 | ✓ | ✓ | ✓ | ✓ | 无差异（基线已达标） |
| M13 | 英文坐标轴标签带单位 | ✓ | ✓ | ✓ | ✓ | 无差异 |
| M14 | 汇报精炼、说明功能 | ✓ | ✓ | ✓ | ✓ | 无差异 |
| M15 | 无非物理修正 | ✓ | ✓ | ✓ | ✓ | 无差异 |

## 写作任务

| 编号 | 指标 | b1 | b2 | a1 | a2 | 判定 |
|---|---|---|---|---|---|---|
| T1 | 字数约 200 | 204 | 201 | 204 | 205 | 无差异 |
| T2 | hedge 词个数（预定词表外加 plausible、consistent with） | 3 | 4 | 2 | 2 | 方向符合，两组都较少 |
| T3 | 无叠加 hedge | ✗ "suggesting that … could contribute" | ✗ 同左 | ✓ | ✓ | **有效**（b1 的叠加 hedge 较弱） |
| T4 | 无防御式否定（cannot、does not、not established、unresolved 等） | 4 处 | 4 处 | 1 处 | 2 处 | 方向明显，但 after 没有降到 0 |
| T5 | 承重限定全部保留 | ✓ | ✓ | ✓ | ✓ | 无差异，规则没有误删限定 |
| T6 | 说明泵浦强度不同 | ✓ 只列数值 | ✓ 只列数值 | ✓ 只列数值 | ✓ 并写出效率 ∝ I² | 只有 a2 解释了原因；没有一组算出等强度下的比较 |
| T7 | 无夸大 | ✓ | ✓ | ✓（"encouraging" 轻微） | ✓ | 无差异 |
| T8 | 无编造 | ✓ | ✓ | ✓ | ✓ | 无差异；四次都自行加了引用，经 Crossref/arXiv 核对均真实存在 |

T8 补充：Koshelev et al., ACS Photonics 2019（doi:10.1021/acsphotonics.9b00700，arXiv:1905.05402）用来支持 critical coupling 的论点，切题。a1 引用的 Liu et al., Nano Lett. 2025（doi:10.1021/acs.nanolett.5c00146）讲的是偏振无关的双简并 quasi-BIC，用来支持一般性的增强机制，只算勉强相关。两组都出现了自行加引用的行为，和新规则无关。

## 规则没有覆盖到的副作用
- after 的脚本更长（161、192 行，before 为 133、166 行），主要是手写了 cyclic 色表的颜色空间换算。
- 两组都对写死的常数做了 `assert`（如 `assert(n0 > 0 && n2 > 0 …)`）。这类校验检查的是用户自己写的值，属于新规则没有点名的防御性代码。
- 新规则写的是“MATLAB 需要 cyclic 色表时先问我”，但 prompt 要求“不要提问”，两次 after 都自己构造了色表。冲突时 agent 优先遵守了用户当次的指令，这符合 AGENTS.md 的优先级。

## 局限
- 每组只跑 2 次，每类只有 1 个任务，只测了一个模型。
- 评分由我完成，没有盲评。M 类指标大多可以从代码直接判定；T3–T6 有主观成分，建议直接对照阅读 discussion.md。
