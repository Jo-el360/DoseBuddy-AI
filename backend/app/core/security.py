from typing import Optional, Dict, Any
from fastapi import HTTPException, Security, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from app.core.config import settings

security_bearer = HTTPBearer(auto_error=False)

def verify_token(credentials: Optional[HTTPAuthorizationCredentials] = Security(security_bearer)) -> Dict[str, Any]:
    """
    Verifies Firebase Bearer ID Token.
    If USE_MOCK_SERVICES is True or no credentials provided in test mode, returns a mock user payload.
    """
    if settings.USE_MOCK_SERVICES:
        return {
            "uid": "mock-elderly-user-123",
            "email": "arthur.patient@example.com",
            "name": "Arthur Pendelton",
            "role": "patient"
        }

    if not credentials:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing Authorization Header",
            headers={"WWW-Authenticate": "Bearer"},
        )

    token = credentials.credentials
    try:
        import firebase_admin
        from firebase_admin import auth
        
        decoded_token = auth.verify_id_token(token)
        return decoded_token
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Invalid or expired Firebase Auth token: {str(e)}",
            headers={"WWW-Authenticate": "Bearer"},
        )
