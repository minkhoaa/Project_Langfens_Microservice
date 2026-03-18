from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    environment: str = "development"
    qdrant_host: str = "localhost"
    qdrant_port: int = 6333
    qdrant_grpc_port: int = 6334
    gemini_api_key: str = ""
    gemini_embedding_model: str = "models/gemini-embedding-001"
    qdrant_collection_writing: str = "writing_samples"
    qdrant_collection_grammar: str = "grammar_knowledge"
    redis_host: str = "localhost"
    redis_port: int = 6379
    data_dir: str = "/app/data"
    gemini_chat_model: str = "gemini-2.5-flash"
    gemini_chat_temperature: float = 0.3
    gemini_chat_max_tokens: int = 8192
    gemini_chat_timeout: int = 60

    class Config:
        env_file = ".env"
        case_sensitive = False


settings = Settings()
