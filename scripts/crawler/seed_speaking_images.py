#!/usr/bin/env python3
"""Generate cover images for speaking tasks and upload to Cloudinary."""
import hashlib, os, re, sys, time
from pathlib import Path
import requests, numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

SCRIPT_DIR = Path(__file__).resolve().parent
MICRO_ROOT = SCRIPT_DIR.parents[1]
WORKSPACE_ROOT = MICRO_ROOT.parent
PUBLIC_DIR = WORKSPACE_ROOT / "langfens-fe-app" / "public" / "writing-images"
SEEDS_DIR = MICRO_ROOT / "deploy" / "seeds"
SQL_PATH = SEEDS_DIR / "seed_speaking_exams_image_urls.sql"
ENV_PATH = MICRO_ROOT / "deploy" / "envs" / "speaking.env"

IMAGES = [
    # (slug, public_id)
    ("speaking-part1-introduce-yourself",        "ielts/speaking/part1-introduce-yourself"),
    ("speaking-part1-family-and-friends",         "ielts/speaking/part1-family-and-friends"),
    ("speaking-part1-hometown",                  "ielts/speaking/part1-hometown"),
    ("speaking-part1-hobbies",                   "ielts/speaking/part1-hobbies"),
    ("speaking-part1-work-or-study",             "ielts/speaking/part1-work-or-study"),
    ("speaking-part1-daily-routine",             "ielts/speaking/part1-daily-routine"),
    ("speaking-part2-cue-card-describe-friend",  "ielts/speaking/part2-describe-friend"),
    ("speaking-part2-cue-card-describe-place",   "ielts/speaking/part2-describe-place"),
    ("speaking-part2-cue-card-describe-object",  "ielts/speaking/part2-describe-object"),
    ("speaking-part2-cue-card-describe-event",   "ielts/speaking/part2-describe-event"),
    ("speaking-part3-discuss-technology",        "ielts/speaking/part3-discuss-technology"),
    ("speaking-part3-discuss-environment",       "ielts/speaking/part3-discuss-environment"),
    ("speaking-part3-discuss-education",         "ielts/speaking/part3-discuss-education"),
    ("speaking-part3-discuss-work-and-career",   "ielts/speaking/part3-discuss-work"),
    ("speaking-part3-discuss-tradition",        "ielts/speaking/part3-discuss-tradition"),
]

PRIMARY="#2563EB"; ACCENT="#06D6A0"; TEXT="#111827"; MUTED="#6B7280"; BORDER="#E5E7EB"

def _save(fig, dest): dest.parent.mkdir(parents=True, exist_ok=True); fig.savefig(dest, dpi=150, bbox_inches="tight", facecolor="white"); plt.close(fig)

def _canvas(bg, accent, accent2):
    fig, ax = plt.subplots(figsize=(10, 6.3))
    fig.patch.set_facecolor(bg); ax.set_facecolor(bg)
    ax.set_xlim(0, 10); ax.set_ylim(0, 6.3); ax.set_xticks([]); ax.set_yticks([])
    for s in ax.spines.values(): s.set_visible(False)
    rng = np.random.default_rng(seed=42)
    for _ in range(18):
        x = rng.uniform(7.5, 9.9); y = rng.uniform(4.6, 6.1)
        ax.scatter(x, y, s=rng.uniform(8, 30), c=accent, alpha=0.25, edgecolors="none", zorder=1)
    return fig, ax

def _chrome(ax, title, subtitle, accent):
    ax.text(0.55, 5.85, "IELTS SPEAKING", fontsize=11, color=accent, fontweight="bold",
            ha="left", va="top", alpha=0.85, family="DejaVu Sans")
    ax.text(0.55, 5.4, title, fontsize=22, color="white", fontweight="bold",
            ha="left", va="top", linespacing=1.15, family="DejaVu Sans")
    ax.text(0.55, 3.85, subtitle, fontsize=11, color="white", ha="left", va="top",
            alpha=0.75, style="italic", family="DejaVu Sans")

# ---- Part 1: Introduce Yourself ----
def render_intro(slug, pubid):
    fig, ax = _canvas("#0F172A", "#60A5FA", "#34D399")
    # Person silhouette
    head = mpatches.Circle((3, 3.0), 0.6, facecolor="#FBBF24", zorder=5)
    body = mpatches.FancyBboxPatch((2.3, 0.6), 1.4, 1.6, boxstyle="round,pad=0.0,rounding_size=0.4",
                                  facecolor="#FBBF24", zorder=5)
    ax.add_patch(head); ax.add_patch(body)
    # Speech bubble
    bub = mpatches.FancyBboxPatch((5.5, 2.0), 3.5, 1.6, boxstyle="round,pad=0.0,rounding_size=0.4",
                                  facecolor="white", edgecolor="#1E293B", linewidth=3, zorder=5)
    ax.add_patch(bub)
    # Bubble tail
    ax.add_patch(mpatches.Polygon([(5.5, 2.4), (4.7, 2.0), (5.5, 1.6)],
                                  closed=True, facecolor="white", edgecolor="#1E293B",
                                  linewidth=3, zorder=5))
    ax.add_patch(mpatches.Polygon([(5.5, 2.4), (4.7, 2.0), (5.5, 1.6)],
                                  closed=True, facecolor="white", zorder=6, linewidth=0))
    for i, ln in enumerate(["Hi! I'm from", "Hanoi, Vietnam."]):
        ax.text(7.25, 3.2 - i * 0.5, ln, fontsize=13, color="#0F172A", ha="center", va="center", family="DejaVu Sans")
    # Stars/sparkles
    for (sx, sy, r) in [(6.0, 4.6, 0.08), (7.2, 4.4, 0.06), (8.0, 4.7, 0.07), (6.5, 4.9, 0.05)]:
        ax.scatter([sx], [sy], s=r*800, c="#FBBF24", zorder=4)
    _chrome(ax, "Introduce\nYourself", "Part 1 · Personal questions", "#60A5FA")
    return _save(fig, PUBLIC_DIR / f"{slug}.png")

# ---- Part 1: Family and Friends ----
def render_family(slug, pubid):
    fig, ax = _canvas("#1E3A8A", "#93C5FD", "#FBBF24")
    # Three figures
    for (x, y, c) in [(2.0, 0.6, "#F472B6"), (4.0, 0.6, "#FBBF24"), (6.0, 0.6, "#34D399")]:
        head = mpatches.Circle((x, 2.5), 0.5, facecolor=c, zorder=5)
        body = mpatches.FancyBboxPatch((x-0.5, 0.6), 1.0, 1.4, boxstyle="round,pad=0.0,rounding_size=0.3",
                                      facecolor=c, zorder=5)
        ax.add_patch(head); ax.add_patch(body)
    # Hearts above
    for (hx, hy) in [(3.0, 3.3), (5.0, 3.3), (4.0, 3.6)]:
        ax.scatter([hx], [hy], s=300, marker="$\u2665$", c="#EF4444", zorder=4)
    _chrome(ax, "Family &\nFriends", "Part 1 · Personal questions", "#FBBF24")
    return _save(fig, PUBLIC_DIR / f"{slug}.png")

# ---- Part 1: Hometown ----
def render_hometown(slug, pubid):
    fig, ax = _canvas("#0F766E", "#5EEAD4", "#FBBF24")
    # Skyline silhouette
    for (x, y, w, h) in [(0.5, 0.3, 1.2, 1.8), (1.6, 0.3, 0.9, 2.4), (2.4, 0.3, 1.1, 1.5),
                         (3.4, 0.3, 0.8, 2.0), (4.1, 0.3, 1.2, 1.3), (5.2, 0.3, 1.0, 2.6),
                         (6.1, 0.3, 0.9, 1.8), (6.9, 0.3, 1.1, 2.2), (7.9, 0.3, 0.8, 1.6),
                         (8.6, 0.3, 1.1, 2.3)]:
        ax.add_patch(mpatches.Rectangle((x, y), w, h, facecolor="#065F46", edgecolor="#134E4A", linewidth=1.5, zorder=3))
    # Pin
    ax.scatter([5.0], [1.8], s=600, marker="$\u25cf$", c="#EF4444", edgecolor="white", linewidth=2, zorder=5)
    # Sun
    ax.add_patch(mpatches.Circle((8.2, 3.0), 0.5, facecolor="#FBBF24", alpha=0.9, zorder=2))
    _chrome(ax, "My Hometown", "Part 1 · Personal questions", "#FBBF24")
    return _save(fig, PUBLIC_DIR / f"{slug}.png")

# ---- Part 1: Hobbies ----
def render_hobbies(slug, pubid):
    fig, ax = _canvas("#7C3AED", "#C4B5FD", "#FBBF24")
    # Music note
    ax.add_patch(mpatches.Circle((2.0, 1.0), 0.4, facecolor="white", zorder=4))
    ax.plot([2.4, 2.4], [1.0, 2.4], color="white", lw=4, zorder=4)
    ax.add_patch(mpatches.Circle((2.0, 1.8), 0.3, facecolor="white", zorder=4))
    ax.plot([2.3, 2.9], [2.4, 2.6], color="white", lw=4, zorder=4)
    # Book
    ax.add_patch(mpatches.FancyBboxPatch((3.5, 0.6), 1.2, 1.4, boxstyle="round,pad=0.0,rounding_size=0.1",
                                       facecolor="white", edgecolor="#7C3AED", linewidth=3, zorder=4))
    ax.plot([3.5, 4.7], [1.3, 1.3], color="#7C3AED", lw=2, zorder=5)
    # Ball
    ax.add_patch(mpatches.Circle((6.0, 1.0), 0.5, facecolor="#FBBF24", edgecolor="white", linewidth=3, zorder=4))
    ax.add_patch(mpatches.Polygon([(6.0, 1.0), (6.0, 1.5)], closed=True, facecolor="#1F2937", zorder=5))
    # Palette
    ax.add_patch(mpatches.Circle((7.5, 1.0), 0.5, facecolor="white", edgecolor="#1F2937", linewidth=3, zorder=4))
    for i, c in enumerate(["#EF4444", "#FBBF24", "#10B981", "#3B82F6"]):
        ax.add_patch(mpatches.Wedge((7.5, 1.0), 0.4, 90 + i*45, 90 + (i+1)*45, facecolor=c, zorder=5))
    _chrome(ax, "Hobbies &\nInterests", "Part 1 · Personal questions", "#FBBF24")
    return _save(fig, PUBLIC_DIR / f"{slug}.png")

# ---- Part 1: Work or Study ----
def render_work(slug, pubid):
    fig, ax = _canvas("#374151", "#9CA3AF", "#FBBF24")
    # Briefcase
    ax.add_patch(mpatches.FancyBboxPatch((2.0, 0.6), 2.0, 1.4, boxstyle="round,pad=0.0,rounding_size=0.15",
                                       facecolor="#92400E", edgecolor="#1F2937", linewidth=3, zorder=4))
    ax.add_patch(mpatches.FancyBboxPatch((2.4, 1.7), 1.2, 0.4, boxstyle="round,pad=0.0,rounding_size=0.1",
                                       facecolor="#1F2937", zorder=5))
    # Graduation cap
    ax.add_patch(mpatches.Polygon([(6.0, 2.2), (8.0, 2.2), (7.0, 1.5)], closed=True,
                                  facecolor="#1F2937", edgecolor="#FBBF24", linewidth=2.5, zorder=4))
    ax.add_patch(mpatches.Polygon([(6.6, 2.3), (7.4, 2.3), (7.4, 2.7), (6.6, 2.7)],
                                  closed=True, facecolor="#1F2937", edgecolor="#FBBF24", linewidth=2, zorder=5))
    ax.plot([7.0, 7.0], [2.7, 3.0], color="#FBBF24", lw=2, zorder=5)
    ax.scatter([7.0], [3.1], s=80, c="#FBBF24", zorder=5)
    _chrome(ax, "Work or Study", "Part 1 · Personal questions", "#FBBF24")
    return _save(fig, PUBLIC_DIR / f"{slug}.png")

# ---- Part 1: Daily Routine ----
def render_routine(slug, pubid):
    fig, ax = _canvas("#065F46", "#5EEAD4", "#FBBF24")
    # Clock
    cx, cy, r = 3.5, 1.5, 0.8
    ax.add_patch(mpatches.Circle((cx, cy), r, facecolor="white", edgecolor="#1F2937", linewidth=4, zorder=4))
    for ang in range(0, 360, 30):
        x1 = cx + r*0.85*np.cos(np.radians(ang-90)); y1 = cy + r*0.85*np.sin(np.radians(ang-90))
        x2 = cx + r*0.95*np.cos(np.radians(ang-90)); y2 = cy + r*0.95*np.sin(np.radians(ang-90))
        ax.plot([x1, x2], [y1, y2], color="#1F2937", lw=2, zorder=5)
    ax.plot([cx, cx], [cy, cy + 0.5], color="#1F2937", lw=4, zorder=6)
    ax.plot([cx, cx + 0.45], [cy, cy], color="#1F2937", lw=3, zorder=6)
    ax.scatter([cx], [cy], s=40, c="#1F2937", zorder=7)
    # Coffee cup
    ax.add_patch(mpatches.FancyBboxPatch((6.0, 0.6), 1.2, 1.4, boxstyle="round,pad=0.0,rounding_size=0.1",
                                       facecolor="white", edgecolor="#1F2937", linewidth=3, zorder=4))
    ax.add_patch(mpatches.Ellipse((6.6, 2.0), 1.0, 0.2, facecolor="#92400E", zorder=5))
    # Steam
    for sx, sy in [(6.3, 2.5), (6.6, 2.7), (6.9, 2.5)]:
        ax.plot([sx, sx + 0.05], [sy, sy + 0.3], color="white", lw=3, alpha=0.6, zorder=4)
    _chrome(ax, "Daily Routine", "Part 1 · Personal questions", "#FBBF24")
    return _save(fig, PUBLIC_DIR / f"{slug}.png")

# ---- Part 2: Cue card - Describe a Friend ----
def render_describe_friend(slug, pubid):
    fig, ax = _canvas("#831843", "#F9A8D4", "#FBBF24")
    # Person portrait
    head = mpatches.Circle((3.0, 1.8), 0.6, facecolor="#FBBF24", zorder=5)
    body = mpatches.FancyBboxPatch((2.2, 0.4), 1.6, 1.0, boxstyle="round,pad=0.0,rounding_size=0.3",
                                  facecolor="#7C3AED", zorder=5)
    ax.add_patch(head); ax.add_patch(body)
    # Smile
    ax.add_patch(mpatches.Wedge((3.0, 1.7), 0.2, 200, 340, facecolor="none", edgecolor="#1F2937", linewidth=3, zorder=6))
    # Eyes
    ax.scatter([2.85], [1.95], s=40, c="#1F2937", zorder=6)
    ax.scatter([3.15], [1.95], s=40, c="#1F2937", zorder=6)
    # Cue card
    ax.add_patch(mpatches.FancyBboxPatch((5.5, 0.6), 3.0, 2.0, boxstyle="round,pad=0.0,rounding_size=0.15",
                                       facecolor="white", edgecolor="#831843", linewidth=3, zorder=4))
    ax.text(7.0, 2.2, "CUE CARD", fontsize=10, fontweight="bold", color="#831843", ha="center", zorder=5)
    ax.text(7.0, 1.7, "Describe a friend", fontsize=12, fontweight="bold", color="#1F2937", ha="center", zorder=5)
    ax.text(7.0, 1.3, "who is important", fontsize=10, color="#374151", ha="center", zorder=5)
    ax.text(7.0, 1.0, "to you.", fontsize=10, color="#374151", ha="center", zorder=5)
    _chrome(ax, "Describe a\nFriend", "Part 2 · Cue card", "#FBBF24")
    return _save(fig, PUBLIC_DIR / f"{slug}.png")

# ---- Part 2: Describe a Place ----
def render_describe_place(slug, pubid):
    fig, ax = _canvas("#0C4A6E", "#38BDF8", "#FBBF24")
    # Mountain
    ax.add_patch(mpatches.Polygon([(0.5, 0.3), (2.5, 3.0), (4.5, 0.3)], closed=True,
                                  facecolor="#1E40AF", edgecolor="#0F172A", linewidth=2, zorder=3))
    ax.add_patch(mpatches.Polygon([(3.0, 0.3), (5.0, 2.4), (7.0, 0.3)], closed=True,
                                  facecolor="#1E3A8A", edgecolor="#0F172A", linewidth=2, zorder=3))
    # Sun
    ax.add_patch(mpatches.Circle((7.5, 2.2), 0.5, facecolor="#FBBF24", alpha=0.9, zorder=4))
    # Cue card
    ax.add_patch(mpatches.FancyBboxPatch((5.5, 0.4), 3.0, 1.4, boxstyle="round,pad=0.0,rounding_size=0.15",
                                       facecolor="white", edgecolor="#0C4A6E", linewidth=3, zorder=4))
    ax.text(7.0, 1.5, "CUE CARD", fontsize=10, fontweight="bold", color="#0C4A6E", ha="center", zorder=5)
    ax.text(7.0, 1.05, "Describe a place", fontsize=11, fontweight="bold", color="#1F2937", ha="center", zorder=5)
    ax.text(7.0, 0.7, "you'd love to visit", fontsize=9, color="#374151", ha="center", zorder=5)
    _chrome(ax, "Describe a\nPlace", "Part 2 · Cue card", "#FBBF24")
    return _save(fig, PUBLIC_DIR / f"{slug}.png")

# ---- Part 2: Describe an Object ----
def render_describe_object(slug, pubid):
    fig, ax = _canvas("#581C87", "#C4B5FD", "#FBBF24")
    # Gift box
    ax.add_patch(mpatches.FancyBboxPatch((2.0, 0.3), 1.6, 1.4, boxstyle="round,pad=0.0,rounding_size=0.1",
                                       facecolor="#7C3AED", edgecolor="white", linewidth=3, zorder=4))
    ax.add_patch(mpatches.Rectangle((2.0, 1.3), 1.6, 0.3, facecolor="#FBBF24", zorder=5))
    ax.add_patch(mpatches.Rectangle((2.6, 0.3), 0.4, 1.7, facecolor="#FBBF24", zorder=5))
    # Cue card
    ax.add_patch(mpatches.FancyBboxPatch((5.5, 0.4), 3.0, 1.4, boxstyle="round,pad=0.0,rounding_size=0.15",
                                       facecolor="white", edgecolor="#581C87", linewidth=3, zorder=4))
    ax.text(7.0, 1.5, "CUE CARD", fontsize=10, fontweight="bold", color="#581C87", ha="center", zorder=5)
    ax.text(7.0, 1.05, "Describe an object", fontsize=11, fontweight="bold", color="#1F2937", ha="center", zorder=5)
    ax.text(7.0, 0.7, "that's important to you", fontsize=9, color="#374151", ha="center", zorder=5)
    _chrome(ax, "Describe an\nObject", "Part 2 · Cue card", "#FBBF24")
    return _save(fig, PUBLIC_DIR / f"{slug}.png")

# ---- Part 2: Describe an Event ----
def render_describe_event(slug, pubid):
    fig, ax = _canvas("#9A3412", "#FDBA74", "#FBBF24")
    # Calendar with date
    ax.add_patch(mpatches.FancyBboxPatch((1.5, 0.3), 1.6, 1.6, boxstyle="round,pad=0.0,rounding_size=0.1",
                                       facecolor="white", edgecolor="#9A3412", linewidth=3, zorder=4))
    ax.add_patch(mpatches.Rectangle((1.5, 1.5), 1.6, 0.4, facecolor="#9A3412", zorder=5))
    ax.text(2.3, 1.0, "15", fontsize=22, fontweight="bold", color="#9A3412", ha="center", zorder=6)
    # Confetti
    for cx, cy, c in [(0.8, 2.4, "#FBBF24"), (3.4, 2.6, "#EF4444"), (0.6, 1.6, "#10B981"),
                      (3.6, 1.4, "#3B82F6")]:
        ax.add_patch(mpatches.Rectangle((cx, cy), 0.1, 0.2, facecolor=c, zorder=4, angle=20))
    # Cue card
    ax.add_patch(mpatches.FancyBboxPatch((5.5, 0.4), 3.0, 1.4, boxstyle="round,pad=0.0,rounding_size=0.15",
                                       facecolor="white", edgecolor="#9A3412", linewidth=3, zorder=4))
    ax.text(7.0, 1.5, "CUE CARD", fontsize=10, fontweight="bold", color="#9A3412", ha="center", zorder=5)
    ax.text(7.0, 1.05, "Describe an event", fontsize=11, fontweight="bold", color="#1F2937", ha="center", zorder=5)
    ax.text(7.0, 0.7, "that was important", fontsize=9, color="#374151", ha="center", zorder=5)
    _chrome(ax, "Describe an\nEvent", "Part 2 · Cue card", "#FBBF24")
    return _save(fig, PUBLIC_DIR / f"{slug}.png")

# ---- Part 3: Discuss Technology ----
def render_discuss_tech(slug, pubid):
    fig, ax = _canvas("#0F172A", "#60A5FA", "#34D399")
    # Phone + circuit
    phone = mpatches.FancyBboxPatch((2.0, 0.5), 1.5, 2.4, boxstyle="round,pad=0.0,rounding_size=0.15",
                                    facecolor="#1E293B", edgecolor="#60A5FA", linewidth=3, zorder=4)
    ax.add_patch(phone)
    ax.add_patch(mpatches.FancyBboxPatch((2.15, 0.8), 1.2, 1.8, boxstyle="round,pad=0.0,rounding_size=0.08",
                                       facecolor="#020617", zorder=5))
    for i, h in enumerate([0.3, 0.25, 0.4, 0.3, 0.5]):
        ax.add_patch(mpatches.FancyBboxPatch((2.3, 0.95 + i*0.3), 0.5*0.8, h*0.7,
                                            boxstyle="round,pad=0.0,rounding_size=0.04",
                                            facecolor="#3B82F6" if i%2==0 else "#06B6D4", zorder=6))
    # Wifi waves
    for r, alpha in [(0.4, 0.9), (0.8, 0.6), (1.2, 0.3)]:
        ax.add_patch(mpatches.Wedge((6.0, 2.0), r, 30, 150, facecolor="none", edgecolor="#60A5FA",
                                    linewidth=3, alpha=alpha, zorder=4))
    # Chat bubble
    ax.add_patch(mpatches.FancyBboxPatch((5.5, 0.4), 2.5, 0.9, boxstyle="round,pad=0.0,rounding_size=0.2",
                                       facecolor="white", edgecolor="#1E293B", linewidth=2, zorder=5))
    ax.text(6.75, 0.85, "Discuss…", fontsize=11, fontweight="bold", color="#1E293B", ha="center", zorder=6)
    _chrome(ax, "Technology", "Part 3 · Discussion", "#60A5FA")
    return _save(fig, PUBLIC_DIR / f"{slug}.png")

# ---- Part 3: Environment ----
def render_discuss_env(slug, pubid):
    fig, ax = _canvas("#064E3B", "#5EEAD4", "#FBBF24")
    # Tree
    ax.add_patch(mpatches.Rectangle((1.5, 0.3), 0.2, 1.0, facecolor="#92400E", zorder=3))
    for r, c in [(1.0, "#10B981"), (0.85, "#34D399"), (0.7, "#6EE7B7")]:
        ax.add_patch(mpatches.Circle((1.6, 1.5), r, facecolor=c, zorder=4))
    # Wind turbine
    ax.add_patch(mpatches.Rectangle((3.5, 0.3), 0.1, 2.0, facecolor="#9CA3AF", zorder=3))
    for ang_deg, c in zip([0, 120, 240], ["#FBBF24", "#F59E0B", "#FBBF24"]):
        # Compute rotated blade endpoints
        a = np.radians(ang_deg)
        x0, y0 = 3.55, 2.3
        x1, y1 = x0 + 0.7 * np.cos(a), y0 + 0.7 * np.sin(a)
        ax.plot([x0, x1], [y0, y1], color=c, lw=8, solid_capstyle="round", zorder=4)
    ax.scatter([3.55], [2.3], s=40, c="#1F2937", zorder=5)
    # Sun
    ax.add_patch(mpatches.Circle((7.5, 2.0), 0.6, facecolor="#FBBF24", zorder=4))
    # Leaf
    ax.add_patch(mpatches.Ellipse((6.0, 1.0), 0.4, 0.2, facecolor="#10B981", angle=30, zorder=4))
    _chrome(ax, "Environment", "Part 3 · Discussion", "#5EEAD4")
    return _save(fig, PUBLIC_DIR / f"{slug}.png")

# ---- Part 3: Education ----
def render_discuss_edu(slug, pubid):
    fig, ax = _canvas("#7C2D12", "#FDBA74", "#FBBF24")
    # Books
    for (x, c) in [(1.0, "#7C3AED"), (1.6, "#DC2626"), (2.2, "#059669")]:
        ax.add_patch(mpatches.FancyBboxPatch((x, 0.4), 0.5, 1.4, boxstyle="round,pad=0.0,rounding_size=0.05",
                                            facecolor=c, edgecolor="white", linewidth=1.5, zorder=3))
    # Graduation cap
    ax.add_patch(mpatches.Polygon([(4.0, 2.2), (6.0, 2.2), (5.0, 1.4)], closed=True,
                                  facecolor="#1F2937", edgecolor="#FBBF24", linewidth=2, zorder=4))
    ax.add_patch(mpatches.Polygon([(4.5, 2.3), (5.5, 2.3), (5.5, 2.7), (4.5, 2.7)],
                                  closed=True, facecolor="#1F2937", edgecolor="#FBBF24", linewidth=2, zorder=5))
    ax.plot([5.0, 5.0], [2.7, 3.0], color="#FBBF24", lw=2, zorder=5)
    ax.scatter([5.0], [3.1], s=80, c="#FBBF24", zorder=5)
    # Chat bubble
    ax.add_patch(mpatches.FancyBboxPatch((5.5, 0.4), 2.5, 0.9, boxstyle="round,pad=0.0,rounding_size=0.2",
                                       facecolor="white", edgecolor="#1E293B", linewidth=2, zorder=5))
    ax.text(6.75, 0.85, "Discuss…", fontsize=11, fontweight="bold", color="#1E293B", ha="center", zorder=6)
    _chrome(ax, "Education", "Part 3 · Discussion", "#FBBF24")
    return _save(fig, PUBLIC_DIR / f"{slug}.png")

# ---- Part 3: Work and Career ----
def render_discuss_work(slug, pubid):
    fig, ax = _canvas("#1E3A8A", "#93C5FD", "#FBBF24")
    # Briefcase
    ax.add_patch(mpatches.FancyBboxPatch((1.5, 0.5), 2.0, 1.4, boxstyle="round,pad=0.0,rounding_size=0.15",
                                       facecolor="#92400E", edgecolor="#1F2937", linewidth=3, zorder=4))
    ax.add_patch(mpatches.FancyBboxPatch((1.9, 1.6), 1.2, 0.4, boxstyle="round,pad=0.0,rounding_size=0.1",
                                       facecolor="#1F2937", zorder=5))
    # Person at desk
    head = mpatches.Circle((5.5, 1.8), 0.4, facecolor="#FBBF24", zorder=5)
    body = mpatches.FancyBboxPatch((5.0, 0.4), 1.0, 1.2, boxstyle="round,pad=0.0,rounding_size=0.3",
                                  facecolor="#3B82F6", zorder=5)
    ax.add_patch(head); ax.add_patch(body)
    # Laptop
    ax.add_patch(mpatches.Rectangle((6.5, 0.6), 1.2, 0.7, facecolor="#1F2937", zorder=5))
    ax.add_patch(mpatches.Rectangle((6.6, 0.7), 1.0, 0.5, facecolor="#3B82F6", zorder=6))
    # Chat bubble
    ax.add_patch(mpatches.FancyBboxPatch((5.5, 0.0), 2.5, 0.4, boxstyle="round,pad=0.0,rounding_size=0.1",
                                       facecolor="white", edgecolor="#1E293B", linewidth=2, zorder=5))
    ax.text(6.75, 0.2, "Discuss…", fontsize=9, fontweight="bold", color="#1E293B", ha="center", zorder=6)
    _chrome(ax, "Work &\nCareer", "Part 3 · Discussion", "#FBBF24")
    return _save(fig, PUBLIC_DIR / f"{slug}.png")

# ---- Part 3: Tradition ----
def render_discuss_tradition(slug, pubid):
    fig, ax = _canvas("#7F1D1D", "#FCA5A5", "#FBBF24")
    # Lanterns
    for (x, c) in [(2.0, "#EF4444"), (3.5, "#FBBF24"), (5.0, "#EF4444")]:
        ax.add_patch(mpatches.Ellipse((x, 2.0), 0.7, 0.9, facecolor=c, zorder=4))
        ax.add_patch(mpatches.Rectangle((x-0.05, 2.5), 0.1, 0.2, facecolor="#FBBF24", zorder=5))
        ax.plot([x, x], [1.5, 1.0], color="#FBBF24", lw=2, zorder=5)
        ax.plot([x, x], [2.6, 3.0], color="#92400E", lw=2, zorder=5)
    # Chat bubble
    ax.add_patch(mpatches.FancyBboxPatch((5.5, 0.4), 2.5, 0.9, boxstyle="round,pad=0.0,rounding_size=0.2",
                                       facecolor="white", edgecolor="#1E293B", linewidth=2, zorder=5))
    ax.text(6.75, 0.85, "Discuss…", fontsize=11, fontweight="bold", color="#1E2937", ha="center", zorder=6)
    _chrome(ax, "Tradition", "Part 3 · Discussion", "#FBBF24")
    return _save(fig, PUBLIC_DIR / f"{slug}.png")

RENDERERS = {
    "speaking-part1-introduce-yourself": render_intro,
    "speaking-part1-family-and-friends": render_family,
    "speaking-part1-hometown": render_hometown,
    "speaking-part1-hobbies": render_hobbies,
    "speaking-part1-work-or-study": render_work,
    "speaking-part1-daily-routine": render_routine,
    "speaking-part2-cue-card-describe-friend": render_describe_friend,
    "speaking-part2-cue-card-describe-place": render_describe_place,
    "speaking-part2-cue-card-describe-object": render_describe_object,
    "speaking-part2-cue-card-describe-event": render_describe_event,
    "speaking-part3-discuss-technology": render_discuss_tech,
    "speaking-part3-discuss-environment": render_discuss_env,
    "speaking-part3-discuss-education": render_discuss_edu,
    "speaking-part3-discuss-work-and-career": render_discuss_work,
    "speaking-part3-discuss-tradition": render_discuss_tradition,
}

def read_env_creds():
    out = {}
    for raw in ENV_PATH.read_text().splitlines():
        line = raw.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        k, v = line.split("=", 1)
        out[k.strip()] = v.strip().strip('"').strip("'")
    return out

def cloudinary_sign(params, secret):
    s = "&".join(f"{k}={v}" for k, v in sorted(params.items()))
    return hashlib.sha1((s + secret).encode()).hexdigest()

def upload(creds, file_path, public_id):
    timestamp = int(time.time())
    params = {"timestamp": str(timestamp), "public_id": public_id, "overwrite": "true"}
    sig = cloudinary_sign(params, creds["CLOUDINARY_API_SECRET"])
    url = f"https://api.cloudinary.com/v1_1/{creds['CLOUDINARY_CLOUD_NAME']}/image/upload"
    with open(file_path, "rb") as f:
        files = {"file": (file_path.name, f, "image/png")}
        data = {
            "api_key": creds["CLOUDINARY_API_KEY"],
            "timestamp": str(timestamp),
            "public_id": public_id,
            "overwrite": "true",
            "signature": sig,
        }
        r = requests.post(url, files=files, data=data, timeout=60)
    if r.status_code >= 400:
        raise SystemExit(f"Upload failed ({r.status_code}) for {file_path.name}: {r.text[:200]}")
    return r.json()["secure_url"]

def main():
    creds = read_env_creds()
    PUBLIC_DIR.mkdir(parents=True, exist_ok=True)
    slug_to_url = {}
    for slug, public_id in IMAGES:
        render = RENDERERS.get(slug)
        if not render:
            print(f"  skip unknown slug: {slug}"); continue
        path = PUBLIC_DIR / f"{slug}.png"
        print(f"  render  {slug}")
        render(slug, public_id)
        print(f"  upload  {path.name}")
        url = upload(creds, path, public_id)
        slug_to_url[slug] = url
        print(f"    {url}")
    print(f"\n{len(slug_to_url)}/{len(IMAGES)} images uploaded.")
    return slug_to_url

if __name__ == "__main__":
    main()
