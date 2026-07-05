from pydantic import BaseModel, EmailStr

class ClientSignup(BaseModel):
    username: str
    email: EmailStr
    password: str

class ClientLogin(BaseModel):
    email: EmailStr
    password: str

class GoogleLogin(BaseModel):
    id_token: str
