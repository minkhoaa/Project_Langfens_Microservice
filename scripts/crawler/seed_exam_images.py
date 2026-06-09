#!/usr/bin/env python3
"""Generate attractive cover images for exam-service exams (reading/listening) and upload to Cloudinary."""
import hashlib, sys, time
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
ENV_PATH = MICRO_ROOT / "deploy" / "envs" / "speaking.env"

# (slug, public_id, render_fn_name)
IMAGES = [
    ("ielts-listening-practice-1",                       "ielts/exams/ielts-listening-practice-1",       "render_listening_audio"),
    ("ielts-reading-practice-1",                        "ielts/exams/ielts-reading-practice-1",        "render_reading_passage"),
    ("ielts-mentor-ielts-academic-reading-test-119",     "ielts/exams/ielts-mentor-academic-reading-119", "render_reading_passage"),
    ("ielts-mentor-reading-test-119-passage-1-nutmeg-a-valuable-spice",  "ielts/exams/ielts-mentor-nutmeg",  "render_nutmeg"),
    ("ielts-mentor-reading-test-119-passage-2-driverless-cars",          "ielts/exams/ielts-mentor-driverless-cars",  "render_driverless_cars"),
    ("ielts-mentor-reading-test-119-passage-3-what-is-exploration",      "ielts/exams/ielts-mentor-exploration",  "render_exploration"),
    ("ielts-mentor-reading-test-116-passage-1-roman-shipbuilding-and-navigation",  "ielts/exams/ielts-mentor-roman-ship",  "render_roman_ship"),
    ("english-placement-a2-c1-sample-01",               "ielts/exams/english-placement-a2-c1",          "render_placement"),
]

def _save(fig, dest):
    dest.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(dest, dpi=150, bbox_inches="tight", facecolor="white")
    plt.close(fig)

def _chrome(ax, title, subtitle, accent):
    ax.text(0.55, 5.85, "IELTS", fontsize=11, color=accent, fontweight="bold",
            ha="left", va="top", alpha=0.85, family="DejaVu Sans")
    ax.text(0.55, 5.4, title, fontsize=22, color="white", fontweight="bold",
            ha="left", va="top", linespacing=1.15, family="DejaVu Sans")
    ax.text(0.55, 3.85, subtitle, fontsize=11, color="white", ha="left", va="top",
            alpha=0.75, style="italic", family="DejaVu Sans")

def _poster_canvas(bg, accent):
    fig, ax = plt.subplots(figsize=(10, 6.3))
    fig.patch.set_facecolor(bg); ax.set_facecolor(bg)
    ax.set_xlim(0, 10); ax.set_ylim(0, 6.3); ax.set_xticks([]); ax.set_yticks([])
    for s in ax.spines.values(): s.set_visible(False)
    rng = np.random.default_rng(seed=42)
    for _ in range(18):
        x = rng.uniform(7.5, 9.9); y = rng.uniform(4.6, 6.1)
        ax.scatter(x, y, s=rng.uniform(8, 30), c=accent, alpha=0.25, edgecolors="none", zorder=1)
    return fig, ax

# ---- Listening practice 1: headphones with waveform ----
def render_listening_audio(slug, pid):
    fig, ax = _poster_canvas("#0C4A6E", "#38BDF8")
    # Headphones
    ax.add_patch(mpatches.FancyBboxPatch((0.5, 1.0), 2.5, 1.6, boxstyle="round,pad=0.0,rounding_size=0.2",
                                       facecolor="#1E293B", edgecolor="#0EA5E9", linewidth=3, zorder=4))
    ax.add_patch(mpatches.Circle((0.7, 1.8), 0.4, facecolor="#0EA5E9", zorder=5))
    ax.add_patch(mpatches.Circle((2.8, 1.8), 0.4, facecolor="#0EA5E9", zorder=5))
    # Waveform bars
    for i, h in enumerate([0.5, 0.7, 0.4, 0.8, 0.6, 0.3, 0.7, 0.5, 0.4, 0.6, 0.5, 0.7]):
        ax.add_patch(mpatches.Rectangle((4.5 + i * 0.35, 1.5), 0.25, h,
                                       facecolor="#0EA5E9", zorder=5))
    # Sound notes
    for x, y in [(5.5, 3.2), (6.5, 3.0), (7.5, 3.2)]:
        ax.scatter([x], [y], s=80, c="#FBBF24", alpha=0.6, zorder=4)
    _chrome(ax, "Listening\nPractice", "Test 1 · Audio comprehension", "#0EA5E9")
    return _save(fig, PUBLIC_DIR / f"{slug}.png")

# ---- Reading practice: open book ----
def render_reading_passage(slug, pid):
    fig, ax = _poster_canvas("#1E1B4B", "#A78BFA")
    # Open book
    ax.add_patch(mpatches.Polygon([(0.5, 0.5), (2.5, 0.5), (2.5, 2.4), (0.5, 2.4)],
                                  closed=True, facecolor="white", edgecolor="#7C3AED", linewidth=2, zorder=4))
    ax.add_patch(mpatches.Polygon([(2.5, 0.5), (4.5, 0.5), (4.5, 2.4), (2.5, 2.4)],
                                  closed=True, facecolor="white", edgecolor="#7C3AED", linewidth=2, zorder=4))
    ax.plot([2.5, 2.5], [0.5, 2.4], color="#7C3AED", lw=2, zorder=5)
    for i in range(4):
        y = 2.0 - i * 0.35
        ax.plot([0.7, 2.3], [y, y], color="#A78BFA", lw=1.5, zorder=5)
        ax.plot([2.7, 4.3], [y, y], color="#A78BFA", lw=1.5, zorder=5)
    # Reading glasses
    ax.add_patch(mpatches.Circle((6.0, 1.8), 0.5, facecolor="none", edgecolor="#FBBF24", linewidth=4, zorder=5))
    ax.add_patch(mpatches.Circle((7.5, 1.8), 0.5, facecolor="none", edgecolor="#FBBF24", linewidth=4, zorder=5))
    ax.plot([6.5, 7.0], [1.8, 1.8], color="#FBBF24", lw=4, zorder=5)
    _chrome(ax, "Reading\nPractice", "Test 1 · Comprehension", "#A78BFA")
    return _save(fig, PUBLIC_DIR / f"{slug}.png")

# ---- Nutmeg passage: spice + globe ----
def render_nutmeg(slug, pid):
    fig, ax = _poster_canvas("#7C2D12", "#FDBA74")
    # Spice seeds
    for i, (x, y) in enumerate([(1.0, 1.0), (1.5, 1.3), (2.0, 1.0), (2.5, 1.4),
                                (1.2, 1.7), (1.8, 1.9), (2.3, 1.8)]):
        ax.add_patch(mpatches.Ellipse((x, y), 0.35, 0.5, facecolor="#92400E", zorder=4, angle=20))
    # Globe
    ax.add_patch(mpatches.Circle((6.0, 1.8), 1.0, facecolor="#1E40AF", edgecolor="#FBBF24", linewidth=3, zorder=4))
    ax.add_patch(mpatches.Ellipse((6.0, 1.8), 1.0, 0.3, facecolor="none", edgecolor="#0EA5E9", linewidth=2, zorder=5))
    ax.add_patch(mpatches.Ellipse((6.0, 1.8), 0.4, 1.0, facecolor="none", edgecolor="#0EA5E9", linewidth=2, zorder=5))
    # Pin
    ax.scatter([6.0], [2.5], s=300, marker="*", c="#EF4444", zorder=6)
    _chrome(ax, "Nutmeg: A\nValuable Spice", "Reading Test 119 · Passage 1", "#FBBF24")
    return _save(fig, PUBLIC_DIR / f"{slug}.png")

# ---- Driverless cars: futuristic car on road ----
def render_driverless_cars(slug, pid):
    fig, ax = _poster_canvas("#0F172A", "#60A5FA")
    # Road perspective
    ax.add_patch(mpatches.Polygon([(0, 0), (10, 0), (7, 2.5), (3, 2.5)],
                                  closed=True, facecolor="#1E293B", zorder=2))
    for y in [0.3, 0.9, 1.5]:
        ax.plot([3.5, 6.5], [y, y], color="#FBBF24", lw=3, linestyle=(0, (4, 6)), zorder=3)
    # Futuristic car
    ax.add_patch(mpatches.FancyBboxPatch((4.0, 1.3), 2.5, 0.9,
                                       boxstyle="round,pad=0.0,rounding_size=0.2",
                                       facecolor="#3B82F6", edgecolor="#60A5FA", linewidth=2, zorder=4))
    ax.add_patch(mpatches.Polygon([(4.3, 2.2), (4.6, 2.5), (5.9, 2.5), (6.2, 2.2)],
                                  closed=True, facecolor="#3B82F6", edgecolor="#60A5FA", linewidth=2, zorder=4))
    ax.add_patch(mpatches.Rectangle((4.5, 2.25), 1.5, 0.2, facecolor="#06B6D4", zorder=5))
    # LIDAR / sensor dome
    ax.add_patch(mpatches.Circle((5.25, 2.65), 0.2, facecolor="#EF4444", zorder=6))
    ax.add_patch(mpatches.Circle((5.25, 2.65), 0.35, facecolor="#EF4444", alpha=0.3, zorder=5))
    # Wheels
    ax.add_patch(mpatches.Circle((4.5, 1.3), 0.2, facecolor="#0F172A", zorder=5))
    ax.add_patch(mpatches.Circle((6.0, 1.3), 0.2, facecolor="#0F172A", zorder=5))
    _chrome(ax, "Driverless Cars", "Reading Test 119 · Passage 2", "#60A5FA")
    return _save(fig, PUBLIC_DIR / f"{slug}.png")

# ---- Exploration: telescope + rocket ----
def render_exploration(slug, pid):
    fig, ax = _poster_canvas("#1E1B4B", "#FBBF24")
    # Rocket
    ax.add_patch(mpatches.Polygon([(1.5, 0.3), (1.7, 0.3), (1.7, 1.8), (1.5, 1.8)],
                                  closed=True, facecolor="#E5E7EB", zorder=3))
    ax.add_patch(mpatches.Polygon([(1.5, 0.3), (1.7, 0.3), (1.6, 0.0)],
                                  closed=True, facecolor="#E5E7EB", zorder=3))
    ax.add_patch(mpatches.Circle((1.6, 1.4), 0.12, facecolor="#3B82F6", zorder=4))
    # Flame
    ax.add_patch(mpatches.Polygon([(1.45, 0.3), (1.75, 0.3), (1.6, -0.3)],
                                  closed=True, facecolor="#F97316", zorder=2))
    # Telescope
    ax.add_patch(mpatches.Rectangle((3.5, 0.4), 0.3, 1.4, facecolor="#7C3AED", zorder=4))
    ax.add_patch(mpatches.Polygon([(3.5, 1.5), (3.8, 1.5), (4.2, 2.0), (3.7, 2.0)],
                                  closed=True, facecolor="#1E293B", zorder=4))
    # Stars
    for sx, sy, r in [(5.0, 3.0, 0.08), (6.0, 2.5, 0.06), (6.5, 3.5, 0.1),
                      (7.5, 2.8, 0.07), (8.0, 3.2, 0.05)]:
        ax.scatter([sx], [sy], s=r*1000, c="#FBBF24", zorder=4)
    _chrome(ax, "What is\nExploration?", "Reading Test 119 · Passage 3", "#FBBF24")
    return _save(fig, PUBLIC_DIR / f"{slug}.png")

# ---- Roman shipbuilding: ship ----
def render_roman_ship(slug, pid):
    fig, ax = _poster_canvas("#0F766E", "#FCD34D")
    # Ship hull
    ax.add_patch(mpatches.Polygon([(0.5, 0.5), (3.5, 0.5), (3.5, 1.0), (3.0, 1.3),
                                  (0.8, 1.3), (0.5, 1.0)],
                                  closed=True, facecolor="#92400E", edgecolor="#1F2937", linewidth=2, zorder=3))
    # Mast
    ax.plot([1.8, 1.8], [1.3, 2.5], color="#1F2937", lw=3, zorder=4)
    # Sail
    ax.add_patch(mpatches.Polygon([(1.8, 2.5), (2.8, 1.5), (1.8, 1.5)],
                                  closed=True, facecolor="#FCD34D", edgecolor="#1F2937", linewidth=1.5, zorder=4))
    # Oars
    for i in range(3):
        ax.plot([0.7 + i*0.7, 0.5 + i*0.7], [0.6, 0.2], color="#1F2937", lw=2, zorder=4)
    # Sea waves
    for y in [0.3, 0.15]:
        ax.plot([0, 10], [y, y], color="#0EA5E9", lw=2, alpha=0.6, zorder=2)
    _chrome(ax, "Roman\nShipbuilding", "Reading Test 116 · Passage 1", "#FCD34D")
    return _save(fig, PUBLIC_DIR / f"{slug}.png")

# ---- English placement: clipboard with checkmark ----
def render_placement(slug, pid):
    fig, ax = _poster_canvas("#0F766E", "#5EEAD4")
    # Clipboard
    ax.add_patch(mpatches.FancyBboxPatch((1.0, 0.4), 1.8, 2.4, boxstyle="round,pad=0.0,rounding_size=0.1",
                                       facecolor="white", edgecolor="#0F766E", linewidth=3, zorder=4))
    ax.add_patch(mpatches.FancyBboxPatch((1.4, 2.5), 1.0, 0.3, boxstyle="round,pad=0.0,rounding_size=0.05",
                                       facecolor="#5EEAD4", edgecolor="#0F766E", linewidth=2, zorder=5))
    # Lines on paper
    for i in range(3):
        ax.plot([1.3, 2.5], [2.3 - i*0.4, 2.3 - i*0.4], color="#9CA3AF", lw=1, zorder=5)
    # Checkmark (big, on right)
    ax.add_patch(mpatches.FancyBboxPatch((4.5, 0.6), 2.0, 2.0, boxstyle="round,pad=0.0,rounding_size=0.2",
                                       facecolor="#10B981", zorder=4))
    ax.plot([5.0, 5.5, 6.0], [1.6, 1.1, 1.8], color="white", lw=8, solid_capstyle="round", zorder=5)
    # A1 -> C1 arrow
    ax.text(5.5, 2.95, "A2 → C1", fontsize=14, fontweight="bold", color="white", ha="center", zorder=5)
    _chrome(ax, "English\nPlacement", "Sample 01 · Find your level", "#5EEAD4")
    return _save(fig, PUBLIC_DIR / f"{slug}.png")

RENDERERS = {
    "render_listening_audio": render_listening_audio,
    "render_reading_passage": render_reading_passage,
    "render_nutmeg": render_nutmeg,
    "render_driverless_cars": render_driverless_cars,
    "render_exploration": render_exploration,
    "render_roman_ship": render_roman_ship,
    "render_placement": render_placement,
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
    for slug, public_id, render_name in IMAGES:
        render = RENDERERS.get(render_name)
        if not render:
            print(f"  skip unknown renderer: {render_name}"); continue
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
