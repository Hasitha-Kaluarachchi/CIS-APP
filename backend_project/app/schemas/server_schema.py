from pydantic import BaseModel, EmailStr


class ServerCreate(BaseModel):
    server_name: str
    category: str
    sector: str
    description: str
    location: str
    contact_number: str
    email: EmailStr
    website: str = ""
    registration_number: str | None = ""
    verification_evidence: str | None = ""


class ServerUpdate(BaseModel):
    server_name: str
    category: str
    sector: str
    description: str
    location: str
    contact_number: str
    email: EmailStr
    website: str = ""
    registration_number: str | None = ""
    verification_evidence: str | None = ""
