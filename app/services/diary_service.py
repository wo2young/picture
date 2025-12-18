from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, update, delete
from sqlalchemy.orm import selectinload
from datetime import datetime

from app.models.diary import Diary
from app.models.photo import Photo
from app.models.photo_diary import PhotoDiary


# -------------------------------
# 일기 생성 (+ 사진 연결)
# -------------------------------
async def create_diary(db: AsyncSession, data: dict):
    """
    1. diary 생성
    2. photo_diary 테이블에 사진 연결
    """

    diary = Diary(
        family_id=data["family_id"],
        writer_id=data["writer_id"],
        title=data.get("title"),
        content=data["content"],
        diary_date=data["diary_date"],
    )

    db.add(diary)
    await db.flush()  # diary.id 확보

    # 사진 연결
    for photo_id in data.get("photo_ids", []):
        db.add(
            PhotoDiary(
                photo_id=photo_id,
                diary_id=diary.id,
            )
        )

    await db.commit()
    await db.refresh(diary)

    return {
        "id": diary.id,
        "created_at": diary.created_at,
    }


# -------------------------------
# 일기 상세 조회
# -------------------------------
async def get_diary(db: AsyncSession, diary_id: int):
    stmt = (
        select(Diary)
        .where(
            Diary.id == diary_id,
            Diary.deleted_at.is_(None),
        )
    )

    result = await db.execute(stmt)
    return result.scalar_one_or_none()


# -------------------------------
# 가족별 일기 목록 조회
# -------------------------------
async def list_diaries_by_family(db: AsyncSession, family_id: int):
    stmt = (
        select(Diary)
        .where(
            Diary.family_id == family_id,
            Diary.deleted_at.is_(None),
        )
        .order_by(Diary.diary_date.desc(), Diary.created_at.desc())
    )

    result = await db.execute(stmt)
    return result.scalars().all()


# -------------------------------
# 일기 수정 (+ 사진 재연결)
# -------------------------------
async def update_diary(db: AsyncSession, diary_id: int, data: dict):
    stmt = (
        update(Diary)
        .where(
            Diary.id == diary_id,
            Diary.deleted_at.is_(None),
        )
        .values(
            title=data.get("title"),
            content=data.get("content"),
            diary_date=data.get("diary_date"),
            updated_at=datetime.utcnow(),
        )
        .returning(Diary.id)
    )

    result = await db.execute(stmt)
    row = result.fetchone()

    if not row:
        return {"updated": False}

    # photo_ids가 들어온 경우만 처리
    if "photo_ids" in data:
        # 기존 연결 제거
        await db.execute(
            delete(PhotoDiary).where(PhotoDiary.diary_id == diary_id)
        )

        # 새 연결 등록
        for photo_id in data["photo_ids"] or []:
            db.add(
                PhotoDiary(
                    photo_id=photo_id,
                    diary_id=diary_id,
                )
            )

    await db.commit()
    return {"updated": True}


# -------------------------------
# 일기 삭제 (soft delete)
# -------------------------------
async def delete_diary(db: AsyncSession, diary_id: int):
    await db.execute(
        update(Diary)
        .where(Diary.id == diary_id)
        .values(deleted_at=datetime.utcnow())
    )
    await db.commit()
    return {"deleted": True}


# -------------------------------
# 사진 상세 조회 + 연결된 일기
# -------------------------------
async def get_photo_with_diaries(db: AsyncSession, photo_id: int):
    stmt = (
        select(Photo)
        .options(selectinload(Photo.diaries))
        .where(
            Photo.id == photo_id,
            Photo.deleted_at.is_(None),
        )
    )

    result = await db.execute(stmt)
    photo = result.scalar_one_or_none()

    if not photo:
        return None

    return photo
