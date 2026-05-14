from fastapi import APIRouter, HTTPException, Depends

from bson import ObjectId

from app.schemas.server_schema import (
    ServerCreate,
    ServerUpdate
)

from app.config.mongo_db import (
    servers,
    categories
)

from app.middleware.auth_middleware import (
    get_current_user
)

router = APIRouter(
    prefix="/servers",
    tags=["Servers"]
)


# CREATE SERVER
@router.post("/create")
def create_server(
    data: ServerCreate,
    user=Depends(get_current_user)
):

    # ONLY ORGANIZATION CAN CREATE
    if user["role"] != "organization":

        raise HTTPException(
            status_code=403,
            detail="Only organizations can create servers"
        )

    # CHECK CATEGORY EXISTS
    category = categories.find_one({
        "_id": ObjectId(data.category_id)
    })

    if not category:

        raise HTTPException(
            status_code=404,
            detail="Category not found"
        )

    server_data = {

        "server_name": data.server_name,

        "description": data.description,

        "category_id": data.category_id,

        "organization_id": user["organization_id"],

        "country": data.country,

        "contact_email": data.contact_email
    }

    servers.insert_one(server_data)

    return {
        "message": "Server created successfully"
    }


# GET ALL SERVERS
@router.get("/")
def get_servers():

    all_servers = list(
        servers.find()
    )

    formatted_servers = []

    for server in all_servers:

        server["_id"] = str(server["_id"])

        formatted_servers.append(server)

    return {
        "servers": formatted_servers
    }


# GET SINGLE SERVER
@router.get("/{server_id}")
def get_single_server(server_id: str):

    server = servers.find_one({
        "_id": ObjectId(server_id)
    })

    if not server:

        raise HTTPException(
            status_code=404,
            detail="Server not found"
        )

    server["_id"] = str(server["_id"])

    return server


# UPDATE SERVER
@router.put("/{server_id}")
def update_server(
    server_id: str,
    data: ServerUpdate,
    user=Depends(get_current_user)
):

    server = servers.find_one({
        "_id": ObjectId(server_id)
    })

    if not server:

        raise HTTPException(
            status_code=404,
            detail="Server not found"
        )

    # OWNER CHECK
    if server["organization_id"] != user["organization_id"]:

        raise HTTPException(
            status_code=403,
            detail="Unauthorized"
        )

    servers.update_one(
        {
            "_id": ObjectId(server_id)
        },
        {
            "$set": {

                "server_name": data.server_name,

                "description": data.description,

                "country": data.country,

                "contact_email": data.contact_email
            }
        }
    )

    return {
        "message": "Server updated successfully"
    }


# DELETE SERVER
@router.delete("/{server_id}")
def delete_server(
    server_id: str,
    user=Depends(get_current_user)
):

    server = servers.find_one({
        "_id": ObjectId(server_id)
    })

    if not server:

        raise HTTPException(
            status_code=404,
            detail="Server not found"
        )

    # OWNER CHECK
    if server["organization_id"] != user["organization_id"]:

        raise HTTPException(
            status_code=403,
            detail="Unauthorized"
        )

    servers.delete_one({
        "_id": ObjectId(server_id)
    })

    return {
        "message": "Server deleted successfully"
    }


# SEARCH SERVERS
@router.get("/search/")
def search_servers(query: str):

    search_results = list(
        servers.find({
            "server_name": {
                "$regex": query,
                "$options": "i"
            }
        })
    )

    formatted_results = []

    for server in search_results:

        server["_id"] = str(server["_id"])

        formatted_results.append(server)

    return {
        "results": formatted_results
    }


# GET SERVERS BY CATEGORY
@router.get("/category/{category_id}")
def get_servers_by_category(category_id: str):

    category_servers = list(
        servers.find({
            "category_id": category_id
        })
    )

    formatted_servers = []

    for server in category_servers:

        server["_id"] = str(server["_id"])

        formatted_servers.append(server)

    return {
        "servers": formatted_servers
    }
