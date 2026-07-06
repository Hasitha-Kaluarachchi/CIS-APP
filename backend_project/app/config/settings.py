import os
from dotenv import load_dotenv

load_dotenv()

MYSQL_HOST = os.getenv("MYSQL_HOST", "localhost")
MYSQL_USER = os.getenv("MYSQL_USER", "root")
MYSQL_PASSWORD = os.getenv("MYSQL_PASSWORD", "")
MYSQL_DATABASE = os.getenv("MYSQL_DATABASE", "data_nexus")

MONGO_URL = os.getenv("MONGO_URL", "mongodb://localhost:27017")

JWT_SECRET = os.getenv("JWT_SECRET", "change-this-secret-key")
JWT_ALGORITHM = os.getenv("JWT_ALGORITHM", "HS256")

GOOGLE_CLIENT_ID = os.getenv("GOOGLE_CLIENT_ID", "")

# Used by temporary developer/admin verification endpoints.
# Set this in .env before production/demo sharing.
ADMIN_VERIFY_SECRET = os.getenv("ADMIN_VERIFY_SECRET", "data-nexus-dev-secret")
