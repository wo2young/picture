from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class PhotoCreate(BaseModel):
    album_id: int
    uploader_id: int
    original_url: str
    thumbnail_url: str
    description: Optional[str] = None
    place: Optional[str] = None
    taken_at: Optional[datetime] = None


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
        orm_mode = True
