# Figure 1 of the A/B test: main code differences (before vs after the new AGENTS.md rules).
# Snippets are copied from before/matlab-1 and after/matlab-2 (alignment whitespace condensed).
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

out = "ab-compare-code.png"
mono = dict(family="monospace", fontsize=10)
bad, good = "#b03a2e", "#1e8449"

rows = [
    ("Script header",
     "%% TE reflection: air / dispersive Si3N4 film / semi-infinite SiO2\n"
     "% Run this script in MATLAB R2019a or later; no toolboxes are required.\n"
     "script_dir = fileparts(mfilename('fullpath'));",
     "no clear/close/clc: variables and figures of earlier runs survive",
     "% TE reflection of an air / Si3N4 film / semi-infinite SiO2 stack.\n"
     "% Model: isotropic, nonmagnetic, lossless media and coherent plane waves.\n"
     "clear; close all; clc;",
     "clean start; header states the physical model"),
    ("Parameters\nand names",
     "lambda_nm = 400:1:1100;\n"
     "theta_deg = (0:0.1:89).';\n"
     "n_air = 1;\n"
     "n_substrate = 1.45;\n"
     "thickness_nm = 200;",
     "unit suffixes in names; no comments on meaning or units",
     "n0 = 1;                  % Air refractive index (dimensionless).\n"
     "n2 = 1.45;               % SiO2 refractive index (dimensionless).\n"
     "d = 200;                 % Si3N4 film thickness (nm).\n"
     "wavelength = 400:1:1100; % Vacuum wavelength (nm).\n"
     "theta = (0:0.1:89).';    % External incidence angle (deg).",
     "symbols as in the formulas; units in comments"),
    ("Phase\ncolormap",
     "color_maps = {parula(256), hsv(256), blue_white_red};",
     "hsv: lightness jumps create false features in the phase map",
     "% A closed circle of constant Oklab lightness/chroma provides a cyclic map.\n"
     "phi = linspace(0, 2*pi, color_count).';\n"
     "Lab = [phase_lightness * ones(color_count, 1), ...\n"
     "    phase_chroma*cos(phi), phase_chroma*sin(phi)];",
     "cyclic and constant lightness: only hue encodes phase"),
    ("Output",
     "print(figures(map_idx), fullfile(script_dir, [file_stems{map_idx}, '.png']), ...\n"
     "    '-dpng', '-r180');\n"
     "save(fullfile(script_dir, 'fresnel_film_results.mat'), ...",
     "writes 3 PNG files + a 31 MB .mat on every run (both before runs)",
     "drawnow;",
     "figures stay in windows; nothing written to disk (both after runs)"),
]

fig = plt.figure(figsize=(17, 12), dpi=150)
gs = fig.add_gridspec(len(rows) + 2, 3, width_ratios=[0.09, 0.455, 0.455],
                      height_ratios=[0.22, 0.62, 0.85, 0.72, 0.62, 2.0],
                      hspace=0.14, wspace=0.03, left=0.02, right=0.99, top=0.95, bottom=0.05)
fig.suptitle("Codex MATLAB task: before vs after the new AGENTS.md rules (2 runs each)",
             fontsize=15, weight="bold")
for col, title, color in [(1, "Before: original AGENTS.md", bad), (2, "After: new rules", good)]:
    ax = fig.add_subplot(gs[0, col]); ax.axis("off")
    ax.text(0.01, 0.2, title, fontsize=13, weight="bold", color=color)

for i, (label, b_code, b_note, a_code, a_note) in enumerate(rows, start=1):
    ax = fig.add_subplot(gs[i, 0]); ax.axis("off")
    ax.text(0.95, 0.5, label, ha="right", va="center", fontsize=11, weight="bold")
    for col, code, note, color, face in [(1, b_code, b_note, bad, "#fdf2f1"),
                                         (2, a_code, a_note, good, "#eefaf2")]:
        ax = fig.add_subplot(gs[i, col])
        ax.set_xticks([]); ax.set_yticks([])
        ax.set_facecolor(face)
        for s in ax.spines.values():
            s.set_color(color); s.set_linewidth(1.2)
        ax.text(0.015, 0.93, code, va="top", **mono)
        ax.text(0.015, 0.07, "→ " + note, va="bottom", fontsize=10.5,
                color=color, style="italic", weight="bold")

# %% Bottom panel: why hsv fails for phase. CIE L* of each colormap around the phase circle.
def srgb_to_lstar(rgb):
    lin = np.where(rgb <= 0.04045, rgb / 12.92, ((rgb + 0.055) / 1.055) ** 2.4)
    Y = lin @ np.array([0.2126, 0.7152, 0.0722])  # relative luminance (D65)
    f = np.where(Y > (6 / 29) ** 3, np.cbrt(Y), Y / (3 * (6 / 29) ** 2) + 4 / 29)
    return 116 * f - 16

phi = np.linspace(0, 2 * np.pi, 257)
hsv_rgb = plt.get_cmap("hsv")(phi / (2 * np.pi))[:, :3]
# Same construction as after/matlab-2: Oklab L = 0.72, C = 0.10, hue around the circle
Lab = np.column_stack([0.72 * np.ones_like(phi), 0.10 * np.cos(phi), 0.10 * np.sin(phi)])
lms = Lab @ np.array([[1, 1, 1], [0.3963377774, -0.1055613458, -0.0894841775],
                      [0.2158037573, -0.0638541728, -1.2914855480]])
lin = (lms ** 3) @ np.array([[4.0767416621, -1.2684380046, -0.0041960863],
                             [-3.3077115913, 2.6097574011, -0.7034186147],
                             [0.2309699292, -0.3413193965, 1.7076147010]])
ok_rgb = np.where(lin > 0.0031308, 1.055 * np.abs(lin) ** (1 / 2.4) - 0.055, 12.92 * lin)

L_hsv, L_ok = srgb_to_lstar(hsv_rgb), srgb_to_lstar(ok_rgb)
sub = gs[len(rows) + 1, 1:].subgridspec(2, 2, width_ratios=[1, 1.2], height_ratios=[0.12, 1],
                                        wspace=0.12, hspace=0)
ax = fig.add_subplot(sub[1, 0])
ax.imshow(np.stack([hsv_rgb, ok_rgb]), aspect="auto", extent=[-np.pi, np.pi, 1.5, -0.5])
ax.set_yticks([0, 1], ["hsv (before)", "Oklab cyclic (after)"])
ax.set_xticks([-np.pi, 0, np.pi], ["-π", "0", "π"])
ax.set_xlabel("Phase arg(r) (rad)")
ax.set_title("Phase colormaps used", fontsize=11, weight="bold")
ax = fig.add_subplot(sub[1, 1])
ax.plot(phi - np.pi, L_hsv, color=bad, lw=2, label="hsv (before)")
ax.plot(phi - np.pi, L_ok, color=good, lw=2, label="Oklab cyclic (after)")
ax.set_xticks([-np.pi, 0, np.pi], ["-π", "0", "π"])
ax.set_xlabel("Phase arg(r) (rad)")
ax.set_ylabel("Perceived lightness L*")
ax.set_ylim(0, 100)
ax.set_title("Lightness L*: hsv %.0f–%.0f (false bands), Oklab %.0f–%.0f (uniform)"
             % (L_hsv.min(), L_hsv.max(), L_ok.min(), L_ok.max()), fontsize=11, weight="bold")
ax.legend(loc="lower right")
fig.savefig(out, dpi=150)
print("saved", out)
