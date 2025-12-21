from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.schemas.family_schema import (
    FamilyCreate,
    FamilyResponse,
)
from app.services.family_service import (
    create_family,
    get_my_families,
)
from app.core.deps import get_current_user
from app.models.user import AppUser

router = APIRouter(prefix="/families", tags=["Family"])


@router.post("", response_model=FamilyResponse)
async def create(
    payload: FamilyCreate,
    db: AsyncSession = Depends(get_db),
    user: AppUser = Depends(get_current_user),
):
    return await create_family(
        db=db,
        user=user,
        name=payload.name,
        family_type=payload.type,
    )


@router.get("", response_model=list[FamilyResponse])
async def my_families(
    db: AsyncSession = Depends(get_db),
    user: AppUser = Depends(get_current_user),
):
    return await get_my_families(db, user)
