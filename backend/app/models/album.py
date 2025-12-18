# app/models/album.py

from sqlalchemy import (
    Column,
    BigInteger,
    String,
    DateTime,
    ForeignKey,
    func,
)
from app.database import Base


class Album(Base):
    __tablename__ = "album"

    # =========================
    # 기본 정보
    # =========================
    id = Column(BigInteger, primary_key=True, index=True)

    family_id = Column(
        BigInteger,
        ForeignKey("family.id"),
        nullable=False,
    )

    folder_id = Column(
        BigInteger,
        ForeignKey("album_folder.id"),
        nullable=True,
    )

    title = Column(String(200), nullable=False)
    description = Column(String, nullable=True)

    # 대표 사진 (순환 참조 방지: FK 안 건다)
    cover_photo_id = Column(
        BigInteger,
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
