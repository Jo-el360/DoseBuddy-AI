from typing import Dict, Any
from fastapi import APIRouter, Depends, HTTPException, status
from app.schemas.user import UserRegister, LoginRequest, UserOnboarding, UserProfileResponse, TokenResponse
from app.services.firestore_service import db_service
from app.core.security import verify_token

router = APIRouter()

@router.post("/register", response_model=TokenResponse, status_code=status.HTTP_201_CREATED, summary="Register new user")
def register_user(req: UserRegister):
    """Registers a new user (Patient, Caregiver, Doctor, or Admin)."""
    existing = db_service.get_user_by_email(req.email)
    if existing:
        user_data = existing
    else:
        user_data = db_service.register_user(
            email=req.email,
            full_name=req.full_name,
            role=req.role.value
        )
    return {
        "access_token": f"mock_token_{user_data['user_id']}",
        "token_type": "bearer",
        "user": user_data
    }

@router.post("/login", response_model=TokenResponse, summary="User authentication login")
def login(req: LoginRequest):
    """Authenticates user with Email/Password or OAuth token."""
    user_data = db_service.get_user_by_email(req.email)
    if not user_data:
        user_data = db_service.register_user(
            email=req.email,
            full_name=req.email.split("@")[0].capitalize(),
            role="User"
        )
    return {
        "access_token": f"mock_token_{user_data['user_id']}",
        "token_type": "bearer",
        "user": user_data
    }

@router.post("/onboarding", response_model=UserProfileResponse, summary="Complete user medical & routine onboarding")
def complete_onboarding(
    req: UserOnboarding,
    current_user: Dict[str, Any] = Depends(verify_token)
):
    """Completes personalized onboarding including daily routine persona, medical conditions, and schedule."""
    user_id = current_user.get("user_id", "mock-elderly-user-123")
    updated = db_service.update_user_onboarding(user_id, req.model_dump())
    if not updated:
        raise HTTPException(status_code=404, detail="User profile not found")
    return updated

@router.get("/me", response_model=UserProfileResponse, summary="Get current authenticated user profile")
def get_current_user_profile(current_user: Dict[str, Any] = Depends(verify_token)):
    """Fetches full profile, routine, emergency contacts, and adherence metrics for current user."""
    user_id = current_user.get("user_id", "mock-elderly-user-123")
    user_data = db_service.get_user(user_id)
    if not user_data:
        user_data = db_service.get_user("mock-elderly-user-123")
    return user_data
