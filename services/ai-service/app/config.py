from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    environment: str = "development"
    qdrant_host: str = "localhost"
    qdrant_port: int = 6333
    qdrant_grpc_port: int = 6334
    gemini_api_key: str = ""
    redis_host: str = "localhost"
    redis_port: int = 6379

    class Config:
        env_file = ".env"
        case_sensitive = False


settings = Settings()
