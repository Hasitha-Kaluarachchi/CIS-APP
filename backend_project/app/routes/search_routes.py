from fastapi import APIRouter

from app.config.mongo_db import (
    categories,
    servers
)

router = APIRouter(
    prefix="/search",
    tags=["Search"]
)


# SEARCH CATEGORIES
@router.get("/categories")
def search_categories(query: str):

    result = list(
        categories.find(
            {
                "name": {
                    "$regex": query,
                    "$options": "i"
                }
            },
            {
                "_id": 0
            }
        )
    )

    return {
        "categories": result
    }


# SEARCH SERVERS
@router.get("/servers")
def search_servers(query: str):

    result = list(
        servers.find(
            {
                "server_name": {
                    "$regex": query,
                    "$options": "i"
                }
            },
            {
                "_id": 0
            }
        )
    )

    return {
        "servers": result
    }