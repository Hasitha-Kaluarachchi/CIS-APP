from app.config.mongo_db import categories

DEFAULT_CATEGORIES = [
    {"name": "Health Services", "description": "Hospitals, clinics, pharmacies, and health-related services."},
    {"name": "Education Services", "description": "Schools, universities, institutes, and education support services."},
    {"name": "Business Services", "description": "Private businesses and professional services."},
    {"name": "Administrative Services", "description": "Government and administrative services."},
]

for category in DEFAULT_CATEGORIES:
    categories.update_one(
        {"name": category["name"]},
        {"$set": category},
        upsert=True,
    )

print("MongoDB categories seeded successfully.")
