from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.schemas.album_schema import AlbumCreate, AlbumResponse
from app.services.album_service import (
    create_album,
    get_albums,
    get_albums_by_folder,
    get_album,
    delete_album,
)
from app.core.deps import get_current_user
from app.models.user import AppUser

router = APIRouter(
    prefix="/albums",
    tags=["Album"],
)


# =========================
# 앨범 생성 (토큰 기반)
# =========================
@router.post("", response_model=AlbumResponse)
async def create_album_api(
    data: AlbumCreate,
    db: AsyncSession = Depends(get_db),
    user: AppUser = Depends(get_current_user),
):
    return await create_album(
        db=db,
        user=user,
        title=data.title,
        description=data.description,
        folder_id=data.folder_id,
    )


# =========================
# 앨범 목록 조회 (내 family 기준)
# =========================
@router.get("", response_model=list[AlbumResponse])
async def get_albums_api(
    db: AsyncSession = Depends(get_db),
    user: AppUser = Depends(get_current_user),
):
    return await get_albums(db=db, user=user)


# =========================
# 폴더별 앨범 조회 (내 family + folder)
# =========================
@router.get("/folder/{folder_id}", response_model=list[AlbumResponse])
async def get_albums_by_folder_api(
    folder_id: int,
    db: AsyncSession = Depends(get_db),
    user: AppUser = Depends(get_current_user),
):
    return await get_albums_by_folder(
        db=db,
        user=user,
        folder_id=folder_id,
    )


# =========================
# 앨범 단건 조회
# =========================
@router.get("/{album_id}", response_model=AlbumResponse)
async def get_album_api(
    album_id: int,
    db: AsyncSession = Depends(get_db),
    user: AppUser = Depends(get_current_user),
):
    album = await get_album(db=db, user=user, album_id=album_id)
    if not album:
        raise HTTPException(status_code=404, detail="Album not found")
    return album


# =========================
# 앨범 삭제
# =========================
@router.delete("/{album_id}")
async def delete_album_api(
    album_id: int,
    db: AsyncSession = Depends(get_db),
    user: AppUser = Depends(get_current_user),
):
    ok = await delete_album(db=db, user=user, album_id=album_id)
    if not ok:
        raise HTTPException(status_code=404, detail="Album not found")
    return {"result": "ok"}
