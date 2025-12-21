from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles

from app.database import Base, engine
import app.models

from app.routers import (
    auth_router,
    family_router,
    album_router,
    album_folder_router,
    photo_router,
    diary_router,
)

app = FastAPI(title="Picture Diary API")

@app.on_event("startup")
async def on_startup():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

app.include_router(auth_router.router)
app.include_router(family_router.router)
app.include_router(album_router.router)
app.include_router(album_folder_router.router)
app.include_router(photo_router.router)
app.include_router(diary_router.router)
