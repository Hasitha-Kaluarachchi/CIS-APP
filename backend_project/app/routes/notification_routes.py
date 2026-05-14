from fastapi import APIRouter, HTTPException
from datetime import datetime

from app.config.mongo_db import notifications

from app.schemas.notification_schema import (
    CreateNotification
)

router = APIRouter(
    prefix="/notifications",
    tags=["Notifications"]
)

@router.post("/create")
def create_notification(data: CreateNotification):

    notification_data = {
        "title": data.title,
        "message": data.message,
        "receiver_id": data.receiver_id,
        "receiver_type": data.receiver_type,
        "is_read": False,
        "created_at": datetime.utcnow()
    }

    notifications.insert_one(notification_data)

    return {
        "message": "Notification created successfully"
    }

@router.get("/{receiver_type}/{receiver_id}")
def get_notifications(
    receiver_type: str,
    receiver_id: int
):

    user_notifications = list(
        notifications.find(
            {
                "receiver_type": receiver_type,
                "receiver_id": receiver_id
            },
            {
                "_id": 0
            }
        )
    )

    return {
        "notifications": user_notifications
    }

@router.put("/read/{notification_id}")
def mark_as_read(notification_id: str):

    result = notifications.update_one(
        {"_id": notification_id},
        {
            "$set": {
                "is_read": True
            }
        }
    )

    return {
        "message": "Notification updated"
    }