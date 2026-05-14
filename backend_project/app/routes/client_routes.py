from fastapi import APIRouter, HTTPException

from app.schemas.client_schema import (
    ClientSignup,
    ClientLogin
)

from app.config.mysql_db import (
    get_mysql_connection
)

from app.config.mongo_db import (
    client_profiles
)

from app.utils.password import (
    hash_password,
    verify_password
)

from app.utils.jwt_handler import (
    create_access_token
)

router = APIRouter()

# CLIENT SIGNUP
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
        raise HTTPException(
            status_code=400,
            detail="Email already exists"
        )

    # HASH PASSWORD
    hashed_password = hash_password(
        data.password
    )

    # INSERT USER
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

    print("MongoDB insert started")

    # CREATE MONGODB PROFILE
    client_profiles.insert_one({
        "client_id": client_id,
        "username": data.username,
        "email": data.email,
        "phone": "",
        "address": ""
    })

    # CREATE JWT TOKEN
    token = create_access_token({
        "client_id": client_id,
        "role": "client"
    })

    return {
        "message": "Client signup successful",
        "token": token
    }


# CLIENT LOGIN
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
        raise HTTPException(
            status_code=401,
            detail="Invalid password"
        )

    # CREATE TOKEN
    token = create_access_token({
        "client_id": user["id"],
        "role": "client"
    })

    return {
        "message": "Login successful",
        "token": token
    }