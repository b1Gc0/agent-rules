<!-- Synced copy of the "科研代码规范" section in ~/.codex/AGENTS.md. Edit both files together. -->

## 科研代码规范（Python / MATLAB / Mathematica）

以下规则适用于新写的科研脚本。修改已有代码时，已有代码的结构、命名和风格优先于本规范，只有我要求重写时才按本规范改写；冲突之处在汇报里指出。“错误处理”一节对你新写的代码始终适用。

### 错误处理
- 出错时让错误直接暴露（抛出异常或报错退出），从根本原因修复，不用 workaround 掩盖症状。
- 错误捕获（`try/except`、`try/catch`、`Check`）只放在文件读写、网络、用户输入这类 I/O 边界，并且要重新抛出或报错。
- 不对脚本里写死的参数做 `assert` 或范围检查（如 `assert(n0 > 0)`），这些值是我自己写的。只校验外部输入（读入的文件、数据）和计算结果。
- 不加静默 fallback、静默默认值、兼容分支，除非我明确要求。
- 数值计算出现 NaN/Inf、参数越界或不收敛时，直接报错并给出出问题的数值。不静默替换、截断或回退到默认参数，因为这会把物理错误变成看似合理的结果。
- 不加没有物理对应的修正系数或经验常数来让结果对上参考值。对不上时报告差异，并分析可能的物理或数值原因。
- 需求变更时，用新规则替换旧规则，不把旧需求保留成“禁止 X”的条款。

### 结构
- 默认写成从上到下顺序执行的脚本，可以逐段阅读和运行。
- 同一段代码被调用 2 次及以上才写成函数，只用一次的代码保持内联。表示物理量函数关系的定义（如色散关系 n(λ)）不受此限。
- 所有可调参数集中放在开头，每行一个，注释写明含义和单位。
- 用 cell 分段，每段开头写一行英文标题注释。
- 以清楚为先：向量化影响可读性时，可以用显式循环。
- 只用已有的库或工具箱，引入新依赖前先问我。

### 注释
- 脚本开头用几行注释写明：用途、物理模型和近似、参考文献或方程来源。
- 注释用英文，写得充分：物理含义、单位、公式出处或方程编号、这一步为什么需要。
- 不写复述语法的注释（如 "loop over i"）。

### 单位与命名
- 参数用领域常用单位，例如波长和晶格常数用 nm 或 μm、频率用 THz，不一律换成 SI。
- 变量名不带单位后缀（写 `wavelength`，不写 `wavelength_nm`），单位写在注释里。
- 变量名尽量对应论文公式里的符号，例如 `k0`、`beta`、`n_eff`、`a`。
- 公式要求单位一致的地方（例如和 c、ħ、ε0 一起运算），显式写出单位换算并加注释。
- 使用归一化单位时（例如以晶格常数 a 为长度单位、频率写成 ωa/2πc），在参数区注明归一化方式和换回物理单位的关系。

### 绘图
- 默认弹出图窗显示，不导出图片文件，除非我要求。
- 坐标轴标签用英文并带单位，例如 `Wavelength (nm)`。字体用默认值。
- 按数据性质选择颜色映射，除非我指定：
  - 单调或非负的量（强度、功率）用 sequential，如 viridis 类；
  - 有正负、关心零点的量（实场、差值）用 diverging，零点居中、色标对称；
  - 相位等周期量用 cyclic，如 twilight、cmocean `phase`、CET cyclic。不用 hsv，它亮度不均匀，会制造假的特征。
- 不用 jet、turbo 这类彩虹色表。
- MATLAB 没有合适的内置 diverging 或 cyclic 色表时，在脚本里构造，不擅自引入工具箱：diverging 用几行插值（如蓝–白–红）；cyclic 用亮度恒定的色环（如 Oklab 中固定 L、C，让色相转一圈），代码尽量短。

### 数据输出
- 计算结果不保存为文件（`.npy`、`.mat`、`.csv`、`.mx` 等），只画图，除非我要求。

### 修改方式
- 默认只改完成任务所必需的部分，不顺手重构或改动无关代码。
- 我明确要求重写，或你判断改动幅度很大时，整体重写。后一种情况先用一两句话说明为什么重写。
- 发现和任务无关的问题（bug、死代码、可疑的物理假设）时，在汇报里指出，不顺手修改。

### 运行与验证
- 写完或改完后，自己运行原脚本，确认能跑通。不另写 smoke test 或单元测试，也不为了加快速度缩小参数。
- 结果要和参考值（解析解、极限情况、文献或实验数据）对比时，除了原参数，至少再换一个参数点对比一次，防止结果只在一个参数下凑巧对上。
- 根据网格规模、循环次数、扫描点数估计运行时间。预计超过 5 分钟时，先告诉我估计的时间，等我确认再运行。
- 运行环境自己找，包括 Python 解释器或 conda 环境、MATLAB、wolframscript 的路径。
- 图窗会阻塞自动运行。验证时按下面各语言的方法运行，不改动脚本里显示图窗的代码。

### 汇报
- 改完后的汇报保持精炼，说明改了哪些功能或形式（如“扫描改成二维”“相位图改用 cyclic 色表”），不列行号或逐行改动。

### Python
- 用 `# %%` 分段，方便在 VS Code 中逐段运行。
- 不写 `main()`、class、argparse、logging、`if __name__ == "__main__"`。例外：用到 multiprocessing 时保留 `__main__` guard（Windows 要求）。
- 默认只用 numpy、scipy、matplotlib。
- 变量名只用 ASCII，例如 `lam`（`lambda` 是关键字）、`eps`。
- 结尾用 `plt.show()`。验证时设置环境变量 `MPLBACKEND=Agg` 再运行，此时 `plt.show()` 不会阻塞。
- diverging 色表用对称的 `vmin=-vmax` 或 `TwoSlopeNorm` 让零点居中。

示例：
```python
import numpy as np
import matplotlib.pyplot as plt

# %% Parameters
a = 500        # lattice constant (nm)
lam = 1550     # free-space wavelength (nm)
n_eff = 2.1    # effective index of the guided mode

# %% Calculation
k0 = 2 * np.pi / lam                     # free-space wavenumber (rad/nm)
beta = n_eff * k0                        # propagation constant (rad/nm)
z = np.linspace(0, 20 * a, 500)          # propagation distance (nm)
phase = np.angle(np.exp(1j * beta * z))  # wrapped phase in (-pi, pi]

# %% Plot
plt.plot(z / 1e3, phase)
plt.xlabel("z (μm)")
plt.ylabel("Phase (rad)")
plt.show()
```

### MATLAB
- 写成脚本文件，开头加 `clear; close all; clc;`，用 `%%` 分段。
- 需要复用的函数作为 local function 放在脚本末尾（MATLAB 语法要求）。
- 变量名只用 ASCII（MATLAB 不支持 Unicode 变量名）。
- 不用 `save`、`saveas`、`exportgraphics`、`print` 导出，除非我要求。
- 容易和矩阵运算混淆的逐元素运算（`.*`、`./`、`.^`）加注释说明。
- 验证时用 `matlab -batch "run('script.m')"` 运行，batch 模式不会因图窗阻塞。

### Mathematica
- 我主要用 `.nb`。不直接编辑 `.nb` 文件（底层是 box 表达式，容易改坏），除非我要求；在回复中按 cell 给出可直接粘贴的代码。
- 第一个 cell 用 ``ClearAll["Global`*"]`` 清空符号。
- 可以用希腊字母作符号（`λ`、`ε`、`β`），和公式对应。
- 注释用 `(* ... *)`，英文。
- 不用 `Quantity[]` 单位对象，用普通数值加注释说明单位。
- 不用 `Quiet` 压掉报错信息。需要显式检查时用 `Enclose`/`Confirm`，失败时直接报错。
- 如果可以用 Wolfram MCP（Mathematica 15 及以上内置），用 `ReadNotebook` 读取 `.nb`，用 `WolframLanguageEvaluator` 验证代码；仍然不用 `WriteNotebook` 覆盖我已有的 `.nb`。没有 Wolfram MCP 时，按下面的 wolframscript 方式验证。
- 不用 `Export`，图直接在 notebook 中显示。
- 验证时把代码写入临时 `.wl` 文件，用 `wolframscript -file` 运行，确认没有报错信息（messages），运行后删除临时文件。

### 防御性写作（论文、报告、文档）
- 去掉多余的 caveat、免责声明、叠加的 hedge（如 "may potentially"）、对假想审稿人的预先辩解和自我贬低式表述。
- 用正面陈述代替否定式辩解：写“本文分析 Y”，不写“本文并不声称 X”。
- 保留承重的限定：近似条件、适用范围、仿真和实测的区别、样本量和参数设置。适用范围的限制集中写在 Limitations 或 Discussion 中。
- 不为了让句子显得有力而夸大结论，或编造事实、数值、机制。
- 没有要求时不自行添加参考文献；需要引用的地方标 `[ref]`，由我补充。

### 规则文件维护
- 全局规则文件的默认位置：Codex 为 `~/.codex/AGENTS.md`（设置了 `CODEX_HOME` 时在该目录下），Claude Code 为 `~/.claude/CLAUDE.md` 和 `~/.claude/rules/`。
- 需要修改全局规则时，如果在默认位置找不到规则文件，先找到实际生效的文件，然后告诉我应该改哪个文件、怎么改，不要直接修改。
