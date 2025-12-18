# app/models/diary.py

from sqlalchemy import (
    Column,
    BigInteger,
    String,
    Text,
    DateTime,
    ForeignKey,
    Index,
    func,
)
from app.database import Base


class Diary(Base):
    __tablename__ = "diary"

    # =========================
    # 기본 식별
    # =========================
    id = Column(BigInteger, primary_key=True)

    # =========================
    # 소속 관계
    # =========================
    family_id = Column(
        BigInteger,
        ForeignKey("family.id"),
        nullable=False,
    )

    author_id = Column(
        BigInteger,
        ForeignKey("app_user.id"),
        nullable=False,
    )

    # =========================
    # 일기 내용
    # =========================
    title = Column(String(200), nullable=False)
    content = Column(Text, nullable=False)

    diary_date = Column(
        DateTime(timezone=True),
        nullable=False,
    )

    # =========================
    # 시간 컬럼
    # =========================
    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
    )
    updated_at = Column(
        DateTime(timezone=True),
        nullable=True,
    )
    deleted_at = Column(
        DateTime(timezone=True),
        nullable=True,
    )

    # =========================
    # 인덱스
    # =========================
    __table_args__ = (
        Index("idx_diary_family", "family_id"),
        Index("idx_diary_author", "author_id"),
        Index("idx_diary_date", "diary_date"),
    )
