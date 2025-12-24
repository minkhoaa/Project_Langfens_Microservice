#!/usr/bin/env python3
"""
Fix script for mini-ielts 390-new-staff-at-theatre
v4: Removed "TWO" from prompts to avoid MCQ_MULTIPLE detection
"""

import json
from pathlib import Path

# Constants
BASE_DIR = Path("/home/khoa/RiderProjects/Project_Langfens_Microservice")
DATA_DIR = BASE_DIR / "data"
ITEM_ID = "390-new-staff-at-theatre"

# Create output directory structure
(DATA_DIR / "normalized" / "mini-ielts").mkdir(parents=True, exist_ok=True)
(DATA_DIR / "cleaned" / "mini-ielts").mkdir(parents=True, exist_ok=True)

# Full transcript from solution page
TRANSCRIPT = """Hi. Great to see you! I'm Jody, and I'll be looking after both of you for the first month you're working here at the Amersham Theatre. I'll tell you something about the theatre now, then take you to meet two of the other staff.

It's an old building, and it's been modernised several times. In fact, as you can see, we're carrying out a major refurbishment at the moment. The interior has just been repainted, and we're about to start on the exterior of the building - that'll be a big job. The work's running over budget, so we've had to postpone installing an elevator. I hope you're happy running up and down stairs! When the theatre was built, people were generally slimmer and shorter than now, and the seats were very close together. We've replaced them with larger seats, with more legroom. This means fewer seats in total, but we've taken the opportunity to install seats that can easily be moved, to create different acting spaces. We've also turned a few storerooms over to other purposes, like using them for meetings.

We try hard to involve members of the public in the theatre. One way is by organising backstage tours, so people can be shown round the building and learn how a theatre operates. These are proving very popular. What we're finding is that people want to have lunch or a cup of coffee while they're here, so we're looking into the possibility of opening a cafe in due course. We have a bookshop, which specialises in books about drama, and that attracts plenty of customers. Then there are two large rooms that will be decorated next month, and they'll be available for hire, for conferences and private functions, such as parties. We're also considering hiring out costumes to amateur drama clubs.

Now I want to tell you about our workshops. We recently started a programme of workshops that anyone can join. Eventually we intend to run courses in acting, but we're waiting until we've got the right people in place as trainers. That's proving more difficult than we'd expected! There's a big demand to learn about the technical side of putting on a production, and our lighting workshop has already started, with great success. We're going to start one on sound next month. A number of people have enquired about workshops on make-up, and that's something we're considering for the future. A surprise success is the workshop on making puppets - we happen to have someone working here who does it as a hobby, and she offered to run a workshop. It was so popular we're now running them every month!

Now, a word about the layout of the building. The auditorium, stage and dressing rooms for the actors are all below ground level. Here on the ground floor we have most of the rooms that the public doesn't see. The majority are internal, so they have windows in the roof to light.

Standing here in the foyer, you're probably wondering why the box office isn't here, where the public would expect to find it. Well, you might have noticed it on your way in - although it's part of this building, it's next door, with a separate entrance from the road.

For the theatre manager's office, you go across the foyer and through the double doors, turn right, and it's the room at the end of the corridor, with the door on the left.

The lighting box is where the computerised stage lighting is operated, and it's at the back of the building. When you're through the double doors, turn left, turn right at the water cooler, and right again at the end. It's the second room along that corridor. The lighting box has a window into the auditorium, which of course is below us.

The artistic director's office is through the double doors, turn right, and it's the first room you come to on the right-hand side. And finally, for the moment, the room where I'll take you next - the relaxation room. So if you'd like to come with me..."""

# Questions data
questions = []

# Q1-2: Changes during refurbishment (A, B)
q1_options = [
    {"label": "A", "text": "Some rooms now have a different use."},
    {"label": "B", "text": "A different type of seating has been installed."},
    {"label": "C", "text": "An elevator has been installed."},
    {"label": "D", "text": "The outside of the building has been repaired."},
    {"label": "E", "text": "Extra seats have been added."},
]

# Changed prompt to avoid "TWO" detection
questions.append({
    "idx": 1,
    "type": "MULTIPLE_CHOICE_SINGLE",
    "prompt_md": "Which change has been made during the refurbishment of the theatre? (1 of 2)",
    "options": [{"label": o["label"], "text": o["text"], "is_correct": o["label"] == "A"} for o in q1_options],
    "correct_answers": ["A"]
})

questions.append({
    "idx": 2,
    "type": "MULTIPLE_CHOICE_SINGLE",
    "prompt_md": "Which change has been made during the refurbishment of the theatre? (2 of 2)",
    "options": [{"label": o["label"], "text": o["text"], "is_correct": o["label"] == "B"} for o in q1_options],
    "correct_answers": ["B"]
})

# Q3-4: Facilities offered (B, D)
q3_options = [
    {"label": "A", "text": "rooms for hire"},
    {"label": "B", "text": "backstage tours"},
    {"label": "C", "text": "hire of costumes"},
    {"label": "D", "text": "a bookshop"},
    {"label": "E", "text": "a cafe"},
]

questions.append({
    "idx": 3,
    "type": "MULTIPLE_CHOICE_SINGLE", 
    "prompt_md": "Which facility does the theatre currently offer to the public? (1 of 2)",
    "options": [{"label": o["label"], "text": o["text"], "is_correct": o["label"] == "B"} for o in q3_options],
    "correct_answers": ["B"]
})

questions.append({
    "idx": 4,
    "type": "MULTIPLE_CHOICE_SINGLE",
    "prompt_md": "Which facility does the theatre currently offer to the public? (2 of 2)",
    "options": [{"label": o["label"], "text": o["text"], "is_correct": o["label"] == "D"} for o in q3_options],
    "correct_answers": ["D"]
})

# Q5-6: Workshops offered (C, E)
q5_options = [
    {"label": "A", "text": "sound"},
    {"label": "B", "text": "acting"},
    {"label": "C", "text": "making puppets"},
    {"label": "D", "text": "make-up"},
    {"label": "E", "text": "lighting"},
]

questions.append({
    "idx": 5,
    "type": "MULTIPLE_CHOICE_SINGLE",
    "prompt_md": "Which workshop does the theatre currently offer? (1 of 2)",
    "options": [{"label": o["label"], "text": o["text"], "is_correct": o["label"] == "C"} for o in q5_options],
    "correct_answers": ["C"]
})

questions.append({
    "idx": 6,
    "type": "MULTIPLE_CHOICE_SINGLE",
    "prompt_md": "Which workshop does the theatre currently offer? (2 of 2)",
    "options": [{"label": o["label"], "text": o["text"], "is_correct": o["label"] == "E"} for o in q5_options],
    "correct_answers": ["E"]
})

# Q7-10: Label plan (MATCHING_INFORMATION)
matching_questions = [
    (7, "box office", "G"),
    (8, "theatre manager's office", "D"),
    (9, "lighting box", "B"),
    (10, "artistic director's office", "F"),
]

for idx, prompt, answer in matching_questions:
    questions.append({
        "idx": idx,
        "type": "MATCHING_INFORMATION",
        "prompt_md": prompt,
        "options": [],
        "correct_answers": [answer]
    })

# Build the normalized JSON structure (invariants.py expects questions at ROOT)
data = {
    "source_url": "https://mini-ielts.com/390/listening/new-staff-at-theatre",
    "exam": {
        "title": "New staff at theatre",
        "skill": "LISTENING",
        "audio_url": "https://www.youtube.com/embed/VIDEO_ID_PLACEHOLDER"
    },
    # Questions at root for invariants.py
    "questions": questions,
    "sections": [
        {
            "idx": 1,
            "section_type": "LISTENING_PART",
            "title": "Part 1: New staff at theatre",
            "passage_md": TRANSCRIPT,
            "transcript_md": TRANSCRIPT,
            "instruction_md": """**Questions 1-6:** Choose the correct answer from A-E.

**Questions 7-10:** Label the plan below. Write the correct letter, A-G, next to Questions 7-10.

Ground floor plan of theatre (Diagram showing locations A-G)""",
            "questions": questions
        }
    ]
}

# Save normalized JSON
output_path = DATA_DIR / "normalized" / "mini-ielts" / f"{ITEM_ID}.json"
with open(output_path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print(f"✓ Saved normalized: {output_path}")

# Also save cleaned text
cleaned_path = DATA_DIR / "cleaned" / "mini-ielts" / f"{ITEM_ID}.txt"
with open(cleaned_path, "w", encoding="utf-8") as f:
    f.write(TRANSCRIPT)

print(f"✓ Saved cleaned: {cleaned_path}")

# Print summary
print(f"\n📋 Summary:")
print(f"  - Questions: {len(questions)}")
print(f"  - Passage words: {len(TRANSCRIPT.split())}")
for q in questions:
    print(f"  Q{q['idx']}: {q['type']} → {q.get('correct_answers', [])}")
