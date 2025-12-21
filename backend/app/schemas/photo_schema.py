from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime


# =========================
# 사진 생성 (서버 내부용)
# =========================
class PhotoCreate(BaseModel):
    album_id: int

    # Azure 업로드 후 서버가 채움
    original_url: str = Field(..., min_length=1)
    thumbnail_url: str = Field(..., min_length=1)

    description: Optional[str] = Field(None, max_length=500)
    place: Optional[str] = Field(None, max_length=255)
    taken_at: Optional[datetime] = None


# =========================
# 사진 응답
# =========================
class PhotoResponse(BaseModel):
    id: int
    album_id: int
    uploader_id: int

    original_url: str
    thumbnail_url: str

    description: Optional[str]
    place: Optional[str]
    taken_at: Optional[datetime]
    created_at: datetime

    class Config:
        from_attributes = True
