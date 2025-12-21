from pydantic import BaseModel

class UserRegisterRequest(BaseModel):
    name: str
    phone: str

class UserLoginRequest(BaseModel):
    phone: str

class UserResponse(BaseModel):
    id: int
    name: str
    phone: str

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
