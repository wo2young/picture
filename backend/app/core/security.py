# app/core/security.py

from datetime import datetime, timedelta
from jose import jwt
import os

# =========================
# JWT 설정
# =========================
SECRET_KEY = os.getenv("JWT_SECRET_KEY", "dev-secret")  # 나중에 env 필수
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 24  # 1일


# =========================
# Access Token 생성
# =========================
def create_access_token(
    *,
    user_id: int,
    expires_minutes: int = ACCESS_TOKEN_EXPIRE_MINUTES,
):
    now = datetime.utcnow()
    payload = {
        "sub": str(user_id),   # ⭐ user 식별자
        "iat": now,
        "exp": now + timedelta(minutes=expires_minutes),
    }

    return jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)
