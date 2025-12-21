from fastapi import APIRouter, UploadFile, File, Depends, Form, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.core.deps import get_current_user
from app.models.user import AppUser
from app.services.azure_service import upload_to_azure
from app.services.photo_service import (
    create_photo,
    list_photos_by_album,
    delete_photo,
    get_photo,
)
from app.services.diary_service import get_photo_with_diaries

router = APIRouter(prefix="/photos", tags=["Photo"])


# -------------------------------
# 사진 업로드 + DB 저장 (토큰 기반)
# -------------------------------
@router.post("/upload", summary="사진 업로드 + DB 저장")
async def upload_photo(
    file: UploadFile = File(...),
    album_id: int = Form(...),
    description: str | None = Form(None),
    place: str | None = Form(None),
    db: AsyncSession = Depends(get_db),
    user: AppUser = Depends(get_current_user),
):
    # 1️⃣ Azure 업로드
    image_url = await upload_to_azure(file)

    # 2️⃣ DB 저장 (user 자동 주입)
    photo = await create_photo(
        db=db,
        user=user,
        album_id=album_id,
        original_url=image_url,
        thumbnail_url=image_url,
        description=description,
        place=place,
    )
    return photo


# -------------------------------
# 사진 상세 조회 (+ 연결된 일기)
# -------------------------------
@router.get("/{photo_id}", summary="사진 상세 조회")
async def get_photo_detail(
    photo_id: int,
    db: AsyncSession = Depends(get_db),
    user: AppUser = Depends(get_current_user),
):
    photo = await get_photo_with_diaries(db, user, photo_id)
    if not photo:
        raise HTTPException(status_code=404, detail="Photo not found")
    return photo


# -------------------------------
# 앨범별 사진 목록 (내 가족)
# -------------------------------
@router.get("/album/{album_id}", summary="앨범별 사진 목록")
async def list_photos_album(
    album_id: int,
    db: AsyncSession = Depends(get_db),
    user: AppUser = Depends(get_current_user),
):
    return await list_photos_by_album(db, user, album_id)


# -------------------------------
# 사진 삭제 (soft delete, 내 가족만)
# -------------------------------
@router.delete("/{photo_id}", summary="사진 삭제")
async def delete_photo_api(
    photo_id: int,
    db: AsyncSession = Depends(get_db),
    user: AppUser = Depends(get_current_user),
):
    ok = await delete_photo(db, user, photo_id)
    if not ok:
        raise HTTPException(status_code=404, detail="Photo not found")
    return {"result": "ok"}
