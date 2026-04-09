#!/usr/bin/env python3
"""
Test script to verify Groq and Cerebras OpenAI-compatible APIs work for IELTS essay grading.
Run from ai-service directory: python scripts/test_free_api_providers.py
"""

import os
import sys
import json
import time
from pathlib import Path

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent))

from openai import OpenAI

# Test configuration
TEST_PROMPTS = {
    "simple": "What is the capital of France? Answer in one sentence.",
    "ielts_simple": """You are an IELTS writing examiner. Grade this essay and provide feedback.
    
Student essay: "In modern society, many people think that education is very important for everyone. I completely agree with this opinion because educated people can contribute more to their communities."
Topic: "Some people believe that education is important for everyone. To what extent do you agree or disagree?"
Band: 6.0

Provide your analysis as JSON:
{"band_score": "estimated band", "feedback": "brief feedback", "key_improvements": ["improvement 1", "improvement 2"]}
""",
    "ielts_full": """You are an expert IELTS Writing examiner helping a student improve. The student's current band is 6.0.

You will compare the student's essay with reference essays at Band 6.5 and 7.0.

<topic>In modern society, many people think that education is very important for everyone. I completely agree with this opinion because educated people can contribute more to their communities.</topic>

<student_essay>
In my opinion, education plays a vital role in everyone's life. Firstly, educated individuals are more likely to secure better employment opportunities. For instance, people with university degrees often earn higher salaries compared to those without. Secondly, education helps people develop critical thinking skills which are essential for making informed decisions.

I believe that governments should invest more in education to ensure everyone has access to quality learning. This investment would lead to a more prosperous and harmonious society.
</student_essay>

<step_up_references>
--- Step-up Essay 1 (Band 6.5) ---
In contemporary society, the significance of education cannot be overstated. Education serves as the foundation for personal and societal development. Individuals who pursue higher education often acquire specialized knowledge and skills that enhance their career prospects and earning potential.

Moreover, education fosters critical thinking and analytical abilities. These competencies enable people to navigate complex challenges and contribute meaningfully to their communities.
</step_up_references>

<target_references>
--- Target Essay 1 (Band 7.0) ---
The importance of education in modern society cannot be underestimated. It is widely acknowledged that education serves as a cornerstone for both individual advancement and societal progress. Well-educated citizens are better equipped to secure employment, contribute to economic growth, and make informed decisions that benefit their communities.

Furthermore, education plays a crucial role in developing critical thinking and analytical reasoning. These skills are essential for addressing complex social challenges and fostering a more prosperous and harmonious society. Governments must therefore prioritize investment in education to ensure equitable access for all members of society.
</target_references>

Provide your analysis as a JSON object with these exact keys:
{"overall_analysis": "overview", "vocabulary_feedback": "feedback", "coherence_feedback": "feedback", "grammar_feedback": "feedback", "task_response_feedback": "feedback", "step_up_analysis": "analysis", "target_analysis": "analysis", "key_improvements": ["improvement 1", "improvement 2", "improvement 3"], "sentence_comparisons": [{"original": "sentence", "improved": "improved", "explanation": "why", "category": "vocabulary"}]}

Return ONLY valid JSON. No markdown, no code blocks, no extra text."""
}


def test_groq():
    """Test Groq API with OpenAI-compatible endpoint."""
    print("\n" + "="*60)
    print("TESTING GROQ API")
    print("="*60)
    
    api_key = os.environ.get("GROQ_API_KEY")
    if not api_key:
        print("❌ GROQ_API_KEY not set in environment")
        print("   Get your key from: https://console.groq.com/keys")
        return None
    
    print(f"✅ API key found: {api_key[:8]}...{api_key[-4:]}")
    
    # Groq OpenAI-compatible endpoint
    client = OpenAI(
        api_key=api_key,
        base_url="https://api.groq.com/openai/v1"
    )
    
    results = {}
    
    # Test 1: Simple prompt
    print("\n--- Test 1: Simple prompt ---")
    try:
        start = time.time()
        response = client.chat.completions.create(
            model="llama-3.3-70b-versatile",
            messages=[{"role": "user", "content": TEST_PROMPTS["simple"]}],
            temperature=0.3,
            max_tokens=100,
        )
        elapsed = time.time() - start
        content = response.choices[0].message.content
        print(f"✅ SUCCESS in {elapsed:.2f}s")
        print(f"   Model: {response.model}")
        print(f"   Response: {content}")
        results["simple"] = {"success": True, "time": elapsed}
    except Exception as e:
        print(f"❌ FAILED: {e}")
        results["simple"] = {"success": False, "error": str(e)}
    
    # Test 2: IELTS simple
    print("\n--- Test 2: IELTS simple prompt ---")
    try:
        start = time.time()
        response = client.chat.completions.create(
            model="llama-3.3-70b-versatile",
            messages=[{"role": "user", "content": TEST_PROMPTS["ielts_simple"]}],
            temperature=0.3,
            max_tokens=500,
        )
        elapsed = time.time() - start
        content = response.choices[0].message.content
        
        # Try to parse JSON
        try:
            json_result = json.loads(content)
            print(f"✅ SUCCESS in {elapsed:.2f}s")
            print(f"   Model: {response.model}")
            print(f"   Parsed JSON: {json.dumps(json_result, indent=2)[:500]}...")
            results["ielts_simple"] = {"success": True, "time": elapsed, "parsed": True}
        except json.JSONDecodeError as je:
            print(f"⚠️ SUCCESS but JSON parse failed: {je}")
            print(f"   Raw response: {content[:300]}...")
            results["ielts_simple"] = {"success": True, "time": elapsed, "parsed": False}
            
    except Exception as e:
        print(f"❌ FAILED: {e}")
        results["ielts_simple"] = {"success": False, "error": str(e)}
    
    # Test 3: IELTS full prompt (larger context)
    print("\n--- Test 3: IELTS full prompt (larger context) ---")
    try:
        start = time.time()
        response = client.chat.completions.create(
            model="llama-3.3-70b-versatile",
            messages=[{"role": "user", "content": TEST_PROMPTS["ielts_full"]}],
            temperature=0.3,
            max_tokens=1000,
        )
        elapsed = time.time() - start
        content = response.choices[0].message.content
        
        # Try to parse JSON
        try:
            json_result = json.loads(content)
            print(f"✅ SUCCESS in {elapsed:.2f}s")
            print(f"   Model: {response.model}")
            print(f"   Tokens used: {response.usage.total_tokens if response.usage else 'N/A'}")
            print(f"   Keys returned: {list(json_result.keys())}")
            results["ielts_full"] = {"success": True, "time": elapsed, "tokens": response.usage.total_tokens if response.usage else None}
        except json.JSONDecodeError as je:
            print(f"⚠️ SUCCESS but JSON parse failed: {je}")
            print(f"   Raw response: {content[:300]}...")
            results["ielts_full"] = {"success": True, "time": elapsed, "parsed": False}
            
    except Exception as e:
        print(f"❌ FAILED: {e}")
        results["ielts_full"] = {"success": False, "error": str(e)}
    
    return results


def test_cerebras():
    """Test Cerebras API with OpenAI-compatible endpoint."""
    print("\n" + "="*60)
    print("TESTING CEREBRAS API")
    print("="*60)
    
    api_key = os.environ.get("CEREBRAS_API_KEY")
    if not api_key:
        print("❌ CEREBRAS_API_KEY not set in environment")
        print("   Get your key from: https://inference.cerebras.ai/")
        return None
    
    print(f"✅ API key found: {api_key[:8]}...{api_key[-4:]}")
    
    # Cerebras OpenAI-compatible endpoint
    client = OpenAI(
        api_key=api_key,
        base_url="https://api.cerebras.ai/openai/v1"
    )
    
    results = {}
    
    # Test 1: Simple prompt
    print("\n--- Test 1: Simple prompt ---")
    try:
        start = time.time()
        response = client.chat.completions.create(
            model="llama-3.3-70b",
            messages=[{"role": "user", "content": TEST_PROMPTS["simple"]}],
            temperature=0.3,
            max_tokens=100,
        )
        elapsed = time.time() - start
        content = response.choices[0].message.content
        print(f"✅ SUCCESS in {elapsed:.2f}s")
        print(f"   Model: {response.model}")
        print(f"   Response: {content}")
        results["simple"] = {"success": True, "time": elapsed}
    except Exception as e:
        print(f"❌ FAILED: {e}")
        results["simple"] = {"success": False, "error": str(e)}
    
    # Test 2: IELTS simple
    print("\n--- Test 2: IELTS simple prompt ---")
    try:
        start = time.time()
        response = client.chat.completions.create(
            model="llama-3.3-70b",
            messages=[{"role": "user", "content": TEST_PROMPTS["ielts_simple"]}],
            temperature=0.3,
            max_tokens=500,
        )
        elapsed = time.time() - start
        content = response.choices[0].message.content
        
        try:
            json_result = json.loads(content)
            print(f"✅ SUCCESS in {elapsed:.2f}s")
            print(f"   Model: {response.model}")
            print(f"   Parsed JSON: {json.dumps(json_result, indent=2)[:500]}...")
            results["ielts_simple"] = {"success": True, "time": elapsed, "parsed": True}
        except json.JSONDecodeError as je:
            print(f"⚠️ SUCCESS but JSON parse failed: {je}")
            print(f"   Raw response: {content[:300]}...")
            results["ielts_simple"] = {"success": True, "time": elapsed, "parsed": False}
            
    except Exception as e:
        print(f"❌ FAILED: {e}")
        results["ielts_simple"] = {"success": False, "error": str(e)}
    
    # Test 3: IELTS full prompt
    print("\n--- Test 3: IELTS full prompt (larger context) ---")
    try:
        start = time.time()
        response = client.chat.completions.create(
            model="llama-3.3-70b",
            messages=[{"role": "user", "content": TEST_PROMPTS["ielts_full"]}],
            temperature=0.3,
            max_tokens=1000,
        )
        elapsed = time.time() - start
        content = response.choices[0].message.content
        
        try:
            json_result = json.loads(content)
            print(f"✅ SUCCESS in {elapsed:.2f}s")
            print(f"   Model: {response.model}")
            print(f"   Tokens used: {response.usage.total_tokens if response.usage else 'N/A'}")
            print(f"   Keys returned: {list(json_result.keys())}")
            results["ielts_full"] = {"success": True, "time": elapsed, "tokens": response.usage.total_tokens if response.usage else None}
        except json.JSONDecodeError as je:
            print(f"⚠️ SUCCESS but JSON parse failed: {je}")
            print(f"   Raw response: {content[:300]}...")
            results["ielts_full"] = {"success": True, "time": elapsed, "parsed": False}
            
    except Exception as e:
        print(f"❌ FAILED: {e}")
        results["ielts_full"] = {"success": False, "error": str(e)}
    
    return results


def main():
    print("="*60)
    print("FREE API PROVIDER TEST - IELTS GRADING USE CASE")
    print("="*60)
    
    all_results = {}
    
    # Test Groq
    groq_results = test_groq()
    if groq_results:
        all_results["groq"] = groq_results
    
    # Test Cerebras
    cerebras_results = test_cerebras()
    if cerebras_results:
        all_results["cerebras"] = cerebras_results
    
    # Summary
    print("\n" + "="*60)
    print("SUMMARY")
    print("="*60)
    
    for provider, results in all_results.items():
        print(f"\n{provider.upper()}:")
        for test_name, result in results.items():
            status = "✅" if result.get("success") else "❌"
            time_str = f" ({result.get('time', 0):.2f}s)" if result.get('success') else ""
            parsed_str = " [JSON]" if result.get('parsed') else ""
            print(f"  {status} {test_name}{time_str}{parsed_str}")
    
    # Recommendations
    print("\n" + "="*60)
    print("RECOMMENDATIONS")
    print("="*60)
    
    groq_success = all_results.get("groq", {}).get("ielts_full", {}).get("success", False)
    cerebras_success = all_results.get("cerebras", {}).get("ielts_full", {}).get("success", False)
    
    if groq_success:
        print("✅ Groq: RECOMMENDED - Works with OpenAI-compatible API, llama-3.3-70b-versatile")
        print("   - 128K context (vs Cerebras 8K)")
        print("   - Use base_url='https://api.groq.com/openai/v1'")
    else:
        print("❌ Groq: NOT WORKING - Check API key and rate limits")
    
    if cerebras_success:
        print("✅ Cerebras: SECONDARY OPTION - Works but context limited to 8K")
        print("   - Higher token quota (1M/day vs 100K/day for 70B on Groq)")
        print("   - Use base_url='https://api.cerebras.ai/openai/v1'")
    elif cerebras_success is None:
        print("⚠️ Cerebras: API key not configured")
    else:
        print("❌ Cerebras: NOT WORKING - Check API key and rate limits")


if __name__ == "__main__":
    main()
