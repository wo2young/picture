from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.core.deps import get_current_user
from app.models.user import AppUser
from app.schemas.diary_schema import DiaryCreate, DiaryUpdate, DiaryResponse
from app.services.diary_service import (
    create_diary,
    list_diaries,
    get_diary,
    update_diary,
    delete_diary,
    get_photo_with_diaries,
)

router = APIRouter(prefix="/diaries", tags=["Diary"])


@router.post("", response_model=DiaryResponse)
async def create_diary_api(
    payload: DiaryCreate,
    db: AsyncSession = Depends(get_db),
    user: AppUser = Depends(get_current_user),
):
    return await create_diary(db, user, **payload.dict())


@router.get("", response_model=list[DiaryResponse])
async def list_diaries_api(
    db: AsyncSession = Depends(get_db),
    user: AppUser = Depends(get_current_user),
):
    return await list_diaries(db, user)


@router.get("/{diary_id}", response_model=DiaryResponse)
async def get_diary_detail(
    diary_id: int,
    db: AsyncSession = Depends(get_db),
    user: AppUser = Depends(get_current_user),
):
    diary = await get_diary(db, user, diary_id)
    if not diary:
        raise HTTPException(status_code=404)
    return diary


@router.put("/{diary_id}")
async def update_diary_api(
    diary_id: int,
    payload: DiaryUpdate,
    db: AsyncSession = Depends(get_db),
    user: AppUser = Depends(get_current_user),
):
    ok = await update_diary(db, user, diary_id, **payload.dict())
    if not ok:
        raise HTTPException(status_code=404)
    return {"result": "ok"}


@router.delete("/{diary_id}")
async def delete_diary_api(
    diary_id: int,
    db: AsyncSession = Depends(get_db),
    user: AppUser = Depends(get_current_user),
):
    ok = await delete_diary(db, user, diary_id)
    if not ok:
        raise HTTPException(status_code=404)
    return {"result": "ok"}


@router.get("/photo/{photo_id}")
async def get_photo_diaries(
    photo_id: int,
    db: AsyncSession = Depends(get_db),
    user: AppUser = Depends(get_current_user),
):
    result = await get_photo_with_diaries(db, user, photo_id)
    if not result:
        raise HTTPException(status_code=404)
    return result
