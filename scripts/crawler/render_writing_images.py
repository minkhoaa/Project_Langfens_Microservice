#!/usr/bin/env python3
"""
Render / fetch Task 1 writing prompt images.

Outputs 7 PNG files to <repo>/langfens-fe-app/public/writing-images/.

Strategy (per agreed plan):
  - Academic charts (bar / line / pie)  -> synthetic but plausible data
  - Academic process diagram (recycling) -> fetched from ielts-mentor.com
  - GT letter tasks (3)                  -> generic envelope/letter cover (matplotlib)

Idempotent: if the destination file already exists and matches the source checksum
(for fetched images) or any non-zero size (for synthetic), the step is skipped.

Usage:
    python scripts/crawler/render_writing_images.py            # render all
    python scripts/crawler/render_writing_images.py --slug X   # render one

Requires: matplotlib, Pillow, requests (already in crawler/requirements.txt).
"""

import argparse
import hashlib
import sys
from pathlib import Path

import matplotlib

matplotlib.use("Agg")  # headless
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
import requests

# ── Paths ──────────────────────────────────────────────────────────────────
# The langfens repo has two top-level dirs: Project_Langfens_Microservice (this
# script lives under scripts/crawler there) and langfens-fe-app (the Next.js
# frontend, a sibling). Walk up to the workspace root.
#   SCRIPT_DIR      = …/Project_Langfens_Microservice/scripts/crawler
#   parents[0]      = …/Project_Langfens_Microservice/scripts
#   parents[1]      = …/Project_Langfens_Microservice
#   parents[2]      = …/langfens                            ← workspace root
SCRIPT_DIR = Path(__file__).resolve().parent
MICRO_ROOT = SCRIPT_DIR.parents[1]            # …/Project_Langfens_Microservice
WORKSPACE_ROOT = SCRIPT_DIR.parents[2]         # …/langfens
PUBLIC_DIR = WORKSPACE_ROOT / "langfens-fe-app" / "public" / "writing-images"
CACHE_DIR = SCRIPT_DIR / "_cache_writing_images"
PUBLIC_DIR.mkdir(parents=True, exist_ok=True)
CACHE_DIR.mkdir(parents=True, exist_ok=True)

# Headings / colours use the langfens palette (see langfens-fe-app CLAUDE.md).
PRIMARY = "#2563EB"          # blue-600
PRIMARY_LIGHT = "#DBEAFE"    # blue-100
ACCENT = "#06D6A0"           # teal
TEXT = "#111827"             # gray-900
MUTED = "#6B7280"            # gray-500
BORDER = "#E5E7EB"           # gray-200

LETTER_ENVELOPE_URL = None  # we don't fetch an external envelope; draw our own

# (slug, kind, fetch_url or None, render_fn)
TASKS = [
    (
        "task1-academic-bar-chart-population-by-age",
        "academic",
        None,
        "render_bar_chart",
    ),
    (
        "task1-academic-line-graph-internet-users",
        "academic",
        None,
        "render_line_graph",
    ),
    (
        "task1-academic-pie-chart-energy-sources",
        "academic",
        None,
        "render_pie_charts",
    ),
    (
        "task1-academic-process-bottle-recycling",
        "academic",
        "https://www.ielts-mentor.com/images/writingsamples/"
        "ielts-graph-how-plastic-bottles-are-recycled.png",
        None,
    ),
    (
        "task1-gt-letter-complaint-noisy-neighbour",
        "letter",
        None,
        "render_letter_cover",
    ),
    (
        "task1-gt-letter-job-application-receptionist",
        "letter",
        None,
        "render_letter_cover",
    ),
    (
        "ielts-mentor-writing-4135-letter-to-your-friend-describing-your-experience-o",
        "letter",
        None,
        "render_letter_cover",
    ),
]


# ── Helpers ────────────────────────────────────────────────────────────────
def _save(fig: plt.Figure, dest: Path) -> None:
    dest.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(dest, dpi=150, bbox_inches="tight", facecolor="white")
    plt.close(fig)
    print(f"  ✓ rendered  {dest.relative_to(WORKSPACE_ROOT)}  ({dest.stat().st_size // 1024} KB)")


def _fetch(url: str, dest: Path) -> bool:
    """Download to dest (or to cache first, then copy). Skip if dest matches cached checksum."""
    cache_path = CACHE_DIR / dest.name
    if cache_path.exists():
        cached_hash = hashlib.sha256(cache_path.read_bytes()).hexdigest()
    else:
        cached_hash = None
        print(f"  ↓ fetching  {url}")
        r = requests.get(url, timeout=30, headers={"User-Agent": "Mozilla/5.0"})
        r.raise_for_status()
        cache_path.write_bytes(r.content)
        cached_hash = hashlib.sha256(cache_path.read_bytes()).hexdigest()
        print(f"  ↓ cached    {cache_path.name}  ({len(r.content) // 1024} KB)")

    if dest.exists():
        dest_hash = hashlib.sha256(dest.read_bytes()).hexdigest()
        if dest_hash == cached_hash:
            print(f"  = unchanged {dest.name}")
            return False
    dest.write_bytes(cache_path.read_bytes())
    print(f"  ✓ wrote     {dest.relative_to(WORKSPACE_ROOT)}  ({dest.stat().st_size // 1024} KB)")
    return True


# ── Renderers ──────────────────────────────────────────────────────────────
def render_bar_chart(slug: str) -> Path:
    """UK / Japan / India population by age group, 2020 vs 2050 (synthetic but plausible)."""
    age_groups = ["0-14", "15-29", "30-44", "45-59", "60-74", "75+"]
    countries = ["UK", "Japan", "India"]

    # Plausible synthetic percentages (sum ~100 within each country/year)
    data_2020 = {
        "UK":    [18, 19, 20, 21, 14,  8],
        "Japan": [12, 14, 18, 19, 21, 16],
        "India": [27, 26, 21, 14,  8,  4],
    }
    data_2050 = {
        "UK":    [15, 17, 19, 19, 17, 13],
        "Japan": [10, 12, 16, 17, 20, 25],
        "India": [19, 22, 23, 18, 12,  6],
    }

    fig, axes = plt.subplots(1, 3, figsize=(14, 5.5), sharey=True)
    x = np.arange(len(age_groups))
    width = 0.38

    for ax, country in zip(axes, countries):
        bars1 = ax.bar(x - width / 2, data_2020[country], width, label="2020",
                       color=PRIMARY, edgecolor="white", linewidth=0.5)
        bars2 = ax.bar(x + width / 2, data_2050[country], width, label="2050",
                       color=ACCENT, edgecolor="white", linewidth=0.5)
        ax.set_title(country, fontsize=14, fontweight="bold", color=TEXT, pad=10)
        ax.set_xticks(x)
        ax.set_xticklabels(age_groups, rotation=0, fontsize=9, color=TEXT)
        ax.set_ylim(0, 32)
        ax.set_facecolor("white")
        for spine in ("top", "right"):
            ax.spines[spine].set_visible(False)
        ax.spines["left"].set_color(BORDER)
        ax.spines["bottom"].set_color(BORDER)
        ax.grid(axis="y", color=BORDER, linestyle="-", linewidth=0.5, alpha=0.6)
        ax.set_axisbelow(True)
        ax.tick_params(colors=MUTED, labelsize=9)
        if country == "UK":
            ax.set_ylabel("Percentage of population (%)", fontsize=10, color=TEXT)

    axes[0].legend(loc="upper right", frameon=False, fontsize=10)
    fig.suptitle(
        "Population by Age Group — UK, Japan & India (2020 vs 2050)",
        fontsize=15, fontweight="bold", color=TEXT, y=1.02,
    )
    fig.text(
        0.5, -0.04,
        "Source: Synthetic data for IELTS practice (numbers approximate).",
        ha="center", fontsize=9, color=MUTED, style="italic",
    )
    return _save(fig, PUBLIC_DIR / f"{slug}.png")


def render_line_graph(slug: str) -> Path:
    """Internet users (millions) by region 2000-2020, synthetic."""
    years = np.array([2000, 2003, 2006, 2009, 2012, 2015, 2018, 2020])
    series = {
        "North America": np.array([134, 167, 203, 234, 250, 264, 286, 313]),
        "Europe":        np.array([105, 152, 199, 252, 290, 318, 343, 360]),
        "Asia":          np.array([115, 215, 421, 681, 922, 1175, 1576, 1840]),
        "Africa":        np.array([4,   10,  30,  72,  140, 221,  313,  387]),
    }
    colors = [PRIMARY, ACCENT, "#F59E0B", "#EC4899"]

    fig, ax = plt.subplots(figsize=(11, 5.8))
    for (label, ys), color in zip(series.items(), colors):
        ax.plot(years, ys, marker="o", markersize=7, linewidth=2.4, label=label, color=color)
        # label endpoint
        ax.annotate(label, xy=(years[-1], ys[-1]), xytext=(6, 0),
                    textcoords="offset points", fontsize=10, fontweight="bold",
                    color=color, va="center")

    ax.set_title("Internet Users by Region (millions), 2000–2020",
                 fontsize=15, fontweight="bold", color=TEXT, pad=14)
    ax.set_xlabel("Year", fontsize=11, color=TEXT)
    ax.set_ylabel("Users (millions)", fontsize=11, color=TEXT)
    ax.set_xticks(years)
    ax.set_xticklabels(years, color=MUTED)
    ax.set_facecolor("white")
    for spine in ("top", "right"):
        ax.spines[spine].set_visible(False)
    ax.spines["left"].set_color(BORDER)
    ax.spines["bottom"].set_color(BORDER)
    ax.grid(True, color=BORDER, linestyle="-", linewidth=0.5, alpha=0.7)
    ax.set_axisbelow(True)
    ax.tick_params(colors=MUTED, labelsize=9)
    ax.legend(loc="upper left", frameon=False, fontsize=10)

    fig.text(0.5, -0.02,
             "Source: Synthetic data for IELTS practice (numbers approximate).",
             ha="center", fontsize=9, color=MUTED, style="italic")
    return _save(fig, PUBLIC_DIR / f"{slug}.png")


def render_pie_charts(slug: str) -> Path:
    """Sources of energy in Australia, 1990 vs 2020."""
    labels = ["Coal", "Natural Gas", "Oil", "Hydro", "Renewables", "Nuclear"]
    sizes_1990 = [44, 13, 36, 4,  2, 1]
    sizes_2020 = [25, 27, 28, 6, 12, 2]
    colors = ["#1F2937", "#2563EB", "#F59E0B", "#06D6A0", "#10B981", "#EC4899"]

    fig, axes = plt.subplots(1, 2, figsize=(13, 6))
    for ax, sizes, year in zip(axes, (sizes_1990, sizes_2020), (1990, 2020)):
        wedges, _, _ = ax.pie(
            sizes, labels=None, colors=colors,
            autopct=lambda p: f"{p:.0f}%" if p >= 4 else "",
            startangle=90, wedgeprops=dict(linewidth=2, edgecolor="white"),
            pctdistance=0.72, textprops=dict(color="white", fontsize=10, fontweight="bold"),
        )
        ax.set_title(f"Energy Sources in Australia — {year}",
                     fontsize=14, fontweight="bold", color=TEXT, pad=12)

    # Shared legend at the bottom
    legend = fig.legend(
        wedges, labels,
        loc="lower center", ncol=6, frameon=False, fontsize=10,
        bbox_to_anchor=(0.5, -0.04), labelcolor=TEXT,
    )
    fig.suptitle("Sources of Energy in Australia: 1990 vs 2020",
                 fontsize=15, fontweight="bold", color=TEXT, y=1.02)
    return _save(fig, PUBLIC_DIR / f"{slug}.png")


def render_letter_cover(slug: str) -> Path:
    """Generic 'IELTS Letter Writing Task 1' cover image — an envelope on a soft background."""
    fig, ax = plt.subplots(figsize=(8.5, 5.5))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 6.5)
    ax.set_facecolor(PRIMARY_LIGHT)
    fig.patch.set_facecolor("white")

    # Envelope body
    body = mpatches.FancyBboxPatch(
        (1.6, 1.6), 6.8, 4.0,
        boxstyle="round,pad=0.02,rounding_size=0.15",
        linewidth=2, edgecolor=PRIMARY, facecolor="white",
    )
    ax.add_patch(body)

    # Envelope flap (triangle)
    flap = mpatches.Polygon(
        [(1.6, 5.6), (5.0, 3.4), (8.4, 5.6)],
        closed=True, linewidth=2, edgecolor=PRIMARY, facecolor=PRIMARY_LIGHT,
    )
    ax.add_patch(flap)

    # Letter peeking out (behind flap, above body)
    letter = mpatches.FancyBboxPatch(
        (2.4, 2.4), 5.2, 3.2,
        boxstyle="round,pad=0.02,rounding_size=0.05",
        linewidth=0, facecolor="#F9FAFB",
    )
    ax.add_patch(letter)

    # Lines on the letter
    for i, x in enumerate(np.linspace(2.7, 7.3, 6)):
        ax.plot([2.7, x], [5.0 - i * 0.35, 5.0 - i * 0.35],
                color=BORDER, linewidth=2, solid_capstyle="round")

    # Title text
    ax.text(5, 0.85, "IELTS General Training · Writing Task 1",
            ha="center", va="center", fontsize=12, fontweight="bold", color=TEXT)
    ax.text(5, 0.4, "Letter Writing", ha="center", va="center",
            fontsize=10, color=MUTED, style="italic")

    ax.set_xticks([])
    ax.set_yticks([])
    for spine in ax.spines.values():
        spine.set_visible(False)
    return _save(fig, PUBLIC_DIR / f"{slug}.png")


# ── Main ───────────────────────────────────────────────────────────────────
def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--slug", help="Render a single slug instead of all 7")
    args = parser.parse_args()

    selected = [t for t in TASKS if not args.slug or t[0] == args.slug]
    if args.slug and not selected:
        print(f"Unknown slug: {args.slug}")
        print("Valid slugs:")
        for s, *_ in TASKS:
            print(f"  - {s}")
        return 1

    print(f"Rendering {len(selected)} writing task 1 image(s) → {PUBLIC_DIR}\n")
    rendered = 0
    for slug, kind, fetch_url, render_fn_name in selected:
        dest = PUBLIC_DIR / f"{slug}.png"
        print(f"[{kind}] {slug}")
        if fetch_url:
            try:
                if _fetch(fetch_url, dest):
                    rendered += 1
            except Exception as e:
                print(f"  ✗ fetch failed: {e}")
                return 1
        else:
            render_fn = globals()[render_fn_name]
            try:
                render_fn(slug)
                rendered += 1
            except Exception as e:
                print(f"  ✗ render failed: {e}")
                import traceback
                traceback.print_exc()
                return 1

    print(f"\nDone. {rendered}/{len(selected)} new file(s); rest unchanged.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
