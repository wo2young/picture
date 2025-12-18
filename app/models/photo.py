# app/models/photo.py

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


class Photo(Base):
    __tablename__ = "photo"

    # =========================
    # 기본 식별
    # =========================
    id = Column(BigInteger, primary_key=True)

    # =========================
    # 소속 관계
    # =========================
    album_id = Column(
        BigInteger,
        ForeignKey("album.id", ondelete="CASCADE"),
        nullable=False,
    )

    uploader_id = Column(
        BigInteger,
        ForeignKey("app_user.id"),
        nullable=False,
    )

    # =========================
    # 이미지 URL
    # =========================
    original_url = Column(Text, nullable=False)
    thumbnail_url = Column(Text, nullable=False)

    # =========================
    # 메타 정보
    # =========================
    description = Column(Text, nullable=True)
    place = Column(String(255), nullable=True)

    taken_at = Column(
        DateTime(timezone=True),
        nullable=True,
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
        Index("idx_photo_album", "album_id"),
        Index("idx_photo_uploader", "uploader_id"),
        Index("idx_photo_taken_at", "taken_at"),
    )
