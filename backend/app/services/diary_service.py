from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, update, delete
from datetime import datetime

from app.models.diary import Diary
from app.models.photo import Photo
from app.models.album import Album
from app.models.photo_diary import PhotoDiary
from app.models.user import AppUser
from app.services.family_service import get_my_family


# -------------------------------
# 일기 생성 (+ 사진 연결)
# -------------------------------
async def create_diary(
    db: AsyncSession,
    user: AppUser,
    title: str,
    content: str,
    diary_date,
    photo_ids: list[int] | None = None,
):
    # 1️⃣ 가족 확인
    family = await get_my_family(db, user)
    if not family:
        raise Exception("Family not found")

    # 2️⃣ 일기 생성
    diary = Diary(
        family_id=family.id,
        author_id=user.id,
        title=title,
        content=content,
        diary_date=diary_date,
    )
    db.add(diary)
    await db.flush()  # diary.id 확보

    # 3️⃣ 사진 연결 (있다면)
    if photo_ids:
        result = await db.execute(
            select(Photo)
            .join(Album, Photo.album_id == Album.id)
            .where(
                Photo.id.in_(photo_ids),
                Album.family_id == family.id,
                Photo.deleted_at.is_(None),
            )
        )
        photos = result.scalars().all()

        if len(photos) != len(photo_ids):
            raise Exception("Invalid photo included")

        for photo in photos:
            db.add(
                PhotoDiary(
                    photo_id=photo.id,
                    diary_id=diary.id,
                )
            )

    await db.commit()
    await db.refresh(diary)
    return diary


# -------------------------------
# 일기 단건 조회 (내 가족)
# -------------------------------
async def get_diary(
    db: AsyncSession,
    user: AppUser,
    diary_id: int,
):
    family = await get_my_family(db, user)
    if not family:
        return None

    result = await db.execute(
        select(Diary)
        .where(
            Diary.id == diary_id,
            Diary.family_id == family.id,
            Diary.deleted_at.is_(None),
        )
    )
    return result.scalar_one_or_none()


# -------------------------------
# 내 가족 일기 목록
# -------------------------------
async def list_diaries(
    db: AsyncSession,
    user: AppUser,
):
    family = await get_my_family(db, user)
    if not family:
        return []

    result = await db.execute(
        select(Diary)
        .where(
            Diary.family_id == family.id,
            Diary.deleted_at.is_(None),
        )
        .order_by(Diary.diary_date.desc(), Diary.created_at.desc())
    )
    return result.scalars().all()


# -------------------------------
# 일기 수정 (+ 사진 재연결)
# -------------------------------
async def update_diary(
    db: AsyncSession,
    user: AppUser,
    diary_id: int,
    title: str | None = None,
    content: str | None = None,
    diary_date=None,
    photo_ids: list[int] | None = None,
):
    diary = await get_diary(db, user, diary_id)
    if not diary:
        return False

    diary.title = title or diary.title
    diary.content = content or diary.content
    diary.diary_date = diary_date or diary.diary_date
    diary.updated_at = datetime.utcnow()

    if photo_ids is not None:
        # 기존 연결 제거
        await db.execute(
            delete(PhotoDiary).where(PhotoDiary.diary_id == diary_id)
        )

        if photo_ids:
            family = await get_my_family(db, user)

            result = await db.execute(
                select(Photo)
                .join(Album, Photo.album_id == Album.id)
                .where(
                    Photo.id.in_(photo_ids),
                    Album.family_id == family.id,
                    Photo.deleted_at.is_(None),
                )
            )
            photos = result.scalars().all()

            if len(photos) != len(photo_ids):
                raise Exception("Invalid photo included")

            for photo in photos:
                db.add(
                    PhotoDiary(
                        photo_id=photo.id,
                        diary_id=diary_id,
                    )
                )

    await db.commit()
    return True


# -------------------------------
# 일기 삭제 (soft delete)
# -------------------------------
async def delete_diary(
    db: AsyncSession,
    user: AppUser,
    diary_id: int,
):
    diary = await get_diary(db, user, diary_id)
    if not diary:
        return False

    diary.deleted_at = datetime.utcnow()
    await db.commit()
    return True


# -------------------------------
# 사진 상세 + 연결된 일기 (내 가족)
# -------------------------------
async def get_photo_with_diaries(
    db: AsyncSession,
    user: AppUser,
    photo_id: int,
):
    family = await get_my_family(db, user)
    if not family:
        return None

    photo_result = await db.execute(
        select(Photo)
        .join(Album, Photo.album_id == Album.id)
        .where(
            Photo.id == photo_id,
            Album.family_id == family.id,
            Photo.deleted_at.is_(None),
        )
    )
    photo = photo_result.scalar_one_or_none()
    if not photo:
        return None

    diaries_result = await db.execute(
        select(Diary)
        .join(PhotoDiary, Diary.id == PhotoDiary.diary_id)
        .where(
            PhotoDiary.photo_id == photo_id,
            Diary.deleted_at.is_(None),
        )
    )

    return {
        "photo": photo,
        "diaries": diaries_result.scalars().all(),
    }
