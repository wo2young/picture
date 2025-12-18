from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime, date


# ==============================
# 일기 생성 요청 스키마
# ==============================
class DiaryCreate(BaseModel):
    # 가족 단위 일기이므로 family_id 필요
    family_id: int

    # 작성자 ID (JWT 붙이면 제거 예정)
    writer_id: int

    # 제목은 선택 사항
    title: Optional[str] = None

    # 본문은 필수
    content: str

    # 일기 날짜 (작성일과 별도)
    diary_date: date

    # 이 일기에 연결할 사진 ID 목록
    # 없으면 빈 리스트로 처리
    photo_ids: List[int] = []


# ==============================
# 일기 수정 요청 스키마
# ==============================
class DiaryUpdate(BaseModel):
    # 수정은 부분 업데이트 가능
    title: Optional[str] = None
    content: Optional[str] = None
    diary_date: Optional[date] = None

    # 사진 연결도 수정 가능
    # None이면 사진 연결은 건드리지 않음
    photo_ids: Optional[List[int]] = None


# ==============================
# 일기 응답 스키마
# ==============================
class DiaryResponse(BaseModel):
    id: int
    family_id: int
    writer_id: int
    title: Optional[str]
    content: str
    diary_date: date
    created_at: datetime

    # ORM 객체 → dict 변환 허용
    class Config:
        orm_mode = True
