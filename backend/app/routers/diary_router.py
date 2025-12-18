from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.schemas.diary_schema import DiaryCreate, DiaryUpdate
from app.services.diary_service import (
    create_diary,
    list_diaries_by_family,
    update_diary,
    delete_diary,
    get_diary_with_photos,
)

router = APIRouter(prefix="/diaries", tags=["Diary"])


# -------------------------------
# 일기 생성
# -------------------------------
@router.post("/", summary="일기 생성")
async def create_diary_api(
    payload: DiaryCreate,
    db: AsyncSession = Depends(get_db),
):
    return await create_diary(db, payload.dict())


# -------------------------------
# 가족별 일기 목록
# -------------------------------
@router.get("/family/{family_id}", summary="가족별 일기 목록")
async def list_diaries_api(
    family_id: int,
    db: AsyncSession = Depends(get_db),
):
    return await list_diaries_by_family(db, family_id)


# -------------------------------
# 일기 상세 조회 (+ 사진)
# -------------------------------
@router.get("/{diary_id}", summary="일기 상세 조회 (+ 사진)")
async def get_diary_detail(
    diary_id: int,
    db: AsyncSession = Depends(get_db),
):
    diary = await get_diary_with_photos(db, diary_id)

    if not diary:
        raise HTTPException(status_code=404, detail="Diary not found")

    return diary


# -------------------------------
# 일기 수정
# -------------------------------
@router.put("/{diary_id}", summary="일기 수정")
async def update_diary_api(
    diary_id: int,
    payload: DiaryUpdate,
    db: AsyncSession = Depends(get_db),
):
    return await update_diary(db, diary_id, payload.dict())


# -------------------------------
# 일기 삭제 (soft delete)
# -------------------------------
@router.delete("/{diary_id}", summary="일기 삭제")
async def delete_diary_api(
    diary_id: int,
    db: AsyncSession = Depends(get_db),
):
    return await delete_diary(db, diary_id)
