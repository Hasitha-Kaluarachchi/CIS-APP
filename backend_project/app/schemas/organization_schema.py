from pydantic import BaseModel, EmailStr


class OrganizationSignup(BaseModel):
    organization_name: str
    org_type: str = "General"
    email: EmailStr
    password: str
    registration_number: str | None = None
    phone: str | None = None
    address: str | None = None


class OrganizationLogin(BaseModel):
    email: EmailStr
    password: str


class GoogleLogin(BaseModel):
    id_token: str
