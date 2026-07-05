from fastapi import HTTPException
from google.auth.transport import requests
from google.oauth2 import id_token

from app.config.settings import GOOGLE_CLIENT_ID


def verify_google_token(raw_id_token: str) -> dict:
    """Verify a Google ID token and return trusted Google profile data."""

    if not GOOGLE_CLIENT_ID:
        raise HTTPException(
            status_code=500,
            detail="GOOGLE_CLIENT_ID is not configured in backend .env"
        )

    try:
        payload = id_token.verify_oauth2_token(
            raw_id_token,
            requests.Request(),
            GOOGLE_CLIENT_ID
        )
    except ValueError:
        raise HTTPException(
            status_code=401,
            detail="Invalid Google verification token"
        )

    email = payload.get("email")
    email_verified = payload.get("email_verified")

    if not email or email_verified is not True:
        raise HTTPException(
            status_code=401,
            detail="Google email is not verified"
        )

    name = payload.get("name") or email.split("@")[0]
    picture = payload.get("picture") or ""

    return {
        "email": email,
        "name": name,
        "picture": picture,
    }
