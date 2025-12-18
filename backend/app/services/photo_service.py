from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, update
from datetime import datetime

from app.models.photo import Photo


# -------------------------------
# 사진 생성
# -------------------------------
async def create_photo(db: AsyncSession, data: dict):
    photo = Photo(
        album_id=data["album_id"],
        uploader_id=data["uploader_id"],
        original_url=data["original_url"],
        thumbnail_url=data["thumbnail_url"],
        description=data.get("description"),
        place=data.get("place"),
        taken_at=data.get("taken_at"),
    )

    db.add(photo)
    await db.flush()        # photo.id 확보
    await db.commit()
    await db.refresh(photo)

    return {
        "id": photo.id,
        "created_at": photo.created_at,
    }


# -------------------------------
# 사진 단건 조회
# -------------------------------
async def get_photo(db: AsyncSession, photo_id: int):
    stmt = (
        select(Photo)
        .where(
            Photo.id == photo_id,
            Photo.deleted_at.is_(None),
        )
    )

    result = await db.execute(stmt)
    return result.scalar_one_or_none()


# -------------------------------
# 앨범별 사진 목록 조회
# -------------------------------
async def list_photos_by_album(db: AsyncSession, album_id: int):
    stmt = (
        select(Photo)
        .where(
            Photo.album_id == album_id,
            Photo.deleted_at.is_(None),
        )
        .order_by(Photo.created_at.desc())
    )

    result = await db.execute(stmt)
    return result.scalars().all()


# -------------------------------
# 사진 삭제 (soft delete)
# -------------------------------
async def delete_photo(db: AsyncSession, photo_id: int):
    await db.execute(
        update(Photo)
        .where(Photo.id == photo_id)
        .values(deleted_at=datetime.utcnow())
    )

    await db.commit()
    return {"deleted": True}
