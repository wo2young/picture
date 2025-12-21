from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, update
from datetime import datetime

from app.models.photo import Photo
from app.models.album import Album
from app.models.user import AppUser
from app.services.family_service import get_my_family


# -------------------------------
# 사진 생성 (토큰 기반)
# -------------------------------
async def create_photo(
    db: AsyncSession,
    user: AppUser,
    album_id: int,
    original_url: str,
    thumbnail_url: str,
    description: str | None = None,
    place: str | None = None,
    taken_at=None,
):
    # 1️⃣ 내 가족 확인
    family = await get_my_family(db, user)
    if not family:
        raise Exception("Family not found")

    # 2️⃣ 앨범 소속 검증 (보안 핵심)
    result = await db.execute(
        select(Album)
        .where(
            Album.id == album_id,
            Album.family_id == family.id,
            Album.deleted_at.is_(None),
        )
    )
    album = result.scalar_one_or_none()
    if not album:
        raise Exception("Album not found or access denied")

    # 3️⃣ 사진 생성
    photo = Photo(
        album_id=album_id,
        uploader_id=user.id,   # ✅ 자동 주입
        original_url=original_url,
        thumbnail_url=thumbnail_url,
        description=description,
        place=place,
        taken_at=taken_at,
    )

    db.add(photo)
    await db.commit()
    await db.refresh(photo)
    return photo


# -------------------------------
# 사진 단건 조회 (내 가족만)
# -------------------------------
async def get_photo(
    db: AsyncSession,
    user: AppUser,
    photo_id: int,
):
    family = await get_my_family(db, user)
    if not family:
        return None

    result = await db.execute(
        select(Photo)
        .join(Album, Photo.album_id == Album.id)
        .where(
            Photo.id == photo_id,
            Album.family_id == family.id,
            Photo.deleted_at.is_(None),
        )
    )
    return result.scalar_one_or_none()


# -------------------------------
# 앨범별 사진 목록 (내 가족)
# -------------------------------
async def list_photos_by_album(
    db: AsyncSession,
    user: AppUser,
    album_id: int,
):
    family = await get_my_family(db, user)
    if not family:
        return []

    result = await db.execute(
        select(Photo)
        .join(Album, Photo.album_id == Album.id)
        .where(
            Album.family_id == family.id,
            Photo.album_id == album_id,
            Photo.deleted_at.is_(None),
        )
        .order_by(Photo.created_at.desc())
    )
    return result.scalars().all()


# -------------------------------
# 사진 삭제 (soft delete, 내 가족만)
# -------------------------------
async def delete_photo(
    db: AsyncSession,
    user: AppUser,
    photo_id: int,
):
    photo = await get_photo(db, user, photo_id)
    if not photo:
        return False

    await db.execute(
        update(Photo)
        .where(Photo.id == photo_id)
        .values(deleted_at=datetime.utcnow())
    )
    await db.commit()
    return True
