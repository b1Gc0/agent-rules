# Research Code

Apply these rules to new research scripts in Python, MATLAB, and Mathematica. When modifying existing scripts or modular projects, preserve their structure, naming, style, and interfaces unless the task requires changes within the authorized scope. New files added to an existing project follow that project's conventions. Read an existing single-file research script in full before modifying it. The error-handling rules always apply to newly written code. The change-scope, dependency, and execution-and-verification rules apply to both new and modified code.

## Structure and Changes

- Default to scripts that run section by section and read from top to bottom. Keep single-use code inline, and extract functions for repeated calls. Definitions of physical relationships, such as n(λ), may be functions directly.
- Put tunable parameters at the top, one per line. Divide the code into cells by calculation stage, with English headings explaining their purpose. Choose loops or vectorization for readability.
- Make only the changes required by the task. When the user requests a rewrite, or the task requires extensive changes, explain why before rewriting within the current authorization. When unchanged code contains an error that affects the requested results, such as a wrong unit conversion, fix it and report the fix. Report other unrelated issues without changing them.
- Use existing dependencies. Ask before adding a library or toolbox.

## Comments, Symbols, and Units

- Write comments in English. Start with a brief explanation of the purpose, physical model, and approximations. Include known equation sources or numbers; mark missing sources for completion.
- Comment sufficiently on physical meaning, units, key derivations, and the reason for a step. Do not write comments that restate syntax, such as "loop over i".
- Match variable names to paper notation where practical, such as `a`, `k0`, `beta`, and `n_eff`. Put units in comments, not suffixes such as `wavelength_nm`.
- Use customary field units, such as nm, μm, and THz. Make conversions explicit where equations or external interfaces require them. For normalized units, state the scale and the conversion back to physical units.

## Error Handling

- Surface computation failures and fix their root cause. Preserve exceptions and failure information rather than bypassing errors with silent defaults, fallbacks, or compatibility branches, unless the user requests that behavior.
- Catch errors only at I/O boundaries such as files, networks, and user input, and re-raise them or report an explicit error. Check external inputs and computed results where needed; do not add routine assertions or range checks for hardcoded parameters.
- When a computation produces unexpected NaN/Inf (excluding values deliberately introduced, such as plot masks), goes out of range, or fails to converge, raise an exception or terminate with an error and include the relevant values. Do not silently replace values, clip them, or switch parameters. Investigate physical and numerical reasons for disagreement with reference results rather than introducing correction factors without a physical basis.
- Check computed results against physical constraints where a violation would otherwise produce plausible-looking wrong results, such as energy conservation (R + T + A = 1), passivity, or reciprocity. When a violation exceeds numerical tolerance, raise an error with the relevant values.

## Plotting and Output

- Default to figure windows or inline notebook graphics. Save figures and computed data only when requested. Use default fonts, English labels, and units on dimensional axes.
- Choose colormaps by data structure: sequential for ordered scalar values, such as viridis; diverging for signed quantities centered on zero, with zero centered and symmetric limits; cyclic for periodic phase, such as twilight, cmocean phase, or CET cyclic.
- Do not use hsv, jet, or turbo. Reuse available cyclic/diverging implementations before adding dependencies.

## Execution and Verification

- After creating or modifying a research script, locate the existing interpreter, environment, or computation software independently, and run the complete script with the original parameters. Do not substitute a reduced grid, fewer scan points, or other reduced parameters for the actual run, or write additional smoke tests or unit tests unless requested.
- When comparing with an analytical solution, limiting case, or literature/experimental reference, compare at least one additional parameter point to check against accidental agreement at a single point.
- When reporting quantitative results from discretized methods (grid, mesh, or truncation order), state whether discretization convergence was checked, and say so when it was not. This does not require additional runs.
- If a run is expected to exceed 5 minutes, explain the estimate and wait for confirmation. Base the estimate on scan points, grid size, and loop scale.
- Automated verification may be noninteractive while preserving the display behavior in the delivered code. Report computation results and figure-window or notebook display status separately, and state when the display was not inspected.

## Python

- Use `# %%` cells and ASCII variable names. Default to NumPy, SciPy, and Matplotlib.
- Write scripts directly by default rather than wrapping them in `main()`, classes, argparse, or a logging framework. Retain `if __name__ == "__main__"` when multiprocessing requires an entry-point guard.
- Display figures with `plt.show()`. For automated verification, you may set `MPLBACKEND=Agg` in the process environment. Preserve the delivered display code rather than replacing it with exports. Use symmetric diverging limits with `vmin=-vmax`.

Example:

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

- Write `.m` scripts beginning with `clear; close all; clc;`, divided by `%%` cells. Use ASCII variable names, and put reusable local functions at the end of the script, as MATLAB requires for local functions in scripts.
- Explain the physical or array meaning of easily confused element-wise operations (`.*`, `./`, `.^`). Do not call save or export commands by default.
- When suitable built-in colormaps are unavailable, construct them briefly in the script: interpolate blue–white–red for a diverging map, or use a closed Oklab hue circle with fixed L and C for a cyclic map, keeping RGB values within gamut.
- Automated verification may use `matlab -batch "run('script.m')"`. Preserve figure display code for interactive use; code that explicitly waits for interaction requires separate handling.

## Mathematica

- Primarily deliver cell-by-cell code for notebooks. Editing an existing `.nb` requires an explicit user request; otherwise supply paste-ready code rather than editing box expressions directly.
- Start the first cell with ``ClearAll["Global`*"]``. Greek-letter symbols are allowed. Use English `(* ... *)` comments, and document units of ordinary numerical values in comments rather than using `Quantity[]`.
- When failure checks are needed, use `Enclose`/`Confirm` and stop the evaluation with the offending values when a check fails; returning a `Failure` object that later cells keep using does not count as an error. Do not hide messages with `Quiet`.
- When an available Wolfram MCP provides the relevant tools, use `ReadNotebook` to read and `WolframLanguageEvaluator` to verify. Do not overwrite existing `.nb` files through notebook-conversion tools.
- Without the relevant MCP tools, verify the same computation code through a temporary `.wl` file and `wolframscript -file`, inspect messages and any `Failure` or `$Aborted` output, then remove that temporary file. This does not verify notebook layout or interactivity.
- Display graphics in the notebook; follow this file's output rules for data and figures.
