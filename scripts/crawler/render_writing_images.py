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
    # Task 2 essays (topic-themed poster covers)
    (
        "task2-opinion-children-screen-time",
        "task2",
        None,
        "render_task2_screen_time",
    ),
    (
        "task2-opinion-university-tuition-free",
        "task2",
        None,
        "render_task2_university_tuition",
    ),
    (
        "task2-discuss-cars-vs-public-transport",
        "task2",
        None,
        "render_task2_cars_vs_transport",
    ),
    (
        "task2-discuss-traditional-vs-modern-buildings",
        "task2",
        None,
        "render_task2_traditional_modern",
    ),
    (
        "task2-problem-solution-traffic-congestion",
        "task2",
        None,
        "render_task2_traffic_congestion",
    ),
    (
        "task2-problem-solution-air-pollution-cities",
        "task2",
        None,
        "render_task2_air_pollution",
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


# ── Task 2 essay covers (no chart — abstract topic-themed posters) ─────────
def _poster_canvas(bg, accent, accent2):
    fig, ax = plt.subplots(figsize=(10, 6.3))
    fig.patch.set_facecolor(bg)
    ax.set_facecolor(bg)
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 6.3)
    ax.set_xticks([]); ax.set_yticks([])
    for s in ax.spines.values():
        s.set_visible(False)
    rng = np.random.default_rng(seed=42)
    for _ in range(18):
        x = rng.uniform(7.5, 9.9)
        y = rng.uniform(4.6, 6.1)
        ax.scatter(x, y, s=rng.uniform(8, 30), c=accent, alpha=0.25,
                   edgecolors="none", zorder=1)
    return fig, ax


def _poster_chrome(ax, title, subtitle, accent):
    ax.text(0.55, 5.85, "IELTS WRITING", fontsize=11, color=accent,
            fontweight="bold", ha="left", va="top", alpha=0.85,
            family="DejaVu Sans")
    ax.text(0.55, 5.4, title, fontsize=22, color="white",
            fontweight="bold", ha="left", va="top", linespacing=1.15,
            family="DejaVu Sans")
    ax.text(0.55, 3.85, subtitle, fontsize=11, color="white",
            ha="left", va="top", alpha=0.75, style="italic",
            family="DejaVu Sans")


def render_task2_screen_time(slug):
    """Children and Screen Time — phone screen motif with abstract UI elements."""
    fig, ax = _poster_canvas("#0F172A", "#60A5FA", "#34D399")
    phone = mpatches.FancyBboxPatch(
        (5.6, 0.4), 2.6, 3.0,
        boxstyle="round,pad=0.0,rounding_size=0.3",
        linewidth=3, edgecolor="#1E293B", facecolor="#1E293B", zorder=3)
    ax.add_patch(phone)
    screen = mpatches.FancyBboxPatch(
        (5.8, 0.7), 2.2, 2.4,
        boxstyle="round,pad=0.0,rounding_size=0.15",
        linewidth=0, facecolor="#020617", zorder=4)
    ax.add_patch(screen)
    heights = [0.5, 0.4, 0.55, 0.4, 0.3, 0.5, 0.35, 0.4]
    y_top = 2.95
    for i, h in enumerate(heights):
        w = h
        ax.add_patch(mpatches.FancyBboxPatch(
            (6.0, y_top - h - 0.08), w, h * 0.85,
            boxstyle="round,pad=0.0,rounding_size=0.04",
            facecolor="#3B82F6" if i % 2 == 0 else "#06B6D4", alpha=0.85, zorder=5))
        y_top -= h
    ax.add_patch(mpatches.Circle((6.9, 1.9), 1.5, facecolor="#3B82F6",
                                alpha=0.15, edgecolor="none", zorder=2))
    head = mpatches.Circle((1.7, 1.5), 0.4, facecolor="#FBBF24", zorder=5)
    ax.add_patch(head)
    body = mpatches.FancyBboxPatch(
        (1.3, 0.2), 0.8, 1.0,
        boxstyle="round,pad=0.0,rounding_size=0.3",
        facecolor="#FBBF24", zorder=5)
    ax.add_patch(body)
    ax.annotate("", xy=(5.6, 1.5), xytext=(2.1, 1.5),
                arrowprops=dict(arrowstyle="->", color="#60A5FA",
                                lw=2, alpha=0.7))
    _poster_chrome(ax, "Children &\nScreen Time", "An opinion essay · 250 words", "#60A5FA")
    return _save(fig, PUBLIC_DIR / f"{slug}.png")


def render_task2_university_tuition(slug):
    """Free University Tuition — graduation cap + book stack."""
    fig, ax = _poster_canvas("#1E1B4B", "#FBBF24", "#A78BFA")
    book_colors = ["#7C3AED", "#6D28D9", "#5B21B6", "#4C1D95"]
    for i, c in enumerate(book_colors):
        bw = 2.4 - i * 0.1
        ax.add_patch(mpatches.FancyBboxPatch(
            (1.0 + i * 0.05, 0.4 + i * 0.18), bw, 0.22,
            boxstyle="round,pad=0.0,rounding_size=0.05",
            facecolor=c, edgecolor="white", linewidth=1.2, zorder=3))
        ax.add_patch(mpatches.FancyBboxPatch(
            (1.2 + i * 0.05, 0.6 + i * 0.18), bw * 0.7, 0.04,
            facecolor="white", alpha=0.7, zorder=4))
        ax.add_patch(mpatches.FancyBboxPatch(
            (1.2 + i * 0.05, 0.76 + i * 0.18), bw * 0.7, 0.04,
            facecolor="white", alpha=0.5, zorder=4))
    cap_x, cap_y = 6.5, 2.4
    mortar = mpatches.Polygon(
        [(cap_x, cap_y), (cap_x + 2.0, cap_y),
         (cap_x + 1.5, cap_y - 0.6), (cap_x + 0.5, cap_y - 0.6)],
        closed=True, facecolor="#1E1B4B", edgecolor="#FBBF24", linewidth=2.5, zorder=5)
    ax.add_patch(mortar)
    ax.add_patch(mpatches.Polygon(
        [(cap_x + 0.7, cap_y + 0.05), (cap_x + 1.3, cap_y + 0.05),
         (cap_x + 1.3, cap_y + 0.4), (cap_x + 0.7, cap_y + 0.4)],
        closed=True, facecolor="#1E1B4B", edgecolor="#FBBF24", linewidth=2, zorder=6))
    ax.plot([cap_x + 1.0, cap_x + 1.3], [cap_y + 0.4, cap_y + 0.7],
            color="#FBBF24", lw=2, zorder=6)
    ax.scatter([cap_x + 1.3], [cap_y + 0.7], s=80, c="#FBBF24", zorder=6)
    coin = mpatches.Circle((8.4, 1.0), 0.5, facecolor="#FBBF24",
                           edgecolor="#1E1B4B", linewidth=2.5, zorder=5)
    ax.add_patch(coin)
    ax.text(8.4, 1.0, "$", fontsize=24, color="#1E1B4B",
            ha="center", va="center", fontweight="bold", zorder=6)
    _poster_chrome(ax, "Free University\nTuition", "Discuss both views · 250 words", "#FBBF24")
    return _save(fig, PUBLIC_DIR / f"{slug}.png")


def render_task2_cars_vs_transport(slug):
    """Cars vs Public Transport — car and bus silhouettes on a road."""
    fig, ax = _poster_canvas("#0C4A6E", "#38BDF8", "#FBBF24")
    road = mpatches.Polygon(
        [(0, 0), (10, 0), (7, 2.0), (3, 2.0)],
        closed=True, facecolor="#1E293B", edgecolor="#475569", linewidth=2, zorder=2)
    ax.add_patch(road)
    for y in [0.4, 0.9, 1.4]:
        ax.plot([3.5, 6.5], [y, y], color="#FBBF24", lw=3, linestyle=(0, (4, 6)),
                zorder=3)
    bus = mpatches.FancyBboxPatch(
        (1.0, 1.4), 2.2, 1.3,
        boxstyle="round,pad=0.0,rounding_size=0.2",
        facecolor="#FBBF24", edgecolor="#1E293B", linewidth=2, zorder=4)
    ax.add_patch(bus)
    for i in range(3):
        ax.add_patch(mpatches.Rectangle(
            (1.15 + i * 0.65, 1.8), 0.5, 0.35,
            facecolor="#0EA5E9", edgecolor="#1E293B", linewidth=1.5, zorder=5))
    ax.add_patch(mpatches.Circle((1.45, 1.4), 0.15, facecolor="#0F172A", zorder=5))
    ax.add_patch(mpatches.Circle((2.75, 1.4), 0.15, facecolor="#0F172A", zorder=5))
    ax.text(2.1, 2.5, "BUS", fontsize=10, color="#0F172A",
            fontweight="bold", ha="center", zorder=5)
    car_body = mpatches.FancyBboxPatch(
        (5.5, 1.3), 2.2, 0.8,
        boxstyle="round,pad=0.0,rounding_size=0.15",
        facecolor="#EF4444", edgecolor="#1E293B", linewidth=2, zorder=4)
    ax.add_patch(car_body)
    ax.add_patch(mpatches.Polygon(
        [(5.8, 2.1), (6.2, 2.5), (7.4, 2.5), (7.8, 2.1)],
        closed=True, facecolor="#EF4444", edgecolor="#1E293B", linewidth=2, zorder=4))
    ax.add_patch(mpatches.Rectangle(
        (6.0, 2.2), 1.2, 0.25,
        facecolor="#0EA5E9", edgecolor="#1E293B", linewidth=1, zorder=5))
    ax.add_patch(mpatches.Circle((5.95, 1.3), 0.18, facecolor="#0F172A", zorder=5))
    ax.add_patch(mpatches.Circle((7.25, 1.3), 0.18, facecolor="#0F172A", zorder=5))
    ax.text(6.6, 2.85, "CAR", fontsize=10, color="white",
            fontweight="bold", ha="center", zorder=5)
    _poster_chrome(ax, "Cars vs\nPublic Transport", "Discuss both views · 250 words", "#FBBF24")
    return _save(fig, PUBLIC_DIR / f"{slug}.png")


def render_task2_traditional_modern(slug):
    """Traditional vs Modern Buildings — old stone building + modern skyscraper."""
    fig, ax = _poster_canvas("#0F766E", "#FCD34D", "#7DD3FC")
    base = mpatches.Rectangle((0.5, 0.3), 3.0, 1.8,
                              facecolor="#FCD34D", edgecolor="#0F172A", linewidth=2, zorder=3)
    ax.add_patch(base)
    ax.add_patch(mpatches.Polygon(
        [(0.5, 2.1), (2.0, 3.0), (3.5, 2.1)],
        closed=True, facecolor="#F59E0B", edgecolor="#0F172A", linewidth=2, zorder=4))
    for x in [0.85, 1.65, 2.45, 3.05]:
        ax.add_patch(mpatches.Rectangle(
            (x, 0.4), 0.25, 1.6,
            facecolor="#FDE68A", edgecolor="#0F172A", linewidth=1.5, zorder=4))
    ax.text(2.0, 0.1, "TRADITIONAL", fontsize=9, color="#FCD34D",
            ha="center", fontweight="bold", zorder=5)
    glass = mpatches.FancyBboxPatch(
        (5.0, 0.3), 2.5, 2.8,
        boxstyle="round,pad=0.0,rounding_size=0.1",
        facecolor="#7DD3FC", edgecolor="#0F172A", linewidth=2, zorder=3)
    ax.add_patch(glass)
    for r in range(6):
        for c in range(3):
            ax.add_patch(mpatches.Rectangle(
                (5.15 + c * 0.75, 0.5 + r * 0.4), 0.6, 0.3,
                facecolor=("#67E8F9" if (r + c) % 2 == 0 else "#0891B2"),
                edgecolor="#0F172A", linewidth=0.8, zorder=4))
    ax.plot([6.25, 6.25], [3.1, 3.5], color="#7DD3FC", lw=3, zorder=4)
    ax.scatter([6.25], [3.6], s=80, c="#FCD34D", zorder=5)
    ax.text(6.25, 0.1, "MODERN", fontsize=9, color="#7DD3FC",
            ha="center", fontweight="bold", zorder=5)
    ax.add_patch(mpatches.Circle((5.5, 3.6), 0.5,
                                facecolor="#FCD34D", alpha=0.3, edgecolor="none", zorder=1))
    _poster_chrome(ax, "Traditional vs\nModern Buildings", "Discuss both views · 250 words", "#FCD34D")
    return _save(fig, PUBLIC_DIR / f"{slug}.png")


def render_task2_traffic_congestion(slug):
    """Solving Traffic Congestion — stack of cars and a clock motif."""
    fig, ax = _poster_canvas("#7F1D1D", "#FCA5A5", "#FCD34D")
    car_data = [
        (0.5, 0.5, 0.9, 0.8, "#EF4444"),
        (1.6, 0.4, 0.95, 0.95, "#F97316"),
        (2.7, 0.3, 1.0, 1.1, "#EAB308"),
        (3.9, 0.2, 1.05, 1.25, "#22C55E"),
        (5.1, 0.1, 1.1, 1.4, "#06B6D4"),
    ]
    for x, y, w, h, c in car_data:
        ax.add_patch(mpatches.FancyBboxPatch(
            (x, y), w, h,
            boxstyle="round,pad=0.0,rounding_size=0.1",
            facecolor=c, edgecolor="#0F172A", linewidth=1.8, zorder=3))
        ax.add_patch(mpatches.Polygon(
            [(x + 0.2, y + h * 0.65), (x + 0.4, y + h * 0.95),
             (x + w * 0.7, y + h * 0.95), (x + w * 0.85, y + h * 0.65)],
            closed=True, facecolor="#1E293B", alpha=0.7, zorder=4))
        ax.add_patch(mpatches.Circle((x + 0.2, y), 0.1, facecolor="#0F172A", zorder=5))
        ax.add_patch(mpatches.Circle((x + w - 0.2, y), 0.1, facecolor="#0F172A", zorder=5))
        ax.add_patch(mpatches.Rectangle(
            (x + w - 0.05, y + 0.2), 0.05, 0.15, facecolor="#FCA5A5", zorder=5))
    cx, cy, r = 7.8, 2.4, 0.7
    ax.add_patch(mpatches.Circle((cx, cy), r, facecolor="#FCD34D", zorder=4))
    ax.add_patch(mpatches.Circle((cx, cy), r - 0.1, facecolor="none",
                                edgecolor="#7F1D1D", linewidth=2, zorder=4))
    ax.plot([cx, cx], [cy, cy + 0.45], color="#7F1D1D", lw=3, zorder=5)
    ax.plot([cx, cx + 0.4], [cy, cy], color="#7F1D1D", lw=2, zorder=5)
    ax.scatter([cx], [cy], s=20, c="#7F1D1D", zorder=6)
    _poster_chrome(ax, "Solving Traffic\nCongestion", "Problem / solution essay · 250 words", "#FCD34D")
    return _save(fig, PUBLIC_DIR / f"{slug}.png")


def render_task2_air_pollution(slug):
    """Air Pollution in Cities — city skyline with smog."""
    fig, ax = _poster_canvas("#374151", "#9CA3AF", "#FBBF24")
    buildings = [
        (0.5, 0.2, 1.2, 1.8, "#4B5563"),
        (1.6, 0.2, 0.9, 2.3, "#374151"),
        (2.4, 0.2, 1.1, 1.5, "#4B5563"),
        (3.4, 0.2, 0.8, 2.0, "#374151"),
        (4.1, 0.2, 1.2, 1.4, "#4B5563"),
        (5.2, 0.2, 1.0, 2.5, "#374151"),
        (6.1, 0.2, 0.9, 1.8, "#4B5563"),
        (6.9, 0.2, 1.1, 2.1, "#374151"),
        (7.9, 0.2, 0.8, 1.6, "#4B5563"),
        (8.6, 0.2, 1.1, 2.2, "#374151"),
    ]
    for x, y, w, h, c in buildings:
        ax.add_patch(mpatches.Rectangle(
            (x, y), w, h, facecolor=c, edgecolor="#1F2937", linewidth=1.2, zorder=3))
        for r in range(int(h // 0.4)):
            for cc in range(int(w // 0.3)):
                win_color = "#FBBF24" if (r + cc) % 3 == 0 else "#9CA3AF"
                ax.add_patch(mpatches.Rectangle(
                    (x + 0.1 + cc * 0.3, y + 0.2 + r * 0.4), 0.15, 0.2,
                    facecolor=win_color, alpha=0.6, zorder=4))
    for cx, cy, r in [(1.5, 3.0, 0.4), (3.0, 3.3, 0.55), (5.0, 3.2, 0.5),
                     (6.5, 3.5, 0.35), (8.0, 3.1, 0.45)]:
        ax.add_patch(mpatches.Circle((cx, cy), r, facecolor="#6B7280",
                                    alpha=0.4, edgecolor="none", zorder=5))
    ax.add_patch(mpatches.Circle((8.2, 3.7), 0.35, facecolor="#FCD34D",
                                alpha=0.5, edgecolor="none", zorder=2))
    ax.add_patch(mpatches.Rectangle((4.5, 2.6), 0.3, 0.5, facecolor="#374151", zorder=3))
    ax.add_patch(mpatches.Polygon(
        [(4.4, 3.1), (4.6, 3.1), (4.5, 3.0)],
        facecolor="#6B7280", alpha=0.6, zorder=4))
    _poster_chrome(ax, "Air Pollution\nin Cities", "Problem / solution essay · 250 words", "#FBBF24")
    return _save(fig, PUBLIC_DIR / f"{slug}.png")


# ── Main ───────────────────────────────────────────────────────────────────
def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--slug", help="Render a single slug instead of all 13")
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
