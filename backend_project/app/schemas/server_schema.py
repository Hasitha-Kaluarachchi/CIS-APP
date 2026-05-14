from pydantic import BaseModel


class ServerCreate(BaseModel):

    server_name: str

    description: str

    category_id: str

    country: str

    contact_email: str


class ServerUpdate(BaseModel):

    server_name: str

    description: str

    country: str

    contact_email: str