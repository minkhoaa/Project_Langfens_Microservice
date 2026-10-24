"""Editorial research services; deliberately independent of Reading execution."""
from functools import lru_cache

from app.curation.curation import CurationManager
from app.curation.export import DatasetExporter
from app.offline_eval.comparison import PairedOfflineComparator
from app.offline_eval.runner import OfflineEvalRunner
from app.promotion.promotion import VersionPromotionManager
from app.promotion.registry import PromptVersionRegistry


class EditorialServices:
    def __init__(self) -> None:
        self.curation_manager = CurationManager()
        self.dataset_exporter = DatasetExporter()
        self.eval_runner = OfflineEvalRunner(comparator=PairedOfflineComparator())
        self.prompt_registry = PromptVersionRegistry()
        self.promotion_manager = VersionPromotionManager(registry=self.prompt_registry)

    def bind_run(self, run_id: str) -> str:
        return self.prompt_registry.get_version_for_run(run_id)

    def compute_solver_cache_key(self, run_id: str, content_hash: str) -> str:
        prompt_version = self.bind_run(run_id)
        return f"{prompt_version}:{prompt_version}:v2:{content_hash}"


@lru_cache(maxsize=1)
def get_editorial_services() -> EditorialServices:
    return EditorialServices()
