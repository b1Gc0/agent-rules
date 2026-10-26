# 科研代码

以下规则适用于新写的 Python、MATLAB、Mathematica 科研脚本。修改已有脚本或模块化项目时，优先保持原结构、命名、风格和接口；仅在任务需要且已获授权的范围内调整。向已有项目新增的文件遵循该项目的已有约定。修改已有单文件科研脚本前，先通读整个脚本。错误处理规则对新写的代码始终适用；修改范围、依赖和运行验证规则同样适用于修改已有代码。

## 结构与修改

- 新程序默认是可逐段运行、从上到下阅读的脚本。只使用一次的代码内联；重复调用的代码再提取函数，物理函数关系（如 n(λ)）可直接定义。
- 可调参数集中放在开头，一行一个；代码按计算阶段分 cell，并用英文标题说明各段用途。以清楚为先，循环和向量化按可读性选择。
- 默认只改完成任务必需的部分。用户要求重写，或任务需要大范围调整时，先说明理由，再按本次授权范围重写。未改动部分的错误会影响所要求的结果时（如单位换算写错），直接修正并在汇报中说明；其他无关问题在汇报中指出，保留原状。
- 使用已有依赖；新增库或工具箱前确认。

## 注释、符号与单位

- 注释用英文。开头简述用途、物理模型和近似；已知的公式来源或方程编号写清楚，来源缺失时标待补。
- 注释充分说明物理含义、单位、关键推导和这一步的理由；不写复述语法的注释（如 "loop over i"）。
- 变量尽量对应论文符号，例如 `a`、`k0`、`beta`、`n_eff`；单位放在注释中，不用 `wavelength_nm` 这类后缀。
- 使用领域常用单位，如 nm、μm、THz；在公式和外部接口需要处显式换算。归一化时写明尺度及恢复物理单位的关系。

## 错误处理

- 计算失败就暴露原因并修复根因；保留异常和失败信息，不用静默默认值、fallback 或兼容分支绕过错误，除非用户要求。
- 错误捕获仅用于文件、网络、用户输入等 I/O 边界，并重新抛出或明确报错。外部输入和计算结果按需要检查；写死的参数不加例行 assert 或范围检查。
- 计算出现意外的 NaN/Inf（有意引入的除外，如绘图掩膜）、越界或不收敛时，抛出异常或报错退出，并给出有关数值；不静默替换、clip 或切换参数。与参考结果不符时分析物理和数值原因，不加无物理依据的修正因子。
- 违反后会得到看似合理的错误结果时，用物理约束检查计算结果，如能量守恒（R + T + A = 1）、无源性或互易性；超出数值容差时报错并给出有关数值。

## 绘图与输出

- 默认显示图窗或 notebook 内图形；图片和计算数据仅在用户要求时保存。默认字体，英文标签，有量纲的轴标明单位。
- 按数据结构选择色表：有序标量用 sequential（如 viridis）；围绕零点的有符号量用 diverging，零点居中、范围对称；周期相位用 cyclic（如 twilight、cmocean phase、CET cyclic）。
- 不用 hsv、jet、turbo；必要的 cyclic/diverging 色表优先用已有实现，避免增加依赖。

## 运行验证

- 创建或修改科研脚本后，自行定位现有解释器、环境或计算软件，完整运行原参数脚本；不以缩小网格、减少扫描点等缩减参数的运行替代正式运行，不另外编写 smoke test 或单元测试，除非用户要求。
- 和解析解、极限或文献/实验参考值对比时，至少再换一个参数点，检查是否只在单点凑巧吻合。
- 报告离散方法（网格、mesh 或截断阶数）的定量结果时，说明是否检查过离散收敛，未检查时如实说明；不因此强制额外运行。
- 预计运行超过 5 分钟时，说明预计耗时并等确认；估计依据是扫描点数、网格和循环规模。
- 自动验证可采用非交互方式，保持交付代码的显示方式；计算是否跑通与图窗/notebook 显示是否检查过，分别据实说明。

## Python

- 用 `# %%` 分段，变量名用 ASCII。默认依赖 NumPy、SciPy、Matplotlib。
- 默认直接写脚本，不包 `main()`、class、argparse 或 logging 框架。multiprocessing 需要入口保护时保留 `if __name__ == "__main__"`。
- 用 `plt.show()` 显示；自动验证时可在进程环境设置 `MPLBACKEND=Agg`，不将显示代码改成导出代码。diverging 色标用对称范围 `vmin=-vmax`。

示例：

```python
# Phase accumulated by a guided mode along z.
# Model: single guided mode with constant effective index; no loss or dispersion.
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

## MATLAB

- 写 `.m` 脚本，开头 `clear; close all; clc;`，用 `%%` 分段。变量名用 ASCII，需要复用的 local function 放在脚本末尾（MATLAB 要求脚本中的 local function 位于文件末尾）。
- 易混淆的逐元素运算（`.*`、`./`、`.^`）解释其物理或数组含义；默认不调用保存或导出命令。
- 缺少合适的内置色表时，在脚本里简短构造：diverging 可插值蓝–白–红，cyclic 可用 Oklab 固定 L、C 的闭合色环，保持 RGB 在有效色域内。
- 自动验证可用 `matlab -batch "run('script.m')"`；保留 figure 显示代码，供用户交互运行。显式的等待交互代码仍需单独处理。

## Mathematica

- 主要交付 notebook 使用的分 cell 代码。编辑已有 `.nb` 需要用户明确要求；默认提供可粘贴代码，不直接改写 box 表达式。
- 第一个 cell 用 ``ClearAll["Global`*"]``；允许希腊字母符号，英文注释用 `(* ... *)`，普通数值的单位写在注释中，不用 `Quantity[]`。
- 需要检查失败时用 `Enclose`/`Confirm`，检查失败时中止求值并给出有关数值；只返回 `Failure` 对象、由后续 cell 继续使用，不算报错。不用 `Quiet` 遮蔽报错。
- 可用的 Wolfram MCP 提供相应工具时，用 `ReadNotebook` 读取、`WolframLanguageEvaluator` 验证；不以 notebook 转换工具覆盖已有 `.nb`。
- 没有相应 MCP 时，用临时 `.wl` 和 `wolframscript -file` 验证同一计算代码，检查 messages 以及输出中的 `Failure`/`$Aborted`，完成后清理该临时文件；不能据此声称已经验证 notebook 排版或交互。
- 图形在 notebook 中显示，数据和图片遵循本文件的输出约定。
