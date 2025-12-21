from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.models.user import AppUser
from app.core.jwt import create_access_token


async def register_user(db: AsyncSession, name: str, phone: str):
    result = await db.execute(
        select(AppUser).where(AppUser.phone == phone)
    )
    if result.scalar():
        raise ValueError("이미 존재하는 사용자")

    user = AppUser(
        name=name,
        phone=phone,
    )
    db.add(user)
    await db.commit()
    await db.refresh(user)

    return user


async def login_user(db: AsyncSession, phone: str):
    result = await db.execute(
        select(AppUser).where(
            AppUser.phone == phone,
            AppUser.deleted_at.is_(None),
        )
    )
    user = result.scalar_one_or_none()
    if not user:
        raise ValueError("존재하지 않는 사용자")

    token = create_access_token(
        data={"user_id": user.id}
    )

    return token
