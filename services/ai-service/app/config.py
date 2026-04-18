from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    environment: str = "development"
    qdrant_host: str = "localhost"
    qdrant_port: int = 6333
    qdrant_grpc_port: int = 6334
    qdrant_endpoint: str = ""
    qdrant_api_key: str = ""
    qdrant_collection_writing: str = "writing_samples"
    qdrant_collection_grammar: str = "grammar_knowledge"
    redis_host: str = "localhost"
    redis_port: int = 6379
    data_dir: str = "/app/data"
    roleplay_scenarios_dir: str = "/app/data/scenarios"
    force_reingest: bool = False
    disable_ingestion_on_startup: bool = False

    # Ollama settings (PRIMARY - self-hosted local AI)
    use_ollama: bool = True
    use_openai_like: bool = False
    ollama_base_url: str = "http://localhost:11434"
    ollama_model: str = "deepseek-v2:16b"
    ollama_embed_model: str = "bge-m3"
    ollama_embed_dimensions: int = 1024
    ollama_temperature: float = 0.3
    ollama_timeout: int = 120

    # Legacy fallbacks kept for explicit runtime switches.
    gemini_api_key: str = ""
    gemini_chat_model: str = "gemini-2.5-flash"
    gemini_chat_temperature: float = 0.3
    gemini_chat_max_tokens: int = 12288
    gemini_chat_timeout: int = 60

    class Config:
        env_file = ".env"
        case_sensitive = False
        extra = "ignore"


settings = Settings()
