from fastapi import APIRouter, HTTPException

from bson import ObjectId



from app.config.mongo_db import (
    categories
)

router = APIRouter(
    prefix="/categories",
    tags=["Categories"]
)


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





