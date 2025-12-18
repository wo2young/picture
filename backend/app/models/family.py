# app/models/family.py

from sqlalchemy import (
    Column,
    BigInteger,
    String,
    DateTime,
    func,
)
from sqlalchemy.dialects.postgresql import ENUM
from app.database import Base


class Family(Base):
    __tablename__ = "family"

    # =========================
    # 기본 정보
    # =========================
    id = Column(BigInteger, primary_key=True, index=True)
    name = Column(String(150), nullable=False)

    # PostgreSQL ENUM (이미 DB에 생성된 타입 참조)
    type = Column(
        ENUM(
            "nuclear",
            "maternal",
            "paternal",
            name="family_type",
            create_type=False,   # ★ 중요: DB에 이미 있음
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
