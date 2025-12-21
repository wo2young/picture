from sqlalchemy import Column, BigInteger, String, DateTime, UniqueConstraint, func
from app.database import Base


class AppUser(Base):
    __tablename__ = "app_user"

    id = Column(BigInteger, primary_key=True, index=True)
    name = Column(String(100), nullable=False)
    phone = Column(String(30), nullable=False, unique=True)
    profile_image = Column(String, nullable=True)

    # 가족 관계 (ID만 유지)
    father_id = Column(BigInteger, nullable=True)
    mother_id = Column(BigInteger, nullable=True)
    spouse_id = Column(BigInteger, nullable=True)

    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True))
    deleted_at = Column(DateTime(timezone=True))

    __table_args__ = (
        UniqueConstraint("phone", name="uq_app_user_phone"),
    )
