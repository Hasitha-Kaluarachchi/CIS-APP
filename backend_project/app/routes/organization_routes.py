from fastapi import APIRouter, HTTPException

from datetime import datetime
import secrets

from app.schemas.organization_schema import (
    OrganizationSignup,
    OrganizationLogin,
    GoogleLogin
)

from app.config.mysql_db import (
    get_mysql_connection
)

from app.config.mongo_db import (
    organization_profiles,
    notifications
)

from app.utils.password import (
    hash_password,
    verify_password
)

from app.utils.jwt_handler import (
    create_access_token
)

from app.utils.google_auth import (
    verify_google_token
)

router = APIRouter(
    prefix="/organization",
    tags=["Organization"]
)


# ──────────────────────────────────────────────
# CREATE WELCOME NOTIFICATION
# This creates one welcome notification for an organization.
# It checks first, so the same welcome notification is not duplicated.
# receiver_type = "organization"
# receiver_id = MySQL organization id
# ──────────────────────────────────────────────
def create_welcome_notification(
    organization_id: int,
    organization_name: str
):
    already_sent = notifications.find_one({
        "receiver_type": "organization",
        "receiver_id": int(organization_id),
        "title": "Welcome to Data Nexus"
    })

    if already_sent:
        return

    notifications.insert_one({
        "title": "Welcome to Data Nexus",
        "message": (
            f"Welcome {organization_name}! "
            "Your organization account is ready to use."
        ),
        "receiver_id": int(organization_id),
        "receiver_type": "organization",
        "is_read": False,
        "created_at": datetime.utcnow()
    })


# ──────────────────────────────────────────────
# ORGANIZATION SIGNUP
# Creates a new organization account in MySQL.
# Also creates organization profile in MongoDB.
# Also creates a welcome notification.
# ──────────────────────────────────────────────
@router.post("/signup")
def organization_signup(data: OrganizationSignup):

    conn = get_mysql_connection()
    cursor = conn.cursor(dictionary=True)

    # CHECK ORGANIZATION EXISTS
    cursor.execute(
        "SELECT * FROM organizations WHERE email=%s",
        (data.email,)
    )

    existing_org = cursor.fetchone()

    if existing_org:
        cursor.close()
        conn.close()
        raise HTTPException(
            status_code=400,
            detail="Organization already exists"
        )

    # HASH PASSWORD
    hashed_password = hash_password(data.password)

    # INSERT ORGANIZATION INTO MYSQL
    cursor.execute(
        """
        INSERT INTO organizations
        (organization_name, org_type, email, password)
        VALUES (%s, %s, %s, %s)
        """,
        (
            data.organization_name,
            data.org_type,
            data.email,
            hashed_password
        )
    )

    conn.commit()
    organization_id = cursor.lastrowid

    # CREATE MONGODB PROFILE
    organization_profiles.insert_one({
        "organization_id": organization_id,
        "organization_name": data.organization_name,
        "org_type": data.org_type,
        "registration_number": data.registration_number or "",
        "email": data.email,
        "phone": data.phone or "",
        "address": data.address or "",
        "website": "",
        "main_service": "",
        "profile_picture": ""
    })

    # ADDED: CREATE WELCOME NOTIFICATION
    create_welcome_notification(
        organization_id,
        data.organization_name
    )

    # CREATE JWT TOKEN
    token = create_access_token({
        "organization_id": organization_id,
        "role": "organization"
    })

    cursor.close()
    conn.close()

    return {
        "message": "Organization signup successful",
        "token": token
    }


# ──────────────────────────────────────────────
# ORGANIZATION LOGIN
# Checks organization email and password.
# Creates a JWT token if login details are correct.
# Also ensures welcome notification exists.
# ──────────────────────────────────────────────
@router.post("/login")
def organization_login(data: OrganizationLogin):

    conn = get_mysql_connection()
    cursor = conn.cursor(dictionary=True)

    # CHECK ORGANIZATION
    cursor.execute(
        "SELECT * FROM organizations WHERE email=%s",
        (data.email,)
    )

    organization = cursor.fetchone()

    if not organization:
        cursor.close()
        conn.close()
        raise HTTPException(
            status_code=404,
            detail="Organization not found"
        )

    # VERIFY PASSWORD
    valid_password = verify_password(
        data.password,
        organization["password"]
    )

    if not valid_password:
        cursor.close()
        conn.close()
        raise HTTPException(
            status_code=401,
            detail="Invalid password"
        )

    # ADDED: ENSURE WELCOME NOTIFICATION EXISTS
    create_welcome_notification(
        organization["id"],
        organization["organization_name"]
    )

    # CREATE JWT TOKEN
    token = create_access_token({
        "organization_id": organization["id"],
        "role": "organization"
    })

    cursor.close()
    conn.close()

    return {
        "message": "Organization login successful",
        "token": token
    }

# ──────────────────────────────────────────────
# ORGANIZATION GOOGLE LOGIN / VERIFICATION
# Verifies the Google account using Google ID token.
# If the organization account does not exist, it creates a new provider account.
# ──────────────────────────────────────────────
@router.post("/google-login")
def organization_google_login(data: GoogleLogin):

    google_user = verify_google_token(data.id_token)

    conn = get_mysql_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute(
        "SELECT * FROM organizations WHERE email=%s",
        (google_user["email"],)
    )

    organization = cursor.fetchone()

    if not organization:
        generated_password = hash_password(secrets.token_urlsafe(32))

        cursor.execute(
            """
            INSERT INTO organizations
            (organization_name, org_type, email, password)
            VALUES (%s, %s, %s, %s)
            """,
            (
                google_user["name"],
                "Google Verified Provider",
                google_user["email"],
                generated_password
            )
        )

        conn.commit()
        organization_id = cursor.lastrowid

        organization_profiles.insert_one({
            "organization_id": organization_id,
            "organization_name": google_user["name"],
            "org_type": "Google Verified Provider",
            "registration_number": "",
            "email": google_user["email"],
            "phone": "",
            "address": "",
            "website": "",
            "main_service": "",
            "profile_picture": google_user["picture"],
            "google_verified": True,
            "provider_verified": "pending"
        })

        create_welcome_notification(
            organization_id,
            google_user["name"]
        )

        organization = {
            "id": organization_id,
            "organization_name": google_user["name"],
            "email": google_user["email"]
        }

    else:
        organization_profiles.update_one(
            {"organization_id": int(organization["id"])},
            {
                "$set": {
                    "google_verified": True,
                    "profile_picture": google_user["picture"]
                }
            },
            upsert=True
        )

    create_welcome_notification(
        organization["id"],
        organization["organization_name"]
    )

    token = create_access_token({
        "organization_id": organization["id"],
        "role": "organization"
    })

    cursor.close()
    conn.close()

    return {
        "message": "Google account verified successfully",
        "token": token
    }
