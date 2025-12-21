from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime


# ==============================
# 일기 생성 요청
# ==============================
class DiaryCreate(BaseModel):
    title: str = Field(..., min_length=1, max_length=200)
    content: str = Field(..., min_length=1)
    diary_date: datetime

    # 연결할 사진 ID 목록 (선택)
    photo_ids: Optional[List[int]] = None


# ==============================
# 일기 수정 요청
# ==============================
class DiaryUpdate(BaseModel):
    # 부분 업데이트 허용
    title: Optional[str] = Field(None, min_length=1, max_length=200)
    content: Optional[str] = Field(None, min_length=1)
    diary_date: Optional[datetime] = None

    # 사진 연결 수정
    # - None  : 기존 사진 연결 유지
    # - []    : 모든 사진 연결 해제
    # - [id]  : 해당 목록으로 재설정
    photo_ids: Optional[List[int]] = None


# ==============================
# 일기 응답
# ==============================
class DiaryResponse(BaseModel):
    id: int
    family_id: int
    author_id: int
    title: str
    content: str
    diary_date: datetime
    created_at: datetime

    class Config:
        from_attributes = True
