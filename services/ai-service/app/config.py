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

    @property
    def ollama_url(self) -> str:
        """Full URL for POST /api/generate (chat)."""
        return f"{self.ollama_base_url.rstrip('/')}/api/generate"

    @property
    def ollama_embed_url(self) -> str:
        """Full URL for POST /api/embed (embeddings)."""
        return f"{self.ollama_base_url.rstrip('/')}/api/embed"

    class Config:
        env_file = "/home/khoi/Projects/Project_Langfens_Microservice/deploy/envs/ai.env"
        case_sensitive = False
        extra = "ignore"


settings = Settings()
