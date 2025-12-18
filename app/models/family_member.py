# app/models/family_member.py

from sqlalchemy import (
    Column,
    BigInteger,
    DateTime,
    ForeignKey,
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

    family_id = Column(
        BigInteger,
        ForeignKey("family.id"),
        nullable=False,
    )
    user_id = Column(
        BigInteger,
        ForeignKey("app_user.id"),
        nullable=False,
    )

    # PostgreSQL ENUM (이미 DB에 생성된 타입 참조)
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
            create_type=False,   # ★ 중요
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
