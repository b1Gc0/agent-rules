# Figure 2 of the A/B test: main writing differences (before vs after the new AGENTS.md rules).
# Sentences are quoted verbatim from before/text-1, before/text-2, after/text-1, after/text-2.
# Markup: [h:...] hedge, [n:...] defensive negation, [p:...] positive statement, [c:...] kept caveat.
import re
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

out = "ab-compare-text.png"
bad, good = "#b03a2e", "#1e8449"
style = {"": dict(color="black"),
         "h": dict(color="#b9770e", weight="bold", bbox=dict(fc="#fdebd0", ec="none", pad=0.6)),
         "n": dict(color=bad, weight="bold", bbox=dict(fc="#fadbd8", ec="none", pad=0.6)),
         "p": dict(color=good, weight="bold", bbox=dict(fc="#d5f5e3", ec="none", pad=0.6)),
         "c": dict(color="#1f4e79", weight="bold", bbox=dict(fc="#d6eaf8", ec="none", pad=0.6))}

pairs = [
    ("Sidewall\nattribution",
     "before-2: Incorporating an 8° sidewall tilt reduces the simulated Q to approximately 400, "
     "[h:suggesting] that fabrication geometry [h:could] contribute substantially to resonance degradation.",
     "after-1: Incorporating an 8° sidewall inclination lowers the simulated Q to approximately 400, "
     "[p:supporting] geometric deviations as a [h:plausible] contributor to reduced resonant enhancement."),
    ("Other loss\nchannels",
     "before-2: Pump–resonance mismatch, additional losses and collection differences [h:could] also "
     "contribute, [n:but are not established here].",
     "after-2: Quantitative reconciliation also [p:requires assessing] pump–resonance spectral overlap, "
     "harmonic absorption and collection efficiency."),
    ("Comparison with\nprior work",
     "before-1: However, without matched excitation and collection conditions, this comparison "
     "[n:cannot establish] an intrinsic advantage of crystallinity.",
     "after-2: Establishing a material-specific advantage [p:requires] comparable pulse conditions and "
     "efficiency definitions, [p:since perturbative THG efficiency scales quadratically with pump intensity]."),
    ("Scope of the\nmeasurement",
     "before-1: Measurements on [c:one device] with [c:x-polarized] excitation also leave reproducibility "
     "and polarization dependence [n:unresolved], motivating correlated structural and optical "
     "characterization across multiple devices.",
     "after-2: Measurements currently [p:establish] performance for [c:one device] under [c:x-polarized] "
     "excitation; reproducibility and polarization dependence remain to be characterized."),
]

def tokens(marked):
    """Split marked text into word groups; each group is a list of (text, style) pieces."""
    pieces = []
    for m in re.finditer(r"\[(\w):([^\]]+)\]|([^\[]+)", marked):
        pieces.append((m.group(2), m.group(1)) if m.group(1) else (m.group(3), ""))
    words, current = [], []
    for text, key in pieces:
        for i, part in enumerate(re.split(r"(\s+)", text)):
            if part.isspace():
                if current: words.append(current); current = []
            elif part:
                current.append((part, key))
    if current: words.append(current)
    return words

def draw_wrapped(ax, marked, fontsize=10.5):
    """Draw styled words left to right inside ax, wrapping at the axes width."""
    fig = ax.figure; r = fig.canvas.get_renderer()
    box = ax.get_window_extent(r)
    probe = fig.text(0, 0, "a a", fontsize=fontsize); w_aa = probe.get_window_extent(r).width
    probe.set_text("aa"); space = w_aa - probe.get_window_extent(r).width; probe.remove()
    line_h = fontsize * fig.dpi / 72 * 1.75
    x0, x, y = box.x0 + 10, box.x0 + 10, box.y1 - 10 - fontsize * fig.dpi / 72
    for word in tokens(marked):
        items = [fig.text(0, 0, t, fontsize=fontsize, **style[k]) for t, k in word]
        widths = [it.get_window_extent(r).width for it in items]
        if x + sum(widths) > box.x1 - 10 and x > x0:
            x, y = x0, y - line_h
        for it, w in zip(items, widths):
            it.set_position((x, y)); it.set_transform(None); x += w
        x += space

fig = plt.figure(figsize=(17, 10), dpi=150)
gs = fig.add_gridspec(len(pairs) + 2, 3, width_ratios=[0.1, 0.45, 0.45],
                      height_ratios=[1.7, 0.22] + [0.62] * len(pairs),
                      hspace=0.12, wspace=0.03, left=0.02, right=0.99, top=0.90, bottom=0.02)
fig.suptitle("Codex writing task (THG Discussion paragraph): before vs after the new rules",
             fontsize=15, weight="bold")

# Counts from the four discussion.md files (word lists in ab-test-results.md)
ax = fig.add_subplot(gs[0, 1])
labels = ["before-1", "before-2", "after-1", "after-2"]
hedges, negs = [3, 4, 2, 2], [4, 4, 1, 2]
xs = range(4)
ax.bar([i - 0.2 for i in xs], hedges, 0.4, color="#f0b27a", label="hedge words")
ax.bar([i + 0.2 for i in xs], negs, 0.4, color="#ec7063", label="defensive negations")
ax.set_xticks(list(xs), labels); ax.set_ylabel("Count per ~200-word paragraph")
ax.set_ylim(0, 5); ax.legend(); ax.set_title("Hedges and defensive negations", weight="bold")
ax = fig.add_subplot(gs[0, 2]); ax.axis("off")
ax.text(0.03, 0.95,
        "Held constant in all four paragraphs (rule did not over-correct):\n"
        "  • all load-bearing caveats kept: one device, x-pol only,\n"
        "    sidewall data from a separate sample, sim–exp gap\n"
        "  • no overclaims (\"first\", \"record\", \"polarization-independent\")\n"
        "  • no invented data; added citations exist (checked via Crossref)\n\n"
        "Highlight key:", va="top", fontsize=11, linespacing=1.6)
for x, (k, name) in zip([0.03, 0.14, 0.40, 0.70],
                        [("h", "hedge"), ("n", "defensive negation"),
                         ("p", "positive / explanatory"), ("c", "kept caveat")]):
    ax.text(x, 0.12, name, fontsize=10.5, **style[k])

for col, title, color in [(1, "Before: original AGENTS.md", bad), (2, "After: new rules", good)]:
    ax = fig.add_subplot(gs[1, col]); ax.axis("off")
    ax.text(0.01, 0.1, title, fontsize=13, weight="bold", color=color)
panels = []
for i, (label, before, after) in enumerate(pairs, start=2):
    ax = fig.add_subplot(gs[i, 0]); ax.axis("off")
    ax.text(0.95, 0.5, label, ha="right", va="center", fontsize=11, weight="bold")
    for col, text, color, face in [(1, before, bad, "#fdf2f1"), (2, after, good, "#eefaf2")]:
        ax = fig.add_subplot(gs[i, col]); ax.set_xticks([]); ax.set_yticks([])
        ax.set_facecolor(face)
        for s in ax.spines.values():
            s.set_color(color); s.set_linewidth(1.2)
        panels.append((ax, text))
fig.canvas.draw()
for ax, text in panels:
    draw_wrapped(ax, text)
fig.savefig(out, dpi=150)
print("saved", out)
