from fastapi import APIRouter, HTTPException

from datetime import datetime
import secrets

from app.schemas.client_schema import (
    ClientSignup,
    ClientLogin,
    GoogleLogin
)

from app.config.mysql_db import (
    get_mysql_connection
)

from app.config.mongo_db import (
    client_profiles,
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

router = APIRouter()


# ──────────────────────────────────────────────
# CREATE WELCOME NOTIFICATION
# This creates one welcome notification for a client.
# It checks first, so the same welcome notification is not duplicated.
# receiver_type = "client"
# receiver_id = MySQL client id
# ──────────────────────────────────────────────
def create_welcome_notification(client_id: int, username: str):
    already_sent = notifications.find_one({
        "receiver_type": "client",
        "receiver_id": int(client_id),
        "title": "Welcome to Data Nexus"
    })

    if already_sent:
        return

    notifications.insert_one({
        "title": "Welcome to Data Nexus",
        "message": f"Welcome {username}! Your account is ready to use.",
        "receiver_id": int(client_id),
        "receiver_type": "client",
        "is_read": False,
        "created_at": datetime.utcnow()
    })


# ──────────────────────────────────────────────
# CLIENT SIGNUP
# Creates a new client account in MySQL.
# Also creates a client profile in MongoDB.
# Also creates a welcome notification.
# ──────────────────────────────────────────────
@router.post("/client/signup")
def client_signup(data: ClientSignup):

    conn = get_mysql_connection()
    cursor = conn.cursor(dictionary=True)

    # CHECK EMAIL
    cursor.execute(
        "SELECT * FROM clients WHERE email=%s",
        (data.email,)
    )

    existing_user = cursor.fetchone()

    if existing_user:
        cursor.close()
        conn.close()
        raise HTTPException(
            status_code=400,
            detail="Email already exists"
        )

    # HASH PASSWORD
    hashed_password = hash_password(data.password)

    # INSERT USER INTO MYSQL
    cursor.execute(
        """
        INSERT INTO clients
        (username, email, password)
        VALUES (%s, %s, %s)
        """,
        (
            data.username,
            data.email,
            hashed_password
        )
    )

    conn.commit()
    client_id = cursor.lastrowid

    # CREATE MONGODB PROFILE
    client_profiles.insert_one({
        "client_id": client_id,
        "username": data.username,
        "email": data.email,
        "phone": "",
        "address": "",
        "profile_picture": ""
    })

    # ADDED: CREATE WELCOME NOTIFICATION
    create_welcome_notification(
        client_id,
        data.username
    )

    # CREATE JWT TOKEN
    token = create_access_token({
        "client_id": client_id,
        "role": "client"
    })

    cursor.close()
    conn.close()

    return {
        "message": "Client signup successful",
        "token": token
    }


# ──────────────────────────────────────────────
# CLIENT LOGIN
# Checks client email and password.
# Creates a JWT token if login details are correct.
# Also ensures welcome notification exists.
# ──────────────────────────────────────────────
@router.post("/client/login")
def client_login(data: ClientLogin):

    conn = get_mysql_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute(
        "SELECT * FROM clients WHERE email=%s",
        (data.email,)
    )

    user = cursor.fetchone()

    if not user:
        cursor.close()
        conn.close()
        raise HTTPException(
            status_code=404,
            detail="User not found"
        )

    # VERIFY PASSWORD
    valid_password = verify_password(
        data.password,
        user["password"]
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
        user["id"],
        user["username"]
    )

    # CREATE TOKEN
    token = create_access_token({
        "client_id": user["id"],
        "role": "client"
    })

    cursor.close()
    conn.close()

    return {
        "message": "Login successful",
        "token": token
    }

# ──────────────────────────────────────────────
# CLIENT GOOGLE LOGIN / VERIFICATION
# Verifies the Google account using Google ID token.
# If the client account does not exist, it creates a new client account.
# ──────────────────────────────────────────────
@router.post("/client/google-login")
def client_google_login(data: GoogleLogin):

    google_user = verify_google_token(data.id_token)

    conn = get_mysql_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute(
        "SELECT * FROM clients WHERE email=%s",
        (google_user["email"],)
    )

    user = cursor.fetchone()

    if not user:
        generated_password = hash_password(secrets.token_urlsafe(32))

        cursor.execute(
            """
            INSERT INTO clients
            (username, email, password)
            VALUES (%s, %s, %s)
            """,
            (
                google_user["name"],
                google_user["email"],
                generated_password
            )
        )

        conn.commit()
        client_id = cursor.lastrowid

        client_profiles.insert_one({
            "client_id": client_id,
            "username": google_user["name"],
            "email": google_user["email"],
            "phone": "",
            "address": "",
            "profile_picture": google_user["picture"],
            "google_verified": True
        })

        create_welcome_notification(
            client_id,
            google_user["name"]
        )

        user = {
            "id": client_id,
            "username": google_user["name"],
            "email": google_user["email"]
        }

    else:
        client_profiles.update_one(
            {"client_id": int(user["id"])},
            {
                "$set": {
                    "google_verified": True,
                    "profile_picture": google_user["picture"]
                }
            },
            upsert=True
        )

    create_welcome_notification(
        user["id"],
        user["username"]
    )

    token = create_access_token({
        "client_id": user["id"],
        "role": "client"
    })

    cursor.close()
    conn.close()

    return {
        "message": "Google account verified successfully",
        "token": token
    }
