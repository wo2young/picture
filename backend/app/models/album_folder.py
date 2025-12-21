# app/models/album_folder.py

from sqlalchemy import (
    Column,
    BigInteger,
    String,
    DateTime,
    ForeignKey,
    func,
)
from app.database import Base


class AlbumFolder(Base):
    __tablename__ = "album_folder"

    # =========================
    # 기본 정보
    # =========================
    id = Column(BigInteger, primary_key=True, index=True)

    family_id = Column(
        BigInteger,
        nullable=False,   # FK 제거
    )

    name = Column(String(150), nullable=False)
    description = Column(String, nullable=True)

    # =========================
    # 시간 컬럼
    # =========================
    created_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        nullable=False,
    )
    deleted_at = Column(
        DateTime(timezone=True),
        nullable=True,
    )
