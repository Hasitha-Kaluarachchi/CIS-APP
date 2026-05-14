from fastapi import HTTPException

def organization_only(user):

    if user["role"] != "organization":

        raise HTTPException(
            status_code=403,
            detail="Only organizations can access this feature"
        )


def client_only(user):

    if user["role"] != "client":

        raise HTTPException(
            status_code=403,
            detail="Only clients can access this feature"
        )