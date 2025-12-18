# app/models/user.py

from sqlalchemy import (
    Column,
    BigInteger,
    String,
    DateTime,
    ForeignKey,
    UniqueConstraint,
    func,
)
from app.database import Base


class AppUser(Base):
    __tablename__ = "app_user"

    # =========================
    # 기본 식별 정보
    # =========================
    id = Column(BigInteger, primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    phone = Column(String(30), nullable=False, unique=True)
    profile_image = Column(String, nullable=True)

    # =========================
    # 가족 관계 (자기 참조 FK)
    # =========================
    father_id = Column(
        BigInteger,
        ForeignKey("app_user.id"),
        nullable=True,
    )
    mother_id = Column(
        BigInteger,
        ForeignKey("app_user.id"),
        nullable=True,
    )
    spouse_id = Column(
        BigInteger,
        ForeignKey("app_user.id"),
        nullable=True,
    )

    # =========================
    # 시간 컬럼 (soft delete 포함)
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
    # 테이블 제약
    # =========================
    __table_args__ = (
        UniqueConstraint("phone", name="uq_app_user_phone"),
    )
