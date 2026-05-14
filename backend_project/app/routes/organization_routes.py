from fastapi import APIRouter, HTTPException

from app.schemas.organization_schema import (
    OrganizationSignup,
    OrganizationLogin
)

from app.config.mysql_db import (
    get_mysql_connection
)

from app.config.mongo_db import (
    organization_profiles
)

from app.utils.password import (
    hash_password,
    verify_password
)

from app.utils.jwt_handler import (
    create_access_token
)

router = APIRouter(
    prefix="/organization",
    tags=["Organization"]
)


# ORGANIZATION SIGNUP
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
        raise HTTPException(
            status_code=400,
            detail="Organization already exists"
        )

    # HASH PASSWORD
    hashed_password = hash_password(
        data.password
    )

    # INSERT ORGANIZATION
    cursor.execute(
        """
        INSERT INTO organizations
        (organization_name, email, password)
        VALUES (%s, %s, %s)
        """,
        (
            data.organization_name,
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
        "email": data.email,
        "phone": "",
        "address": "",
        "website": ""
    })

    # CREATE JWT TOKEN
    token = create_access_token({
        "organization_id": organization_id,
        "role": "organization"
    })

    return {
        "message": "Organization signup successful",
        "token": token
    }


# ORGANIZATION LOGIN
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
        raise HTTPException(
            status_code=401,
            detail="Invalid password"
        )

    # CREATE JWT TOKEN
    token = create_access_token({
        "organization_id": organization["id"],
        "role": "organization"
    })

    return {
        "message": "Organization login successful",
        "token": token
    }