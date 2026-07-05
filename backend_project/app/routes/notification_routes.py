from fastapi import APIRouter, HTTPException
from datetime import datetime
from bson import ObjectId

from app.config.mongo_db import notifications
from app.schemas.notification_schema import CreateNotification

router = APIRouter(prefix="/notifications", tags=["Notifications"])


def format_notification(notification):
    notification["_id"] = str(notification["_id"])
    if isinstance(notification.get("created_at"), datetime):
        notification["created_at"] = notification["created_at"].isoformat()
    return notification


@router.post("/create")
def create_notification(data: CreateNotification):
    notification_data = {
        "title": data.title,
        "message": data.message,
        "receiver_id": int(data.receiver_id),
        "receiver_type": data.receiver_type,
        "is_read": False,
        "created_at": datetime.utcnow(),
    }

    inserted = notifications.insert_one(notification_data)

    return {
        "message": "Notification created successfully",
        "notification_id": str(inserted.inserted_id),
    }


@router.get("/{receiver_type}/{receiver_id}")
def get_notifications(receiver_type: str, receiver_id: int):
    user_notifications = list(
        notifications.find({
            "receiver_type": receiver_type,
            "receiver_id": int(receiver_id),
        }).sort("created_at", -1)
    )

    return {
        "notifications": [
            format_notification(notification)
            for notification in user_notifications
        ]
    }


@router.put("/read/{notification_id}")
def mark_as_read(notification_id: str):
    try:
        object_id = ObjectId(notification_id)
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid notification id")

    result = notifications.update_one(
        {"_id": object_id},
        {"$set": {"is_read": True}},
    )

    if result.matched_count == 0:
        raise HTTPException(status_code=404, detail="Notification not found")

    return {"message": "Notification updated"}