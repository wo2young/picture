from datetime import datetime
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.models.album import Album
from app.models.user import AppUser
from app.services.family_service import get_my_family


# =========================
# 앨범 생성
# =========================
async def create_album(
    db: AsyncSession,
    user: AppUser,
    title: str,
    description: str | None,
    folder_id: int | None,
):
    family = await get_my_family(db, user)
    if not family:
        raise Exception("Family not found")

    album = Album(
        family_id=family.id,
        title=title,
        description=description,
        folder_id=folder_id,
    )
    db.add(album)
    await db.commit()
    await db.refresh(album)
    return album


# =========================
# 앨범 목록 조회 (내 family)
# =========================
async def get_albums(
    db: AsyncSession,
    user: AppUser,
):
    family = await get_my_family(db, user)
    if not family:
        return []

    result = await db.execute(
        select(Album)
        .where(
            Album.family_id == family.id,
            Album.deleted_at.is_(None),
        )
        .order_by(Album.created_at.desc())
    )
    return result.scalars().all()


# =========================
# 폴더별 앨범 조회
# =========================
async def get_albums_by_folder(
    db: AsyncSession,
    user: AppUser,
    folder_id: int,
):
    family = await get_my_family(db, user)
    if not family:
        return []

    result = await db.execute(
        select(Album)
        .where(
            Album.family_id == family.id,
            Album.folder_id == folder_id,
            Album.deleted_at.is_(None),
        )
        .order_by(Album.created_at.desc())
    )
    return result.scalars().all()


# =========================
# 앨범 단건 조회
# =========================
async def get_album(
    db: AsyncSession,
    user: AppUser,
    album_id: int,
):
    family = await get_my_family(db, user)
    if not family:
        return None

    result = await db.execute(
        select(Album)
        .where(
            Album.id == album_id,
            Album.family_id == family.id,
            Album.deleted_at.is_(None),
        )
    )
    return result.scalar_one_or_none()


# =========================
# 앨범 삭제 (Soft Delete)
# =========================
async def delete_album(
    db: AsyncSession,
    user: AppUser,
    album_id: int,
) -> bool:
    album = await get_album(db, user, album_id)
    if not album:
        return False

    album.deleted_at = datetime.utcnow()
    await db.commit()
    return True
