# app/models/family_member.py

from sqlalchemy import (
    Column,
    BigInteger,
    DateTime,
    UniqueConstraint,
    func,
)
from sqlalchemy.dialects.postgresql import ENUM
from app.database import Base


class FamilyMember(Base):
    __tablename__ = "family_member"

    # =========================
    # 기본 정보
    # =========================
    id = Column(BigInteger, primary_key=True, index=True)

    # ❌ FK 제거 (family)
    family_id = Column(
        BigInteger,
        nullable=False,
    )

    # ❌ FK 제거 (app_user)
    user_id = Column(
        BigInteger,
        nullable=False,
    )

    # PostgreSQL ENUM (타입은 유지)
    relation = Column(
        ENUM(
            "father",
            "mother",
            "son",
            "daughter",
            "sibling",
            "grandparent",
            "grandchild",
            "uncle",
            "aunt",
            "cousin",
            "spouse",
            name="relation_type",
            create_type=False,   # ★ 그대로 유지
        ),
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
    deleted_at = Column(
        DateTime(timezone=True),
        nullable=True,
    )

    # =========================
    # 제약 조건
    # =========================
    __table_args__ = (
        UniqueConstraint(
            "family_id",
            "user_id",
            name="uq_family_member_family_user",
        ),
    )
