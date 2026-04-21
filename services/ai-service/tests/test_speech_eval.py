"""
tests/test_speech_eval.py
=========================
Unit tests for the three composable functions in speech_eval_service.
Does NOT require actual audio; tests with synthetic data where possible.

Run:
    pytest tests/test_speech_eval.py -v
"""

import io
import struct
import wave

import pytest


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _make_silent_wav(duration_s: float = 1.0, sample_rate: int = 16_000) -> bytes:
    """Generate a minimal PCM WAV in memory (silence)."""
    n_samples = int(duration_s * sample_rate)
    buf = io.BytesIO()
    with wave.open(buf, "wb") as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)  # 16-bit
        wf.setframerate(sample_rate)
        wf.writeframes(b"\x00\x00" * n_samples)
    return buf.getvalue()


# ---------------------------------------------------------------------------
# compare_text
# ---------------------------------------------------------------------------

from app.services.speech_eval_service import compare_text, WordError


class TestCompareText:
    def test_perfect_match(self):
        errors = compare_text("hello world", "hello world")
        assert errors == []

    def test_missing_word(self):
        errors = compare_text("hello", "hello world")
        assert len(errors) == 1
        assert errors[0].type == "missing"
        assert errors[0].word == "world"

    def test_incorrect_word(self):
        errors = compare_text("hello earth", "hello world")
        assert any(e.type == "incorrect" for e in errors)

    def test_empty_target(self):
        errors = compare_text("anything", "")
        assert errors == []

    def test_case_and_punctuation_ignored(self):
        errors = compare_text("Hello, World!", "hello world")
        assert errors == []

    def test_all_missing(self):
        errors = compare_text("", "hello world")
        words = {e.word for e in errors}
        assert "hello" in words
        assert "world" in words
        assert all(e.type == "missing" for e in errors)


# ---------------------------------------------------------------------------
# compute_score
# ---------------------------------------------------------------------------

from app.services.speech_eval_service import compute_score


class TestComputeScore:
    def test_score_range(self):
        wav = _make_silent_wav()
        score = compute_score(wav, "hello world", "hello world", [])
        assert 0.0 <= score <= 1.0

    def test_no_target_gives_high_text_score(self):
        wav = _make_silent_wav()
        score = compute_score(wav, "hello world", "", [])
        # text_score = 1.0 → final ≥ 0.6
        assert score >= 0.5

    def test_all_errors_lowers_score(self):
        wav = _make_silent_wav()
        errors = [
            WordError(word="hello", type="missing"),
            WordError(word="world", type="missing"),
        ]
        score = compute_score(wav, "", "hello world", errors)
        assert score < 0.8  # penalised significantly


# ---------------------------------------------------------------------------
# FastAPI endpoint integration (httpx TestClient)
# ---------------------------------------------------------------------------

from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)


class TestEvaluateEndpoint:
    def test_empty_file_rejected(self):
        resp = client.post(
            "/api/v1/speech/evaluate",
            files={"audio": ("test.wav", b"", "audio/wav")},
        )
        assert resp.status_code == 422

    def test_valid_wav_no_target(self):
        wav = _make_silent_wav()
        resp = client.post(
            "/api/v1/speech/evaluate",
            files={"audio": ("test.wav", wav, "audio/wav")},
        )
        assert resp.status_code == 200
        body = resp.json()
        assert "transcript" in body
        assert "errors" in body
        assert "score" in body
        assert 0.0 <= body["score"] <= 1.0

    def test_valid_wav_with_target(self):
        wav = _make_silent_wav()
        resp = client.post(
            "/api/v1/speech/evaluate",
            files={"audio": ("test.wav", wav, "audio/wav")},
            data={"target": "hello world"},
        )
        assert resp.status_code == 200
        body = resp.json()
        for err in body["errors"]:
            assert err["type"] in ("missing", "incorrect")
