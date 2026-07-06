from datetime import datetime
import re

from bson import ObjectId
from fastapi import APIRouter, Depends, Header, HTTPException

from app.config.mongo_db import servers
from app.config.settings import ADMIN_VERIFY_SECRET
from app.middleware.auth_middleware import get_current_user
from app.schemas.server_schema import ServerCreate, ServerUpdate

router = APIRouter(
    prefix="/server",
    tags=["Servers"],
)


def format_server(server):
    server["_id"] = str(server["_id"])
    for field in ["created_at", "updated_at", "verified_at"]:
        if isinstance(server.get(field), datetime):
            server[field] = server[field].isoformat()
    return server


def server_search_filter(query: str):
    safe_query = re.escape(query.strip())
    return {
        "$or": [
            {"server_name": {"$regex": safe_query, "$options": "i"}},
            {"description": {"$regex": safe_query, "$options": "i"}},
            {"category": {"$regex": safe_query, "$options": "i"}},
            {"sector": {"$regex": safe_query, "$options": "i"}},
            {"location": {"$regex": safe_query, "$options": "i"}},
            {"contact_number": {"$regex": safe_query, "$options": "i"}},
            {"email": {"$regex": safe_query, "$options": "i"}},
        ]
    }


@router.post("/create")
def create_server(data: ServerCreate, user=Depends(get_current_user)):
    if user["role"] != "organization":
        raise HTTPException(
            status_code=403,
            detail="Only organizations can create servers",
        )

    server_data = {
        "server_name": data.server_name.strip(),
        "category": data.category.strip(),
        "sector": data.sector.strip(),
        "description": data.description.strip(),
        "location": data.location.strip(),
        "contact_number": data.contact_number.strip(),
        "email": str(data.email),
        "website": data.website.strip(),
        "registration_number": (data.registration_number or "").strip(),
        "verification_evidence": (data.verification_evidence or "").strip(),
        "verification_status": "pending",
        "is_verified": False,
        "verified_by": "",
        "verified_at": None,
        "organization_id": user["organization_id"],
        "created_at": datetime.utcnow(),
        "updated_at": datetime.utcnow(),
    }

    result = servers.insert_one(server_data)

    return {
        "message": "Business server created successfully. Verification is pending developer review.",
        "server_id": str(result.inserted_id),
    }


@router.get("/")
def get_servers():
    all_servers = list(servers.find().sort("created_at", -1))
    return {"servers": [format_server(server) for server in all_servers]}


@router.get("/search")
def search_servers(query: str):
    query = query.strip()
    if len(query) < 2:
        return {"results": []}

    search_results = list(
        servers.find(server_search_filter(query)).sort("created_at", -1).limit(15)
    )

    return {"results": [format_server(server) for server in search_results]}


@router.get("/category/{category}")
def get_servers_by_category(category: str):
    safe_category = re.escape(category.strip())
    category_servers = list(
        servers.find({
            "category": {"$regex": f"^{safe_category}$", "$options": "i"}
        }).sort("created_at", -1)
    )

    return {"servers": [format_server(server) for server in category_servers]}


@router.get("/my")
def get_my_servers(user=Depends(get_current_user)):
    if user["role"] != "organization":
        raise HTTPException(
            status_code=403,
            detail="Only organizations can view their own servers",
        )

    my_servers = list(
        servers.find({"organization_id": user["organization_id"]}).sort("created_at", -1)
    )

    return {"servers": [format_server(server) for server in my_servers]}


@router.get("/{server_id}")
def get_single_server(server_id: str):
    try:
        object_id = ObjectId(server_id)
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid server id")

    server = servers.find_one({"_id": object_id})
    if not server:
        raise HTTPException(status_code=404, detail="Server not found")

    return format_server(server)


@router.put("/{server_id}")
def update_server(
    server_id: str,
    data: ServerUpdate,
    user=Depends(get_current_user),
):
    if user["role"] != "organization":
        raise HTTPException(status_code=403, detail="Only organizations can update servers")

    try:
        object_id = ObjectId(server_id)
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid server id")

    server = servers.find_one({"_id": object_id})
    if not server:
        raise HTTPException(status_code=404, detail="Server not found")

    if server["organization_id"] != user["organization_id"]:
        raise HTTPException(status_code=403, detail="Unauthorized")

    verification_changed = (
        server.get("registration_number", "") != (data.registration_number or "").strip()
        or server.get("verification_evidence", "") != (data.verification_evidence or "").strip()
    )

    update_data = {
        "server_name": data.server_name.strip(),
        "category": data.category.strip(),
        "sector": data.sector.strip(),
        "description": data.description.strip(),
        "location": data.location.strip(),
        "contact_number": data.contact_number.strip(),
        "email": str(data.email),
        "website": data.website.strip(),
        "registration_number": (data.registration_number or "").strip(),
        "verification_evidence": (data.verification_evidence or "").strip(),
        "updated_at": datetime.utcnow(),
    }

    # When evidence changes, send the server back to pending review.
    if verification_changed:
        update_data.update({
            "verification_status": "pending",
            "is_verified": False,
            "verified_by": "",
            "verified_at": None,
        })

    servers.update_one({"_id": object_id}, {"$set": update_data})
    return {"message": "Server updated successfully"}


@router.put("/{server_id}/verify")
def verify_server(
    server_id: str,
    x_admin_secret: str = Header(default=""),
):
    if x_admin_secret != ADMIN_VERIFY_SECRET:
        raise HTTPException(status_code=403, detail="Invalid admin secret")

    try:
        object_id = ObjectId(server_id)
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid server id")

    result = servers.update_one(
        {"_id": object_id},
        {
            "$set": {
                "verification_status": "verified",
                "is_verified": True,
                "verified_by": "developer_admin",
                "verified_at": datetime.utcnow(),
                "updated_at": datetime.utcnow(),
            }
        },
    )

    if result.matched_count == 0:
        raise HTTPException(status_code=404, detail="Server not found")

    return {"message": "Server verified successfully"}


@router.put("/{server_id}/reject")
def reject_server(
    server_id: str,
    x_admin_secret: str = Header(default=""),
):
    if x_admin_secret != ADMIN_VERIFY_SECRET:
        raise HTTPException(status_code=403, detail="Invalid admin secret")

    try:
        object_id = ObjectId(server_id)
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid server id")

    result = servers.update_one(
        {"_id": object_id},
        {
            "$set": {
                "verification_status": "rejected",
                "is_verified": False,
                "verified_by": "developer_admin",
                "verified_at": datetime.utcnow(),
                "updated_at": datetime.utcnow(),
            }
        },
    )

    if result.matched_count == 0:
        raise HTTPException(status_code=404, detail="Server not found")

    return {"message": "Server verification rejected"}


@router.delete("/{server_id}")
def delete_server(server_id: str, user=Depends(get_current_user)):
    if user["role"] != "organization":
        raise HTTPException(status_code=403, detail="Only organizations can delete servers")

    try:
        object_id = ObjectId(server_id)
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid server id")

    server = servers.find_one({"_id": object_id})
    if not server:
        raise HTTPException(status_code=404, detail="Server not found")

    if server["organization_id"] != user["organization_id"]:
        raise HTTPException(status_code=403, detail="Unauthorized")

    servers.delete_one({"_id": object_id})
    return {"message": "Server deleted successfully"}
