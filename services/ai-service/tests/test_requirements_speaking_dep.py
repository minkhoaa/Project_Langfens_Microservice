"""Regression guard for the langchain-google-genai requirement.

Out-of-scope speaking code (app/services/roleplay_chat_service.py) imports
`ChatGoogleGenerativeAI` from this package. If `langchain-google-genai` is
removed from requirements.txt before that code is migrated to Groq, the first
real call to a speaking endpoint will raise ImportError. This test asserts the
dependency is present in requirements.txt until the speaking provider cleanup
task removes both the import and the entry together.
"""
from __future__ import annotations

from pathlib import Path


def test_requirements_lists_langchain_google_genai_for_speaking():
    req_path = (
        Path(__file__).resolve().parent.parent / "requirements.txt"
    )
    content = req_path.read_text()
    assert "langchain-google-genai" in content, (
        "langchain-google-genai is still imported by "
        "app/services/roleplay_chat_service.py (out of scope). Remove it "
        "only when the speaking provider cleanup task also removes the import."
    )
