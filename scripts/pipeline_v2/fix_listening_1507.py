#!/usr/bin/env python3
"""
Fix script for mini-ielts 1507-research-project
Q1-6: MCQ_SINGLE, Q7-8: Choose TWO (D,E) split, Q9-10: Choose TWO (B,C) split
"""

import json
from pathlib import Path

BASE_DIR = Path("/home/khoa/RiderProjects/Project_Langfens_Microservice")
DATA_DIR = BASE_DIR / "data"
ITEM_ID = "1507-research-project"

(DATA_DIR / "normalized" / "mini-ielts").mkdir(parents=True, exist_ok=True)

# Full transcript
TRANSCRIPT = """Hello, John. Come in and sit down. You're here to discuss your research project, are you? Yes. I've more or less decided what to do, but I'd like your opinion. Fine. You've chosen a topic? Yes, I want to look at how people use public services in their local area. Things like parks and swimming pools. Right. Well, the kind of information you'll get is very useful for town planning, of course. Do you have a special interest in public services? Not really. It's just that I found a report in the college library about an investigation that was done ten years ago, and I thought it would be interesting to do a parallel one. 10 years is a relatively short space of time. What do you expect to find? Do you think things will be more or less the same as before? I think there will be some differences. For example, I think the number of people going to the library will have decreased. And I'd guess that older people are using the sports center more often than they used to. Fine. So those are your hypotheses. Now, what sort of data are you going to use? I was thinking of using official records from the management or the local council and analyzing them. They should be easy to obtain. I don't think that sort of information would be confidential. Yes, you're probably right. There might not be as much information as you'd like, but it would certainly be the easiest kind of data to work with. But have you considered using a questionnaire as well? It's okay to get data from more than one source? Absolutely. It's a bonus. You've already done the module on questionnaire design, haven't you? And it'll be good to get experience, because next year you'll have to do something similar for your final dissertation on a bigger scale. Okay. And what are the variables you'll be looking at? Are you going to look at people's level of education? Whether they have a degree, for example? I hadn't planned to. Do you think I should? Well, you might see some interesting patterns. Okay. And that'll tie in nicely with my plans to analyze the kind of work people do. What about the size of your sample? Have you got any thoughts on the number of questionnaires you might send out? The previous study surveyed 120 people. I don't think I can really analyze more than 50, working by myself, so I should probably distribute about 80 questionnaires altogether to allow for wastage. Do you think that's enough? Definitely. I know that your project guidelines recommend a minimum of 100, but that's an ideal number. And you're working by yourself. And anyway, this assignment is mainly about giving you practice in research methods. Right. And think of ways you can encourage people to actually complete the questionnaire. For example, to make sure that your questions make sense, you should try them out beforehand. Okay, that's no problem. My friends will help. Good. Sometimes you get unpredicted responses and you have to rephrase a question. And I know that you usually get a better return if you deliver questionnaires in person, but there will be too many. But I could enclose a stamped envelope for the return post. It's a bit expensive, but I think it would be worth it. Yes. Good. Some people say that another way of increasing returns is to make the questionnaires anonymous. But usually people put their names on anyway, so I don't think that would make much difference. Okay. And can you give me a bit more advice about the questionnaire? Would it be a good idea to have a short paragraph at the top explaining what I'm doing and why? Definitely. And don't forget you'll need to get a bit of information about your subjects, what age group they're in and perhaps how long they've lived in the area. So you'll need questions for that. Yes, I suppose that will mean it takes a bit longer to complete. But should I give them my phone number in case there's anything they're not sure about? I wouldn't if I were you. No. Okay. And do I have to use open ended questions as well as closed questions? I know the books say it's better to have a mixture. Well, it depends. In this case, I'd stick to close questions. The results will be much more manageable like that. If I draft some questions tomorrow, would it be okay to bring them?"""

questions = []

# Q1: How did John choose the topic? Answer: C
questions.append({
    "idx": 1,
    "type": "MULTIPLE_CHOICE_SINGLE",
    "prompt_md": "How did John choose the topic of his research project?",
    "options": [
        {"label": "A", "text": "He thought the information would be useful for town planning.", "is_correct": False},
        {"label": "B", "text": "He has a special interest in the use of public services.", "is_correct": False},
        {"label": "C", "text": "He read about a similar study which had been done earlier.", "is_correct": True},
    ],
    "correct_answers": ["C"]
})

# Q2: During research, expecting to find? Answer: B
questions.append({
    "idx": 2,
    "type": "MULTIPLE_CHOICE_SINGLE",
    "prompt_md": "During his research, John is expecting to find that",
    "options": [
        {"label": "A", "text": "The use of public services has altered very little.", "is_correct": False},
        {"label": "B", "text": "A group of people has changed its habits.", "is_correct": True},
        {"label": "C", "text": "The most frequently used facility is the library.", "is_correct": False},
    ],
    "correct_answers": ["B"]
})

# Q3: Problem with official records? Answer: A
questions.append({
    "idx": 3,
    "type": "MULTIPLE_CHOICE_SINGLE",
    "prompt_md": "What is the problem with using official records?",
    "options": [
        {"label": "A", "text": "They may be lacking in detail.", "is_correct": True},
        {"label": "B", "text": "They may not be readily available.", "is_correct": False},
        {"label": "C", "text": "They may be difficult to analyse.", "is_correct": False},
    ],
    "correct_answers": ["A"]
})

# Q4: Tutor thinks about questionnaire? Answer: C
questions.append({
    "idx": 4,
    "type": "MULTIPLE_CHOICE_SINGLE",
    "prompt_md": "What does the tutor think about John using a questionnaire to get information?",
    "options": [
        {"label": "A", "text": "He needs to do a course in questionnaire design first.", "is_correct": False},
        {"label": "B", "text": "He should use this method instead of looking at public records.", "is_correct": False},
        {"label": "C", "text": "He will find the practice he gets useful the following year.", "is_correct": True},
    ],
    "correct_answers": ["C"]
})

# Q5: New variable to add? Answer: C
questions.append({
    "idx": 5,
    "type": "MULTIPLE_CHOICE_SINGLE",
    "prompt_md": "Which new variable does John agree to add to his investigation?",
    "options": [
        {"label": "A", "text": "Occupation", "is_correct": False},
        {"label": "B", "text": "Income group", "is_correct": False},
        {"label": "C", "text": "Qualifications", "is_correct": True},
    ],
    "correct_answers": ["C"]
})

# Q6: How many questionnaires? Answer: B
questions.append({
    "idx": 6,
    "type": "MULTIPLE_CHOICE_SINGLE",
    "prompt_md": "How many questionnaires will John distribute?",
    "options": [
        {"label": "A", "text": "The same number as in the previous study", "is_correct": False},
        {"label": "B", "text": "A greater number than he needs for analysis", "is_correct": True},
        {"label": "C", "text": "The number recommended in the project guidelines", "is_correct": False},
    ],
    "correct_answers": ["B"]
})

# Q7-8: Choose TWO strategies (D, E) - Split to 2 MCQ_SINGLE
q78_options = [
    {"label": "A", "text": "Using simple language"},
    {"label": "B", "text": "Delivering the questionnaires in person"},
    {"label": "C", "text": "Making the questionnaires anonymous"},
    {"label": "D", "text": "Providing return envelopes"},
    {"label": "E", "text": "Trialing the questionnaire on friends"},
]

questions.append({
    "idx": 7,
    "type": "MULTIPLE_CHOICE_SINGLE",
    "prompt_md": "Which strategies will John use to encourage people to fill out his questionnaire? (Answer 1 of 2)",
    "options": [{"label": o["label"], "text": o["text"], "is_correct": o["label"] == "D"} for o in q78_options],
    "correct_answers": ["D"]
})

questions.append({
    "idx": 8,
    "type": "MULTIPLE_CHOICE_SINGLE",
    "prompt_md": "Which strategies will John use to encourage people to fill out his questionnaire? (Answer 2 of 2)",
    "options": [{"label": o["label"], "text": o["text"], "is_correct": o["label"] == "E"} for o in q78_options],
    "correct_answers": ["E"]
})

# Q9-10: Choose TWO advice (B, C) - Split to 2 MCQ_SINGLE
q910_options = [
    {"label": "A", "text": "There should be a mixture of question types."},
    {"label": "B", "text": "Some questions should elicit personal information."},
    {"label": "C", "text": "There should be an introduction to explain the survey's purpose."},
    {"label": "D", "text": "A telephone number should be provided for queries."},
    {"label": "E", "text": "The questions should only take a few minutes to answer."},
]

questions.append({
    "idx": 9,
    "type": "MULTIPLE_CHOICE_SINGLE",
    "prompt_md": "Which advice does the tutor give John about his questionnaire? (Answer 1 of 2)",
    "options": [{"label": o["label"], "text": o["text"], "is_correct": o["label"] == "B"} for o in q910_options],
    "correct_answers": ["B"]
})

questions.append({
    "idx": 10,
    "type": "MULTIPLE_CHOICE_SINGLE",
    "prompt_md": "Which advice does the tutor give John about his questionnaire? (Answer 2 of 2)",
    "options": [{"label": o["label"], "text": o["text"], "is_correct": o["label"] == "C"} for o in q910_options],
    "correct_answers": ["C"]
})

# Build normalized JSON
data = {
    "source_url": "https://mini-ielts.com/1507/listening/research-project",
    "exam": {
        "title": "Research Project",
        "skill": "LISTENING",
        "audio_url": "https://www.youtube.com/embed/VIDEO_ID_PLACEHOLDER"
    },
    "questions": questions,
    "sections": [
        {
            "idx": 1,
            "section_type": "LISTENING_PART",
            "title": "Part 3: Research Project",
            "passage_md": TRANSCRIPT,
            "transcript_md": TRANSCRIPT,
            "instruction_md": """**Questions 1-6:** Choose the correct letter, A, B or C.

**Questions 7-8:** Choose the correct answer from A-E. (Answer 1 of 2, Answer 2 of 2)

**Questions 9-10:** Choose the correct answer from A-E. (Answer 1 of 2, Answer 2 of 2)""",
            "questions": questions
        }
    ]
}

output_path = DATA_DIR / "normalized" / "mini-ielts" / f"{ITEM_ID}.json"
with open(output_path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print(f"✓ Saved normalized: {output_path}")
print(f"\n📋 Summary:")
print(f"  - Questions: {len(questions)}")
print(f"  - Passage words: {len(TRANSCRIPT.split())}")
for q in questions:
    print(f"  Q{q['idx']}: {q['type']} → {q.get('correct_answers', [])}")
