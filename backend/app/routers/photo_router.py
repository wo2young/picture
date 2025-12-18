from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.schemas.photo_schema import PhotoCreate
from app.services.photo_service import (
    create_photo,
    list_photos_by_album,
    delete_photo,
    get_photo,
)
from app.services.diary_service import get_photo_with_diaries

router = APIRouter(prefix="/photos", tags=["Photo"])


# -------------------------------
# 사진 생성
# -------------------------------
@router.post("/", summary="사진 생성")
async def create_photo_api(
    payload: PhotoCreate,
    db: AsyncSession = Depends(get_db),
):
    return await create_photo(db, payload.dict())


# -------------------------------
# 사진 상세 조회 (+ 연결된 일기)
# -------------------------------
@router.get("/{photo_id}", summary="사진 상세 조회 (+ 연결된 일기)")
async def get_photo_detail(
    photo_id: int,
    db: AsyncSession = Depends(get_db),
):
    photo = await get_photo_with_diaries(db, photo_id)

    if not photo:
        raise HTTPException(status_code=404, detail="Photo not found")

    return photo


# -------------------------------
# 앨범별 사진 목록
# -------------------------------
@router.get("/album/{album_id}", summary="앨범별 사진 목록")
async def list_photos_album(
    album_id: int,
    db: AsyncSession = Depends(get_db),
):
    return await list_photos_by_album(db, album_id)


# -------------------------------
# 사진 삭제 (soft delete)
# -------------------------------
@router.delete("/{photo_id}", summary="사진 삭제 (soft delete)")
async def delete_photo_api(
    photo_id: int,
    db: AsyncSession = Depends(get_db),
):
    return await delete_photo(db, photo_id)
