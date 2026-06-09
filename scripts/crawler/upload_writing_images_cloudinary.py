#!/usr/bin/env python3
"""
Upload 7 writing task 1 PNGs to Cloudinary, then patch
deploy/seeds/seed_writing_exams_image_urls.sql with the returned URLs.

Reads CLOUDINARY_API_SECRET from the speaking-service .env file at runtime
(never hard-coded), so the secret never lands in this file or in git.

Usage:
    python3 scripts/crawler/upload_writing_images_cloudinary.py
"""

import hashlib
import os
import re
import sys
import time
from pathlib import Path

import requests

# ── Paths ──────────────────────────────────────────────────────────────────
SCRIPT_DIR = Path(__file__).resolve().parent
MICRO_ROOT = SCRIPT_DIR.parents[1]              # Project_Langfens_Microservice
WORKSPACE_ROOT = MICRO_ROOT.parent              # langfens
PUBLIC_DIR = WORKSPACE_ROOT / "langfens-fe-app" / "public" / "writing-images"
SEEDS_DIR = MICRO_ROOT / "deploy" / "seeds"
SQL_PATH = SEEDS_DIR / "seed_writing_exams_image_urls.sql"
ENV_PATH = MICRO_ROOT / "deploy" / "envs" / "speaking.env"

# (slug, file, public_id)
IMAGES = [
    ("task1-academic-bar-chart-population-by-age",         "task1-academic-bar-chart-population-by-age.png",         "ielts/writing-task1/task1-academic-bar-chart-population-by-age"),
    ("task1-academic-line-graph-internet-users",           "task1-academic-line-graph-internet-users.png",           "ielts/writing-task1/task1-academic-line-graph-internet-users"),
    ("task1-academic-pie-chart-energy-sources",            "task1-academic-pie-chart-energy-sources.png",            "ielts/writing-task1/task1-academic-pie-chart-energy-sources"),
    ("task1-academic-process-bottle-recycling",            "task1-academic-process-bottle-recycling.png",            "ielts/writing-task1/task1-academic-process-bottle-recycling"),
    ("task1-gt-letter-complaint-noisy-neighbour",          "task1-gt-letter-complaint-noisy-neighbour.png",          "ielts/writing-task1/task1-gt-letter-complaint-noisy-neighbour"),
    ("task1-gt-letter-job-application-receptionist",       "task1-gt-letter-job-application-receptionist.png",       "ielts/writing-task1/task1-gt-letter-job-application-receptionist"),
    ("ielts-mentor-writing-4135-letter-to-your-friend-describing-your-experience-o",
                                                            "ielts-mentor-writing-4135-letter-to-your-friend-describing-your-experience-o.png",
                                                            "ielts/writing-task1/ielts-mentor-writing-4135-letter-to-your-friend-describing-your-experience-o"),
    # Task 2 essay covers
    ("task2-opinion-children-screen-time",                 "task2-opinion-children-screen-time.png",                 "ielts/writing-task1/task2-opinion-children-screen-time"),
    ("task2-opinion-university-tuition-free",              "task2-opinion-university-tuition-free.png",              "ielts/writing-task1/task2-opinion-university-tuition-free"),
    ("task2-discuss-cars-vs-public-transport",             "task2-discuss-cars-vs-public-transport.png",             "ielts/writing-task1/task2-discuss-cars-vs-public-transport"),
    ("task2-discuss-traditional-vs-modern-buildings",      "task2-discuss-traditional-vs-modern-buildings.png",      "ielts/writing-task1/task2-discuss-traditional-vs-modern-buildings"),
    ("task2-problem-solution-traffic-congestion",          "task2-problem-solution-traffic-congestion.png",          "ielts/writing-task1/task2-problem-solution-traffic-congestion"),
    ("task2-problem-solution-air-pollution-cities",        "task2-problem-solution-air-pollution-cities.png",        "ielts/writing-task1/task2-problem-solution-air-pollution-cities"),
]


def read_env_secret(env_path: Path) -> dict:
    """Parse key=value pairs from speaking.env, returning only the CLOUDINARY_* keys."""
    out = {}
    for raw in env_path.read_text().splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        if "=" not in line:
            continue
        k, v = line.split("=", 1)
        k = k.strip()
        v = v.strip().strip('"').strip("'")
        if k.startswith("CLOUDINARY_"):
            out[k] = v
    required = {"CLOUDINARY_CLOUD_NAME", "CLOUDINARY_API_KEY", "CLOUDINARY_API_SECRET"}
    missing = required - set(out)
    if missing:
        raise SystemExit(f"Missing in {env_path}: {missing}")
    return out


def cloudinary_sign(params: dict, api_secret: str) -> str:
    """SHA1 of sorted key=value pairs joined with & + api_secret."""
    s = "&".join(f"{k}={v}" for k, v in sorted(params.items()))
    return hashlib.sha1((s + api_secret).encode("utf-8")).hexdigest()


def upload_one(creds: dict, file_path: Path, public_id: str) -> str:
    """Upload to Cloudinary, return the secure_url."""
    timestamp = int(time.time())
    params = {
        "folder": "ielts/writing-task1",
        "public_id": public_id.removeprefix("ielts/writing-task1/"),
        "timestamp": str(timestamp),
        "overwrite": "true",
    }
    signature = cloudinary_sign(params, creds["CLOUDINARY_API_SECRET"])

    url = f"https://api.cloudinary.com/v1_1/{creds['CLOUDINARY_CLOUD_NAME']}/image/upload"
    with open(file_path, "rb") as f:
        files = {"file": (file_path.name, f, "image/png")}
        data = {
            "api_key": creds["CLOUDINARY_API_KEY"],
            "timestamp": str(timestamp),
            "signature": signature,
            "folder": params["folder"],
            "public_id": params["public_id"],
            "overwrite": "true",
        }
        r = requests.post(url, files=files, data=data, timeout=60)
    if r.status_code >= 400:
        raise SystemExit(f"Upload failed ({r.status_code}) for {file_path.name}: {r.text[:300]}")
    body = r.json()
    if "secure_url" not in body:
        raise SystemExit(f"No secure_url in response: {body}")
    return body["secure_url"]


def patch_sql(slug_to_url: dict) -> None:
    """Replace relative /writing-images/... lines in the SQL with the Cloudinary URLs."""
    src = SQL_PATH.read_text()
    for slug, url in slug_to_url.items():
        # find existing UPDATE for this slug and rewrite its ImageUrl value
        pattern = re.compile(
            r"(UPDATE\s+writing_exams\s+SET\s+\"ImageUrl\"\s*=\s*)'[^']*'"
            r"(\s+WHERE\s+\"Slug\"\s*=\s*'" + re.escape(slug) + r"';)",
            re.IGNORECASE,
        )
        new_src, n = pattern.subn(rf"\1'{url}'\2", src)
        if n != 1:
            raise SystemExit(f"Expected exactly 1 match for slug={slug}, got {n}")
        src = new_src
    SQL_PATH.write_text(src)
    print(f"  ✓ patched  {SQL_PATH.relative_to(MICRO_ROOT)}")


def main() -> int:
    print(f"Reading Cloudinary creds from: {ENV_PATH.relative_to(MICRO_ROOT)}")
    creds = read_env_secret(ENV_PATH)
    print(f"  cloud_name: {creds['CLOUDINARY_CLOUD_NAME']}")
    print(f"  api_key:    {creds['CLOUDINARY_API_KEY']}")
    print(f"  api_secret: {len(creds['CLOUDINARY_API_SECRET'])} chars (loaded, not displayed)\n")

    slug_to_url: dict = {}
    for slug, filename, public_id in IMAGES:
        path = PUBLIC_DIR / filename
        if not path.exists():
            print(f"  ✗ missing local file: {path}")
            return 1
        print(f"  ↑ {filename} → {public_id}")
        url = upload_one(creds, path, public_id)
        slug_to_url[slug] = url
        print(f"    {url}")

    print("\nPatching SQL file with Cloudinary URLs...")
    patch_sql(slug_to_url)

    print("\nAll 7 images uploaded and SQL updated. Run to apply:")
    print(f"  PGPASSWORD=writing psql -h localhost -p 5440 -U writing -d writing-db \\")
    print(f"    -f {SQL_PATH.relative_to(MICRO_ROOT)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
