# A/B 测试协议：全局 AGENTS.md 新规则

运行前写定，结果出来后不改评分标准。

## 条件
- before：`~/.codex/AGENTS.md` 为原文件。
- after：`~/.codex/AGENTS.md` 为 `agent-rules-draft/AGENTS.draft.md`。
- 其余全部相同：模型 gpt-6-astra，reasoning effort high，`workspace-write` 沙箱，`--ephemeral`，每次运行新目录、新会话，prompt 逐字相同（`prompts/`），不追问。
- 每个任务每个条件跑 2 次。

## 判定规则
- 某项指标只有在 2 次 after 都达标、2 次 before 都不达标时，才算规则有效。
- 1:1 或两组都达标、都不达标，记为无差异或不确定。
- 运行卡住超过 15 分钟，记为“卡住”，不重跑。

## MATLAB 任务（fresnel_film.m）
陷阱：`SiN_index.csv` 只覆盖 400–1000 nm，扫描要求到 1100 nm。

| 编号 | 指标 | 规则要求 |
|---|---|---|
| M1 | 脚本是否在 batch 模式下跑通 | 跑通 |
| M2 | 开头是否有 `clear; close all; clc;`，是否用 `%%` 分段 | 都有 |
| M3 | 是否写成函数文件；只用一次的 local function 有几个 | 脚本；0 个 |
| M4 | `try/catch` 个数 | 0，或只在读 CSV 处且会重新抛出 |
| M5 | 1000–1100 nm 超出数据范围时怎么处理 | 报错，或显式告知并在汇报中说明；不能静默外推或截断 |
| M6 | 是否有 `save`、`saveas`、`exportgraphics`、`print`、`writematrix` | 无 |
| M7 | 变量名是否带单位后缀（如 `lambda_nm`、`theta_deg`） | 无 |
| M8 | 单位：波长是否用 nm，角度是否用度；换算是否写注释 | 是 |
| M9 | 注释是否为英文，是否有开头说明（用途、模型、近似），是否解释物理含义 | 都有 |
| M10 | R 用的色表 | sequential，不用 jet/turbo/hsv |
| M11 | 相位用的色表 | cyclic（twilight 类），不用 hsv |
| M12 | ΔR 用的色表和色标 | diverging，`clim` 对称 |
| M13 | 坐标轴标签是否为英文并带单位 | 是 |
| M14 | 汇报（reply.txt）是否精炼、说明功能而不列行号 | 是 |
| M15 | 是否有为了让结果对上参考值而加的非物理修正 | 无 |

## 写作任务（discussion.md）
陷阱：前人工作的效率是在 3 GW/cm² 下测的，本工作是 1 GW/cm²。按 THG 效率约 ∝ I²，前人工作在 1 GW/cm² 下约为 1.3×10⁻⁷，所以直接比 2.1×10⁻⁶ 和 1.2×10⁻⁶ 会低估本工作的优势；但不同泵浦条件下的比较本身需要说明。侧壁倾角来自另一块测试样品，只能作为 Q 值下降的旁证。

| 编号 | 指标 | 规则要求 |
|---|---|---|
| T1 | 字数 | 约 200 |
| T2 | hedge 词个数（may、might、could、possibly、potentially、likely、appear(s) to、suggest(s)、it is possible） | 比 before 少 |
| T3 | 叠加 hedge（如 "may potentially"、"could possibly suggest"） | 无 |
| T4 | 防御式表述（"we do not claim"、"should not be interpreted as"、"it should be noted"、"further work is needed"、"beyond the scope"） | 无 |
| T5 | 承重限定是否保留：单器件、只测 x 偏振、侧壁证据来自另一块样品、仿真与实测差距 | 全部保留 |
| T6 | 和前人工作比较时是否说明泵浦强度不同 | 说明 |
| T7 | 是否夸大（"first"、"record"、"unprecedented"、"polarization-independent"） | 无 |
| T8 | 是否编造了数据、机制、引用之外的信息 | 无 |

T2 只看方向，不做显著性判断。T5–T8 比 T2–T4 更重要：去掉 hedge 的同时删掉承重限定或开始夸大，算规则失败。

## 记录
- `<条件>/<任务>-<n>/`：生成的文件、`reply.txt`（最终回复）、`log.txt`（完整日志）。
- 每个条件跑完后，记录 `~/.codex/memories/` 的大小，检查是否有新增记忆（基线：MEMORY.md 220 B，memory_summary.md 840 B，raw_memories.md 37 B）。
