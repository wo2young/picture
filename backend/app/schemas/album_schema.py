from datetime import datetime
from typing import Optional
from pydantic import BaseModel


# =========================
# 앨범 생성 요청
# =========================
class AlbumCreate(BaseModel):
    title: str
    description: Optional[str] = None
    folder_id: Optional[int] = None


# =========================
# 앨범 응답
# =========================
class AlbumResponse(BaseModel):
    id: int
    family_id: int
    folder_id: Optional[int]
    title: str
    description: Optional[str]
    cover_photo_id: Optional[int]
    created_at: datetime

    class Config:
        from_attributes = True
