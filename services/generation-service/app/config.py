import os
from pathlib import Path

from pydantic_settings import BaseSettings, SettingsConfigDict

_env_file_override = os.environ.get("GENERATION_SERVICE_ENV_FILE") or os.environ.get("AI_SERVICE_ENV_FILE")
if _env_file_override:
    _default_env_file = _env_file_override
else:
    _deploy_env = (
        Path(__file__).resolve().parent.parent.parent.parent
        / "deploy"
        / "envs"
        / "ai.env"
    )
    _default_env_file = str(_deploy_env) if _deploy_env.is_file() else None


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        extra="ignore",
        env_file=_default_env_file,
        env_file_encoding="utf-8",
    )

    environment: str = "development"
    port: int = 8080

    # MiniMax
    minimax_base_url: str = "https://api.minimaxi.chat/v1"
    minimax_model: str = "MiniMax-Text-01"
    minimax_api_key: str = ""
    minimax_api_keys: str = ""

    # Groq fallback
    groq_base_url: str = "https://api.groq.com/openai/v1"
    groq_model: str = "openai/gpt-oss-20b"
    groq_api_key: str = ""
    groq_api_keys: str = ""

    llm_provider_order: str = "minimax,groq"
    openalex_api_key: str = ""

    # Loop Runtime Caps (G06 caps hotfix / production configuration)
    loop_max_versions: int = 3
    loop_max_generated_versions: int = 3
    loop_max_repair_attempts_per_version: int = 2
    loop_max_total_repairs: int = 5
    loop_max_consecutive_no_progress: int = 2
    loop_max_oscillation_cycles: int = 2
    loop_max_total_calls: int = 15
    loop_max_total_tokens: int = 60_000
    loop_max_wall_time_seconds: float = 300.0
    loop_generate_token_reservation: int = 2500
    loop_evaluate_token_reservation: int = 1000
    loop_repair_token_reservation: int = 1500
    loop_operation_wall_reservation_seconds: float = 30.0
    loop_min_score_threshold: float = 0.8

    # Evaluator & Repair Caps (Phase 07)
    evaluator_deterministic_timeout_seconds: float = 5.0
    evaluator_semantic_timeout_seconds: float = 30.0
    evaluator_stage_timeout_seconds: float = 60.0
    evaluator_max_tokens_per_evaluation: int = 4000
    repair_timeout_seconds: float = 30.0
    repair_max_tokens_per_attempt: int = 3000
    evaluation_cache_enabled: bool = True
    evaluation_cache_max_entries: int = 1000


settings = Settings()
