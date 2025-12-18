from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles  
from app.database import Base, engine
from app.routers import diary_router, photo_router, feed_router, upload_router

app = FastAPI(
    title="Picture Diary API",
    description="사진 + 일기 기록 서비스",
    version="1.0.0"
)

# ★ async 엔진에서는 이렇게 테이블 생성
@app.on_event("startup")
async def on_startup():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

# 정적 파일 서빙
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

# 라우터 등록
app.include_router(photo_router.router, prefix="/photos", tags=["Photos"])
app.include_router(diary_router.router, prefix="/diaries", tags=["Diaries"])
app.include_router(feed_router.router, prefix="/feed", tags=["Feed"])
app.include_router(upload_router)   # prefix 이미 upload_router 안에 있음

@app.get("/")
async def root():
    return {"message": "Picture Diary API is running!"}
