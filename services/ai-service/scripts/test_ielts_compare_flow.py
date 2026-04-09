#!/usr/bin/env python3
"""
Test IELTS Compare Flow - Grading + Sentence Improvements
Run: python scripts/test_ielts_compare_flow.py
"""

import asyncio
import json
import os
import sys
from datetime import datetime
from pathlib import Path
from typing import List, TypedDict

# Add parent to path
sys.path.insert(0, str(Path(__file__).parent.parent))

from openai import OpenAI

# Constants
GROQ_API_KEY = os.getenv("GROQ_API_KEY", "")
GROQ_BASE_URL = "https://api.groq.com/openai/v1"
MODEL = "llama-3.3-70b-versatile"

# Sample IELTS Task 2 Essay (Band 6.0 level)
SAMPLE_ESSAY = {
    "topic": "Some people believe that universities should focus on providing academic knowledge, while others think they should also teach practical skills for employment. Discuss both views and give your own opinion.",
    "task_type": "discussion_essay",
    "student_band": 6.0,
    "essay_text": """In modern society, the role of universities has become a topic of debate. Some people argue that universities should only focus on academic knowledge, while others believe they should also teach practical skills for employment.

On one hand, academic knowledge is very important for universities. It helps students to understand fundamental theories and concepts that are needed for their future careers. For example, knowing scientific principles helps students to think critically and solve complex problems.

On the other hand, many people think that universities should also teach practical skills. This is because employers nowadays want workers who have both theoretical knowledge and practical experience. For instance, skills like communication, teamwork, and problem-solving are very important in the workplace.

In my opinion, universities should provide a balance between academic knowledge and practical skills. This is because graduates need both theoretical understanding and real-world skills to succeed in their careers.

In conclusion, I believe that universities should not only focus on academic knowledge but also include practical skills in their curriculum. This will help students to be better prepared for the workforce."""
}

# Simulated reference essays from Qdrant (would be retrieved from vector DB)
REFERENCE_ESSAYS = {
    "step_up": {
        "band": 6.5,
        "essays": [
            """Universities have long been institutions dedicated to academic pursuits, but the modern job market demands a more nuanced approach to higher education. While theoretical knowledge forms the foundation of university education, the integration of practical skills has become increasingly essential.

The acquisition of academic knowledge remains a primary function of universities. Degrees in mathematics, philosophy, and literature provide students with critical thinking abilities and analytical frameworks that are valuable across numerous professional domains. For instance, a degree in economics equips graduates with understanding of market dynamics and quantitative reasoning applicable to various careers.

However, the contemporary employment landscape requires additional competencies. Practical skills such as digital literacy, project management, and effective communication have become indispensable. Universities that incorporate internship programs and vocational training into their curricula better prepare students for professional environments.

In my assessment, universities should strive to balance academic rigor with practical application. This dual approach ensures graduates possess both theoretical understanding and workplace-ready competencies.

In conclusion, the most effective university education combines traditional academic instruction with practical skill development, creating well-rounded individuals prepared for diverse career challenges."""
        ]
    },
    "target": {
        "band": 7.0,
        "essays": [
            """The debate regarding the primary purpose of university education has intensified in recent decades. While traditionalists advocate exclusively for academic excellence, an opposing view emphasizes the integration of practical vocational training. This essay examines both perspectives before articulating a reasoned position.

Proponents of purely academic education argue that universities should remain sanctuaries of pure scholarship. The pursuit of knowledge for its own sake, they contend, cultivates intellectual capacities that transcend specific professions. Subjects such as mathematics, philosophy, and literature develop analytical reasoning and critical thinking skills that prove invaluable across diverse career paths. As Oscar Wilde remarked, "Education is an admirable thing, but it is well to remember from time to time that nothing that is worth knowing can be taught."

Conversely, advocates for practical skill development assert that universities bear a responsibility to prepare students for employment. The contemporary job market is increasingly competitive, and graduates equipped only with theoretical knowledge often struggle to transition into professional roles. Practical competencies such as effective communication, collaborative problem-solving, and technological proficiency have become essential prerequisites for career success. Furthermore, universities that maintain close ties with industries can better align their curricula with market demands.

In my judgment, the most effective approach synthesizes both perspectives. Universities should indeed prioritize rigorous academic foundations, but they must equally recognize their role in developing workplace-ready graduates. This balanced model produces individuals capable of both abstract reasoning and practical application.

In conclusion, while academic knowledge should remain central to university education, the integration of practical skills is equally imperative for producing well-prepared graduates.""",
        ]
    }
}


def format_references(references: List[str], label: str) -> str:
    """Format reference essays for prompt."""
    if not references:
        return f"(No {label} references available)"
    parts = []
    for i, ref in enumerate(references, 1):
        parts.append(f"--- {label} Essay {i} ---\n{ref}")
    return "\n\n".join(parts)


def get_compare_prompt(student_band: float, topic: str, essay: str,
                       step_up_refs: str, target_refs: str) -> str:
    """Generate the comparison prompt."""
    step_up_band = min(student_band + 0.5, 9.0)
    target_band = min(student_band + 1.5, 9.0)
    
    return f"""You are an expert IELTS Writing examiner helping a student improve progressively. The student's current band is {student_band}.

You will compare the student's essay with two sets of reference essays:
- **Step-up references** (Band {step_up_band}): Achievable improvements the student can make soon.
- **Target references** (Band {target_band}): Stretch-goal quality for medium-term improvement.

<topic>{topic}</topic>

<student_essay>{essay}</student_essay>

<step_up_references>
{step_up_refs}
</step_up_references>

<target_references>
{target_refs}
</target_references>

Provide your analysis as a JSON object with these exact keys:

{{"overall_analysis": "A 150-200 word overview of the student's current level and their improvement path from Band {student_band} to Band {step_up_band} and Band {target_band}.",
  "vocabulary_feedback": "Compare lexical resource across all three levels. What vocabulary patterns appear at Band {step_up_band} that the student is missing? What about Band {target_band}?",
  "coherence_feedback": "Compare coherence devices and paragraph structure across all three levels.",
  "grammar_feedback": "Compare grammatical range and accuracy across all three levels.",
  "task_response_feedback": "Compare how well each level addresses the prompt.",
  "step_up_analysis": "Specific, actionable analysis: what the student needs to do to reach Band {step_up_band}. Reference concrete examples from the step-up essays.",
  "target_analysis": "What distinguishes Band {target_band} writing from Band {step_up_band}. What the student should aim for in the medium term.",
  "key_improvements": ["First priority improvement", "Second priority improvement", "Third priority improvement"],
  "sentence_comparisons": [
    {{
      "original": "The exact sentence from the student's essay that could be improved",
      "improved": "A rewritten version of that sentence demonstrating higher band quality",
      "explanation": "Why this change improves the essay (2-3 sentences)",
      "category": "vocabulary"
    }}
  ]
}}

CRITICAL — Reference Essay Quality Warning:
- The reference essays below are crowd-sourced and may contain their own grammatical errors or unidiomatic expressions.
- Do NOT copy errors from reference essays into your suggested improvements.
- If a reference essay contains mistakes (e.g. missing articles, wrong prepositions, word confusion), acknowledge them internally and still provide CORRECT, idiomatic improvements based on your own expertise as a native-level examiner.
- Your improved sentences must ALWAYS be grammatically perfect and sound natural to a native English speaker.

Rules:
- key_improvements must have 3 to 5 items, ordered by impact. Each item should be a specific, actionable sentence.
- sentence_comparisons must have 2 to 5 items.
- Choose the MOST impactful sentence improvements, not trivial ones.
- Each category (vocabulary, grammar, coherence, structure) should be represented if possible.
- Only include sentences that genuinely need improvement.
- category must be one of: vocabulary, grammar, coherence, structure.
- Focus on PROGRESSION — frame feedback as steps on a journey, not deficiencies.
- Be encouraging but honest. Reference specific phrases from reference essays.
- If step-up or target references are missing, adapt your analysis to work with what is available.

Naturalness — MANDATORY:
- When suggesting improved sentences, ALWAYS prefer natural, idiomatic English over artificially complex vocabulary.
- Do NOT use theatrical or overly formal phrases. For example: "witnessed a substantial surge", "affording them greater latitude", "undoubtedly presents distinct advantages" — these sound unnatural and would NOT impress a real IELTS examiner.
- A Band 7.0 sentence should sound like a well-educated person writing naturally, not someone who swallowed a thesaurus.
- Prefer clear, precise vocabulary over obscure synonyms. "has grown considerably" is better than "has witnessed a substantial surge". "giving them more time for family" is better than "affording them greater latitude to engage with family".
- The gold standard is: natural, fluent, precise, and appropriate for academic writing — NOT maximally complex.

Specificity — MANDATORY:
- In ALL feedback fields (vocabulary_feedback, grammar_feedback, coherence_feedback, task_response_feedback), you MUST quote at least 2 specific phrases from the STUDENT'S essay and explain concretely what is weak about each.
- Do NOT write generic advice like "use more academic vocabulary" or "demonstrate a wider range of complex structures". Instead write something like: "Your phrase 'get better jobs' is too informal for academic writing. A more precise alternative would be 'secure more competitive positions'."
- Every piece of advice must contain a concrete before→after example drawn from the student's actual text.

- Return ONLY valid JSON. No markdown, no code blocks, no extra text."""


async def run_ielts_compare():
    """Run the complete IELTS compare flow."""
    print("="*70)
    print("🇬🇧 IELTS WRITING COMPARE FLOW TEST")
    print("   Grading + Sentence Improvements")
    print("="*70)
    
    # Initialize Groq client
    client = OpenAI(
        api_key=GROQ_API_KEY,
        base_url=GROQ_BASE_URL
    )
    
    # Display student essay info
    print(f"\n📝 STUDENT ESSAY INFO:")
    print(f"   Topic: {SAMPLE_ESSAY['topic'][:80]}...")
    print(f"   Current Band: {SAMPLE_ESSAY['student_band']}")
    print(f"   Task Type: {SAMPLE_ESSAY['task_type']}")
    print(f"   Essay Length: {len(SAMPLE_ESSAY['essay_text'].split())} words")
    
    print(f"\n🔍 RETRIEVING REFERENCE ESSAYS (Simulated Qdrant Search)...")
    print(f"   Step-up references (Band {SAMPLE_ESSAY['student_band'] + 0.5}): {len(REFERENCE_ESSAYS['step_up']['essays'])} essays")
    print(f"   Target references (Band {SAMPLE_ESSAY['student_band'] + 1.5}): {len(REFERENCE_ESSAYS['target']['essays'])} essays")
    
    # Format references
    step_up_refs = format_references(REFERENCE_ESSAYS["step_up"]["essays"], "Step-up")
    target_refs = format_references(REFERENCE_ESSAYS["target"]["essays"], "Target")
    
    # Build prompt
    prompt = get_compare_prompt(
        student_band=SAMPLE_ESSAY["student_band"],
        topic=SAMPLE_ESSAY["topic"],
        essay=SAMPLE_ESSAY["essay_text"],
        step_up_refs=step_up_refs,
        target_refs=target_refs
    )
    
    print(f"\n🤖 CALLING GROQ API (llama-3.3-70b-versatile)...")
    print(f"   Model: {MODEL}")
    print(f"   Temperature: 0.3")
    print(f"   Max Tokens: 2048")
    print()
    
    import time
    start_time = time.time()
    
    response = client.chat.completions.create(
        model=MODEL,
        messages=[
            {"role": "system", "content": "You are an expert IELTS Writing examiner."},
            {"role": "user", "content": prompt}
        ],
        temperature=0.3,
        max_tokens=2048
    )
    
    elapsed = time.time() - start_time
    
    content = response.choices[0].message.content
    tokens_used = response.usage.total_tokens if response.usage else 0
    
    print(f"⏱️  Response time: {elapsed:.2f}s")
    print(f"📊 Tokens used: {tokens_used}")
    print()
    
    # Parse JSON result
    try:
        result = json.loads(content)
    except json.JSONDecodeError as e:
        print(f"❌ JSON Parse Error: {e}")
        print(f"Raw response: {content[:500]}...")
        return
    
    # Display results in chat-like format
    print("="*70)
    print("📋 GRADING RESULTS")
    print("="*70)
    
    print(f"\n🎯 OVERALL ANALYSIS (Band {SAMPLE_ESSAY['student_band']} → Band {SAMPLE_ESSAY['student_band'] + 0.5})")
    print("-"*50)
    print(result.get("overall_analysis", ""))
    
    print(f"\n📚 VOCABULARY FEEDBACK")
    print("-"*50)
    print(result.get("vocabulary_feedback", ""))
    
    print(f"\n🔗 COHERENCE & COHESION FEEDBACK")
    print("-"*50)
    print(result.get("coherence_feedback", ""))
    
    print(f"\n📝 GRAMMAR FEEDBACK")
    print("-"*50)
    print(result.get("grammar_feedback", ""))
    
    print(f"\n✅ TASK RESPONSE FEEDBACK")
    print("-"*50)
    print(result.get("task_response_feedback", ""))
    
    print(f"\n🚀 KEY IMPROVEMENTS TO REACH BAND {SAMPLE_ESSAY['student_band'] + 0.5}")
    print("-"*50)
    for i, improvement in enumerate(result.get("key_improvements", []), 1):
        print(f"   {i}. {improvement}")
    
    print(f"\n💡 STEP-UP ANALYSIS (How to reach Band {SAMPLE_ESSAY['student_band'] + 0.5})")
    print("-"*50)
    print(result.get("step_up_analysis", ""))
    
    print(f"\n🎯 TARGET ANALYSIS (Band {SAMPLE_ESSAY['student_band'] + 1.5} goals)")
    print("-"*50)
    print(result.get("target_analysis", ""))
    
    # Sentence Comparisons - the main feature!
    print()
    print("="*70)
    print("✍️  SENTENCE IMPROVEMENTS (Interactive Chat Style)")
    print("="*70)
    
    sentence_comparisons = result.get("sentence_comparisons", [])
    
    if sentence_comparisons:
        print(f"\n📝 Found {len(sentence_comparisons)} sentences to improve:\n")
        
        for i, comparison in enumerate(sentence_comparisons, 1):
            original = comparison.get("original", "")
            improved = comparison.get("improved", "")
            explanation = comparison.get("explanation", "")
            category = comparison.get("category", "general")
            
            print(f"🔹 IMPROVEMENT #{i} [{category.upper()}]")
            print()
            
            print("   📌 ORIGINAL:")
            print(f"   \"{original}\"")
            print()
            
            print("   ✨ IMPROVED:")
            print(f"   \"{improved}\"")
            print()
            
            print("   💡 WHY:")
            print(f"   {explanation}")
            print()
            print("   " + "-"*60)
            print()
    else:
        print("\n⚠️  No sentence comparisons returned.")
    
    # Final summary
    print()
    print("="*70)
    print("📊 SUMMARY")
    print("="*70)
    print(f"   Current Band: {SAMPLE_ESSAY['student_band']}")
    print(f"   Next Target: {SAMPLE_ESSAY['student_band'] + 0.5}")
    print(f"   Stretch Goal: {SAMPLE_ESSAY['student_band'] + 1.5}")
    print(f"   Processing Time: {elapsed:.2f}s")
    print(f"   Tokens Used: {tokens_used}")
    print(f"   Sentence Improvements: {len(sentence_comparisons)}")
    print()
    print("✅ Flow completed successfully!")


if __name__ == "__main__":
    asyncio.run(run_ielts_compare())
