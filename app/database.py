from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker, declarative_base
from app.config import settings

# async 엔진 생성
engine = create_async_engine(
    settings.DATABASE_URL,
    echo=True,
    future=True
)

# 세션팩토리
AsyncSessionLocal = sessionmaker(
    bind=engine,
    expire_on_commit=False,
    autoflush=False,
    autocommit=False,
    class_=AsyncSession
)

Base = declarative_base()


# FastAPI 의존성 주입용
async def get_db():
    async with AsyncSessionLocal() as session:
        yield session
