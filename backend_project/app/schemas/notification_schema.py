from pydantic import BaseModel


class CreateNotification(BaseModel):
    title: str
    message: str
    receiver_id: int
    receiver_type: str   # client or organization


class NotificationResponse(BaseModel):
    title: str
    message: str
    is_read: bool