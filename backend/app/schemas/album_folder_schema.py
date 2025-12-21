from datetime import datetime
from typing import Optional
from pydantic import BaseModel


# =========================
# 폴더 생성 요청
# =========================
class AlbumFolderCreate(BaseModel):
    family_id: int
    name: str
    description: Optional[str] = None


# =========================
# 폴더 응답
# =========================
class AlbumFolderResponse(BaseModel):
    id: int
    family_id: int
    name: str
    description: Optional[str]
    created_at: datetime

    class Config:
        from_attributes = True
