from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.services.feed_service import (
    get_feed_latest,
    get_feed_random,
    get_feed_all,
)

router = APIRouter(prefix="/feed", tags=["Feed"])


@router.get("/latest")
async def latest_feed(
    user_id: int,
    db: AsyncSession = Depends(get_db),
):
    return await get_feed_latest(db, user_id)


@router.get("/random")
async def random_feed(
    user_id: int,
    db: AsyncSession = Depends(get_db),
):
    return await get_feed_random(db, user_id)


@router.get("/all")
async def all_feed(
    user_id: int,
    db: AsyncSession = Depends(get_db),
):
    return await get_feed_all(db, user_id)
