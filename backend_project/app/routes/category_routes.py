from fastapi import APIRouter, HTTPException

from bson import ObjectId

from app.schemas.category_schema import (
    CategoryCreate,
    CategoryUpdate
)

from app.config.mongo_db import (
    categories
)

router = APIRouter(
    prefix="/categories",
    tags=["Categories"]
)


# CREATE CATEGORY
@router.post("/create")
def create_category(data: CategoryCreate):

    existing_category = categories.find_one({
        "name": data.name
    })

    if existing_category:

        raise HTTPException(
            status_code=400,
            detail="Category already exists"
        )

    category_data = {

        "name": data.name,

        "description": data.description
    }

    categories.insert_one(category_data)

    return {
        "message": "Category created successfully"
    }


# GET ALL CATEGORIES
@router.get("/")
def get_categories():

    all_categories = list(
        categories.find()
    )

    formatted_categories = []

    for category in all_categories:

        category["_id"] = str(category["_id"])

        formatted_categories.append(category)

    return {
        "categories": formatted_categories
    }


# GET SINGLE CATEGORY
@router.get("/{category_id}")
def get_single_category(category_id: str):

    category = categories.find_one({
        "_id": ObjectId(category_id)
    })

    if not category:

        raise HTTPException(
            status_code=404,
            detail="Category not found"
        )

    category["_id"] = str(category["_id"])

    return category


# UPDATE CATEGORY
@router.put("/{category_id}")
def update_category(
    category_id: str,
    data: CategoryUpdate
):

    categories.update_one(
        {
            "_id": ObjectId(category_id)
        },
        {
            "$set": {
                "name": data.name,
                "description": data.description
            }
        }
    )

    return {
        "message": "Category updated successfully"
    }


# DELETE CATEGORY
@router.delete("/{category_id}")
def delete_category(category_id: str):

    categories.delete_one({
        "_id": ObjectId(category_id)
    })

    return {
        "message": "Category deleted successfully"
    }