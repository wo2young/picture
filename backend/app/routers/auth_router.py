from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.database import get_db
from app.models.user import AppUser
from app.schemas.auth_schema import RegisterRequest, LoginRequest, TokenResponse
from app.core.jwt import create_access_token

router = APIRouter(prefix="/auth", tags=["Auth"])


@router.post("/register", response_model=TokenResponse)
async def register(
    payload: RegisterRequest,
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(AppUser).where(AppUser.phone == payload.phone)
    )
    if result.scalar_one_or_none():
        raise HTTPException(status_code=400, detail="Already registered")

    user = AppUser(
        name=payload.name,
        phone=payload.phone,
    )
    db.add(user)
    await db.commit()
    await db.refresh(user)

    token = create_access_token({"user_id": user.id})
    return {"access_token": token}


@router.post("/login", response_model=TokenResponse)
async def login(
    payload: LoginRequest,
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(AppUser).where(
            AppUser.phone == payload.phone,
            AppUser.deleted_at.is_(None),
        )
    )
    user = result.scalar_one_or_none()

    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    token = create_access_token({"user_id": user.id})
    return {"access_token": token}
