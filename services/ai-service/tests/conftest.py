import sys
from unittest.mock import MagicMock

# Mock optional heavy ML dependencies if not installed in current test environment
OPTIONAL_MODULES = [
    "torch",
    "torchaudio",
    "transformers",
    "peft",
    "accelerate",
    "faster_whisper",
    "scipy",
    "langchain_ollama",
    "langchain_google_genai",
    "sentence_transformers",
]

for mod in OPTIONAL_MODULES:
    if mod not in sys.modules:
        try:
            __import__(mod)
        except ImportError:
            sys.modules[mod] = MagicMock()
