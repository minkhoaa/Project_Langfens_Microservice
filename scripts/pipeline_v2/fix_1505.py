#!/usr/bin/env python3
"""Fix script for 1505-cubic-houses (Listening)"""
import json
from pathlib import Path

# Paths
DATA_DIR = Path("/home/khoa/RiderProjects/Project_Langfens_Microservice/data")
SOURCE = "mini-ielts"
ITEM_ID = "1505-cubic-houses"
json_path = DATA_DIR / "normalized" / SOURCE / f"{ITEM_ID}.json"

# Load data
with open(json_path) as f:
    data = json.load(f)

# === FIX 1: Replace passage with actual listening notes ===
# For listening tests, the "passage" is the notes/questions that students fill in
passage_md = """# Cube Houses - Listening Notes

## Background Information

After World War II, local urban planners wanted to redevelop and revive the city.

Altogether, the Cube Houses can function as a _______ (1)

Each Cube building is in the shape of a _______ (2)

The Cube Houses sit on top of a _______ (3) for pedestrians to the central city.

During construction, the work was temporarily discontinued because the designer faced the problem of _______ (4)

---

## Design Features of the Cube Houses

Underneath the houses, there are three pillars made of _______ (5)

A new building is situated between a warehouse and a _______ (6) of architecture.

It is a three-storey building.

The ground floor is an entrance.

Both the lower level and the top level of each house are in the shape of a _______ (7)

The first floor has a living room and an open kitchen.

The medium level has a bathroom and two bedrooms.

The top floor is sometimes used as a small _______ (8)

---

## Living in the Cube Houses

There is a nearby market _______ (9) across the square from the Cube Houses.

For guests, two advantages of the house are its convenient _______ (10) and reasonable price."""

data['sections'][0]['passage_md'] = passage_md

# === FIX 2: Fix Q4 answer (typo: "finace" -> "finance") ===
for q in data['questions']:
    if q['idx'] == 4:
        if q['correct_answers'] == ["finace"]:
            q['correct_answers'] = ["finance"]
            print("Fixed Q4 answer: finace -> finance")

# Save
with open(json_path, 'w') as f:
    json.dump(data, f, indent=2)

print(f"✅ Fixed {json_path}")
print("  - Replaced passage with actual listening notes")
print("  - Fixed Q4 typo if present")
