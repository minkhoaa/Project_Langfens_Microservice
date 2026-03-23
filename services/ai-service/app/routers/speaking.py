from fastapi import APIRouter

from app.schemas import RoleplayScenariosResponse
from app.services.roleplay_scenario_service import load_scenarios

router = APIRouter(prefix="/v1/speaking/roleplay")


@router.get("/scenarios", response_model=RoleplayScenariosResponse)
async def list_roleplay_scenarios():
    scenarios = load_scenarios()
    return RoleplayScenariosResponse(scenarios=scenarios, total=len(scenarios))
