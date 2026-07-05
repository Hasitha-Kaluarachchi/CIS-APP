from pathlib import Path
from uuid import uuid4

from fastapi import APIRouter, Depends, File, HTTPException, UploadFile

from app.middleware.auth_middleware import get_current_user
from app.config.mongo_db import client_profiles, organization_profiles
from app.config.mysql_db import get_mysql_connection

router = APIRouter()

CLIENT_ALLOWED_FIELDS = {
    "username",
    "email",
    "phone",
    "address",
    "profile_picture",
}

ORG_ALLOWED_FIELDS = {
    "organization_name",
    "org_type",
    "registration_number",
    "email",
    "phone",
    "address",
    "website",
    "main_service",
    "profile_picture",
}

ALLOWED_IMAGE_TYPES = {
    "image/jpeg": ".jpg",
    "image/jpg": ".jpg",
    "image/png": ".png",
    "image/webp": ".webp",
}
ALLOWED_IMAGE_EXTENSIONS = {".jpg", ".jpeg", ".png", ".webp"}
MAX_IMAGE_BYTES = 5 * 1024 * 1024
UPLOAD_ROOT = Path(__file__).resolve().parent.parent.parent / "uploads" / "profile_pictures"
UPLOAD_ROOT.mkdir(parents=True, exist_ok=True)


def clean_data(data: dict, allowed_fields: set):
    return {
        key: value
        for key, value in data.items()
        if key in allowed_fields
    }


def format_profile(profile):
    if profile:
        profile["_id"] = str(profile["_id"])
    return profile


async def save_profile_image(file: UploadFile, prefix: str) -> str:
    content_type = (file.content_type or "").lower()
    original_suffix = Path(file.filename or "").suffix.lower()

    if content_type in ALLOWED_IMAGE_TYPES:
        extension = ALLOWED_IMAGE_TYPES[content_type]
    elif original_suffix in ALLOWED_IMAGE_EXTENSIONS:
        extension = ".jpg" if original_suffix == ".jpeg" else original_suffix
    else:
        raise HTTPException(
            status_code=400,
            detail="Only JPG, PNG, and WEBP images are allowed",
        )

    content = await file.read()
    if len(content) > MAX_IMAGE_BYTES:
        raise HTTPException(
            status_code=400,
            detail="Image size must be 5MB or less",
        )

    filename = f"{prefix}_{uuid4().hex}{extension}"
    filepath = UPLOAD_ROOT / filename
    filepath.write_bytes(content)

    return f"/uploads/profile_pictures/{filename}"


@router.get("/client/profile")
def get_client_profile(user=Depends(get_current_user)):
    if user.get("role") != "client":
        raise HTTPException(
            status_code=403,
            detail="Only clients can access this profile",
        )

    profile = client_profiles.find_one({"client_id": user["client_id"]})
    return format_profile(profile)


@router.put("/client/profile")
def update_client_profile(data: dict, user=Depends(get_current_user)):
    if user.get("role") != "client":
        raise HTTPException(
            status_code=403,
            detail="Only clients can update this profile",
        )

    update_data = clean_data(data, CLIENT_ALLOWED_FIELDS)

    if not update_data:
        raise HTTPException(
            status_code=400,
            detail="No valid profile fields provided",
        )

    client_profiles.update_one(
        {"client_id": user["client_id"]},
        {"$set": update_data},
        upsert=True,
    )

    mysql_updates = []
    values = []

    if "username" in update_data:
        mysql_updates.append("username=%s")
        values.append(update_data["username"])

    if "email" in update_data:
        mysql_updates.append("email=%s")
        values.append(update_data["email"])

    if mysql_updates:
        conn = get_mysql_connection()
        cursor = conn.cursor()
        values.append(user["client_id"])
        cursor.execute(
            f"UPDATE clients SET {', '.join(mysql_updates)} WHERE id=%s",
            tuple(values),
        )
        conn.commit()
        cursor.close()
        conn.close()

    return {"message": "Client profile updated"}


@router.post("/client/profile/picture")
async def upload_client_profile_picture(
    file: UploadFile = File(...),
    user=Depends(get_current_user),
):
    if user.get("role") != "client":
        raise HTTPException(status_code=403, detail="Only clients can upload this image")

    image_path = await save_profile_image(file, f"client_{user['client_id']}")
    client_profiles.update_one(
        {"client_id": user["client_id"]},
        {"$set": {"profile_picture": image_path}},
        upsert=True,
    )

    return {"message": "Profile picture uploaded", "profile_picture": image_path}


@router.get("/organization/profile")
def get_organization_profile(user=Depends(get_current_user)):
    if user.get("role") != "organization":
        raise HTTPException(
            status_code=403,
            detail="Only organizations can access this profile",
        )

    profile = organization_profiles.find_one({
        "organization_id": user["organization_id"]
    })
    return format_profile(profile)


@router.put("/organization/profile")
def update_organization_profile(data: dict, user=Depends(get_current_user)):
    if user.get("role") != "organization":
        raise HTTPException(
            status_code=403,
            detail="Only organizations can update this profile",
        )

    update_data = clean_data(data, ORG_ALLOWED_FIELDS)

    if not update_data:
        raise HTTPException(
            status_code=400,
            detail="No valid profile fields provided",
        )

    organization_profiles.update_one(
        {"organization_id": user["organization_id"]},
        {"$set": update_data},
        upsert=True,
    )

    mysql_updates = []
    values = []

    if "organization_name" in update_data:
        mysql_updates.append("organization_name=%s")
        values.append(update_data["organization_name"])

    if "org_type" in update_data:
        mysql_updates.append("org_type=%s")
        values.append(update_data["org_type"])

    if "email" in update_data:
        mysql_updates.append("email=%s")
        values.append(update_data["email"])

    if mysql_updates:
        conn = get_mysql_connection()
        cursor = conn.cursor()
        values.append(user["organization_id"])
        cursor.execute(
            f"UPDATE organizations SET {', '.join(mysql_updates)} WHERE id=%s",
            tuple(values),
        )
        conn.commit()
        cursor.close()
        conn.close()

    return {"message": "Organization profile updated"}


@router.post("/organization/profile/picture")
async def upload_organization_profile_picture(
    file: UploadFile = File(...),
    user=Depends(get_current_user),
):
    if user.get("role") != "organization":
        raise HTTPException(status_code=403, detail="Only organizations can upload this image")

    image_path = await save_profile_image(file, f"organization_{user['organization_id']}")
    organization_profiles.update_one(
        {"organization_id": user["organization_id"]},
        {"$set": {"profile_picture": image_path}},
        upsert=True,
    )

    return {"message": "Logo uploaded", "profile_picture": image_path}
