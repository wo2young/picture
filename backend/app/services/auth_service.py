from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.models.user import AppUser
from app.core.jwt import create_access_token


async def login_by_phone(db: AsyncSession, phone: str):
    result = await db.execute(
        select(AppUser).where(
            AppUser.phone == phone,
            AppUser.deleted_at.is_(None),
        )
    )
    user = result.scalar_one_or_none()

    if not user:
        return None

    token = create_access_token(
        {"sub": str(user.id)}   # ★ 표준 claim
    )

    return {
        "access_token": token,
        "token_type": "bearer",
    }
