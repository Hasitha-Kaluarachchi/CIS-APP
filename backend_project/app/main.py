from fastapi import FastAPI

from app.routes.client_routes import (
    router as client_router
)

from app.routes.organization_routes import (
    router as organization_router
)

from app.routes.profile_routes import (
    router as profile_router
)

from app.routes.notification_routes import (
    router as notification_router
)

from app.routes.category_routes import (
    router as category_router
)

from app.routes.server_routes import (
    router as server_router
)

from app.routes.search_routes import (
    router as search_router
)

app = FastAPI()

# INCLUDE ROUTES
app.include_router(client_router)
app.include_router(organization_router)
app.include_router(profile_router)
app.include_router(notification_router)
app.include_router(category_router)
app.include_router(server_router)
app.include_router(search_router)

# TEST ROUTE
@app.get("/")
def home():

    return {
        "message": "Backend Running Successfully"
    }