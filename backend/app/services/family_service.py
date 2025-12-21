from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.models.family import Family
from app.models.family_member import FamilyMember
from app.models.user import AppUser


async def create_family(
    db: AsyncSession,
    user: AppUser,
    name: str,
    family_type: str,
):
    # 1️⃣ 가족 생성
    family = Family(
        name=name,
        type=family_type,
    )
    db.add(family)
    await db.flush()  # family.id 확보

    # 2️⃣ 생성자를 가족 구성원으로 자동 등록
    member = FamilyMember(
        family_id=family.id,
        user_id=user.id,
        relation="spouse",  # ENUM OK
    )
    db.add(member)

    # 3️⃣ ⭐ 기본 앨범 자동 생성 (핵심)
    default_album = Album(
        family_id=family.id,
        title="전체 사진",
        description="가족의 모든 사진",
        folder_id=None,
    )
    db.add(default_album)

    # 4️⃣ 커밋
    await db.commit()
    await db.refresh(family)

    return family



async def get_my_families(
    db: AsyncSession,
    user: AppUser,
):
    result = await db.execute(
        select(Family)
        .join(FamilyMember)
        .where(
            FamilyMember.user_id == user.id,
            FamilyMember.deleted_at.is_(None),
        )
    )
    return result.scalars().all()

async def get_my_family(
    db: AsyncSession,
    user: AppUser,
):
    result = await db.execute(
        select(Family)
        .join(FamilyMember)
        .where(
            FamilyMember.user_id == user.id,
            FamilyMember.deleted_at.is_(None),
        )
        .order_by(Family.created_at.asc())  # 첫 가족
    )
    return result.scalars().first()