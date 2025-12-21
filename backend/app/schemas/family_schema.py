from pydantic import BaseModel, Field
from datetime import datetime
from enum import Enum


class FamilyType(str, Enum):
    nuclear = "nuclear"
    maternal = "maternal"
    paternal = "paternal"


# =========================
# 가족 생성 요청
# =========================
class FamilyCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=150)
    type: FamilyType


# =========================
# 가족 응답
# =========================
class FamilyResponse(BaseModel):
    id: int
    name: str
    type: FamilyType
    created_at: datetime

    class Config:
        from_attributes = True
