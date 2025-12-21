from pydantic import BaseModel


class RegisterRequest(BaseModel):
    name: str
    phone: str


class LoginRequest(BaseModel):
    phone: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
