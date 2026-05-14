from pydantic import BaseModel, EmailStr

class OrganizationSignup(BaseModel):
    organization_name: str
    email: EmailStr
    password: str

class OrganizationLogin(BaseModel):
    email: EmailStr
    password: str