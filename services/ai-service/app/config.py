import os
from pathlib import Path

from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    environment: str = "development"

    # --- Qdrant ---
    qdrant_host: str = "localhost"
    qdrant_port: int = 6333
    qdrant_grpc_port: int = 6334
    qdrant_endpoint: str = ""
    qdrant_api_key: str = ""
    qdrant_collection_writing: str = "writing_samples"
    qdrant_collection_grammar: str = "grammar_knowledge"
    qdrant_collection_speaking_memory: str = "speaking_memory"

    # --- Redis ---
    redis_host: str = "localhost"
    redis_port: int = 6379
    redis_password: str = ""
    redis_ssl: bool = False

    # --- Paths ---
    data_dir: str = "/app/data"
    roleplay_scenarios_dir: str = "/app/data/scenarios"
    force_reingest: bool = False
    disable_ingestion_on_startup: bool = False

    # Ollama settings (PRIMARY - self-hosted local AI)
    use_ollama: bool = True
    use_openai_like: bool = False
    ollama_base_url: str = "http://localhost:11434"
    ollama_model: str = "qwen2.5"
    ollama_embed_model: str = "bge-m3"
    ollama_embed_dimensions: int = 1024
    ollama_temperature: float = 0.3
    ollama_timeout: int = 120

    # Legacy fallbacks kept for explicit runtime switches.
    gemini_api_key: str = ""
    gemini_embedding_model: str = "models/gemini-embedding-001"
    gemini_chat_model: str = "gemini-2.5-flash"
    gemini_chat_temperature: float = 0.3
    gemini_chat_max_tokens: int = 12288
    gemini_chat_timeout: int = 60

    # --- Local LoRA (Qwen2.5 fine-tuned) ---
    # Set USE_LOCAL_LORA=true in ai.env to activate.
    # Set LORA_DEVICE=cpu for local dev without a GPU.
    use_local_lora: bool = False
    lora_model_path: str = "/app/models/qwen25-lora"
    lora_base_model: str = "Qwen/Qwen2.5-1.5B-Instruct"
    # "cuda" | "cpu" | "mps"  — auto falls back to cpu if cuda unavailable
    lora_device: str = "cuda"
    # Enable bitsandbytes 4-bit quant (requires bitsandbytes installed)
    lora_load_in_4bit: bool = False
    lora_max_new_tokens: int = 200
    lora_temperature: float = 0.7
    lora_top_p: float = 0.9
    lora_repetition_penalty: float = 1.1
    
    # --- Local Pronunciation Scorer (Wav2Vec2 fine-tuned) ---
    pronunciation_scorer_path: str = "/app/models/pronunciation-scorer-v2/best_checkpoint.pt"
    pronunciation_device: str = "cpu"

    @property
    def ollama_url(self) -> str:
        """Full URL for POST /api/generate (chat)."""
        return f"{self.ollama_base_url.rstrip('/')}/api/generate"

    @property
    def ollama_embed_url(self) -> str:
        """Full URL for POST /api/embed (embeddings)."""
        return f"{self.ollama_base_url.rstrip('/')}/api/embed"

    class Config:
        # Resolve env_file in this order:
        # 1. AI_SERVICE_ENV_FILE env var (explicit override)
        # 2. <repo>/deploy/envs/ai.env (when running ai-service from a checkout)
        # 3. "" — Docker injects env vars directly via compose's env_file: directive
        @staticmethod
        def _resolve_env_file() -> str:
            override = os.getenv("AI_SERVICE_ENV_FILE")
            if override:
                return override
            here = Path(__file__).resolve()
            for parent in here.parents:
                candidate = parent / "deploy" / "envs" / "ai.env"
                if candidate.is_file():
                    return str(candidate)
            return ""

        env_file = _resolve_env_file()
        case_sensitive = False
        extra = "ignore"


settings = Settings()
