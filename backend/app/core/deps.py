from fastapi import Depends, HTTPException
from fastapi.security import OAuth2PasswordBearer
from jose import jwt, JWTError
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.database import get_db
from app.models.user import AppUser
from app.core.jwt import SECRET_KEY, ALGORITHM

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")


async def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: AsyncSession = Depends(get_db),
) -> AppUser:
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id = payload.get("user_id")
        if not user_id:
            raise HTTPException(status_code=401)
    except JWTError:
        raise HTTPException(status_code=401)

    result = await db.execute(
        select(AppUser).where(
            AppUser.id == user_id,
            AppUser.deleted_at.is_(None),
        )
    )
    user = result.scalar_one_or_none()

    if not user:
        raise HTTPException(status_code=401)

    return user
