# app/models/photo_diary.py

from sqlalchemy import (
    Column,
    BigInteger,
    DateTime,
    ForeignKey,
    UniqueConstraint,
    func,
)
from app.database import Base


class PhotoDiary(Base):
    __tablename__ = "photo_diary"

    # =========================
    # 기본 식별
    # =========================
    id = Column(BigInteger, primary_key=True)

    # =========================
    # N:N 연결
    # =========================
    photo_id = Column(
        BigInteger,
        ForeignKey("photo.id", ondelete="CASCADE"),
        nullable=False,
    )

    diary_id = Column(
        BigInteger,
        ForeignKey("diary.id", ondelete="CASCADE"),
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

    # =========================
    # 제약
    # =========================
    __table_args__ = (
        UniqueConstraint(
            "photo_id",
            "diary_id",
            name="uq_photo_diary_photo_diary",
        ),
    )
