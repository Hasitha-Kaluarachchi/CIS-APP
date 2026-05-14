from fastapi import APIRouter, Depends
from app.middleware.auth_middleware import get_current_user
from app.config.mongo_db import (
    client_profiles,
    organization_profiles
)

router = APIRouter()


# GET CLIENT PROFILE
@router.get("/client/profile")
def get_client_profile(
    user=Depends(get_current_user)
):

    profile = client_profiles.find_one({
        "client_id": user["client_id"]
    })

    if profile:
        profile["_id"] = str(profile["_id"])

    return profile


# UPDATE CLIENT PROFILE
@router.put("/client/profile")
def update_client_profile(
    data: dict,
    user=Depends(get_current_user)
):

    client_profiles.update_one(
        {
            "client_id": user["client_id"]
        },
        {
            "$set": data
        }
    )

    return {
        "message": "Client profile updated"
    }


# GET ORGANIZATION PROFILE
@router.get("/organization/profile")
def get_organization_profile(
    user=Depends(get_current_user)
):

    profile = organization_profiles.find_one({
        "organization_id": user["organization_id"]
    })

    if profile:
        profile["_id"] = str(profile["_id"])

    return profile


# UPDATE ORGANIZATION PROFILE
@router.put("/organization/profile")
def update_organization_profile(
    data: dict,
    user=Depends(get_current_user)
):

    organization_profiles.update_one(
        {
            "organization_id": user["organization_id"]
        },
        {
            "$set": data
        }
    )

    return {
        "message": "Organization profile updated"
    }