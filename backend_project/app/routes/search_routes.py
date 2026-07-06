import re

from fastapi import APIRouter

from app.config.mongo_db import categories, servers

router = APIRouter(prefix="/search", tags=["Search"])


def format_doc(doc):
    doc["_id"] = str(doc["_id"])
    return doc


@router.get("/categories")
def search_categories(query: str):
    query = query.strip()
    if len(query) < 2:
        return {"categories": []}

    safe_query = re.escape(query)
    result = list(
        categories.find({"name": {"$regex": safe_query, "$options": "i"}}).limit(10)
    )

    return {"categories": [format_doc(category) for category in result]}


@router.get("/servers")
def search_servers(query: str):
    query = query.strip()
    if len(query) < 2:
        return {"servers": []}

    safe_query = re.escape(query)
    result = list(
        servers.find(
            {
                "$or": [
                    {"server_name": {"$regex": safe_query, "$options": "i"}},
                    {"description": {"$regex": safe_query, "$options": "i"}},
                    {"category": {"$regex": safe_query, "$options": "i"}},
                    {"sector": {"$regex": safe_query, "$options": "i"}},
                    {"location": {"$regex": safe_query, "$options": "i"}},
                ]
            }
        ).sort("created_at", -1).limit(15)
    )

    return {"servers": [format_doc(server) for server in result]}
