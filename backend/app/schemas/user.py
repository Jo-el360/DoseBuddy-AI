from typing import Optional, List
from enum import Enum
from pydantic import BaseModel, EmailStr, Field, ConfigDict

class RoleEnum(str, Enum):
    USER = "User"
    CAREGIVER = "Caregiver"
    DOCTOR = "Doctor"
    ADMIN = "Admin"

class UserRegister(BaseModel):
    email: EmailStr = Field(..., json_schema_extra={"example": "patient@example.com"})
    password: str = Field(..., min_length=6, json_schema_extra={"example": "SecurePass123!"})
    full_name: str = Field(..., json_schema_extra={"example": "Arthur Pendelton"})
    role: RoleEnum = Field(default=RoleEnum.USER, json_schema_extra={"example": "User"})

class LoginRequest(BaseModel):
    email: EmailStr = Field(..., json_schema_extra={"example": "patient@example.com"})
    password: str = Field(..., json_schema_extra={"example": "SecurePass123!"})

class UserOnboarding(BaseModel):
    age: int = Field(..., ge=1, le=120, json_schema_extra={"example": 72})
    gender: str = Field(..., json_schema_extra={"example": "Male"})
    height_cm: float = Field(default=172.0, json_schema_extra={"example": 172.0})
    weight_kg: float = Field(default=75.0, json_schema_extra={"example": 75.0})
    blood_group: str = Field(default="O+", json_schema_extra={"example": "O+"})
    medical_conditions: List[str] = Field(default=["Type 2 Diabetes", "Hypertension"], json_schema_extra={"example": ["Type 2 Diabetes", "Hypertension"]})
    allergies: List[str] = Field(default=["Penicillin"], json_schema_extra={"example": ["Penicillin"]})
    emergency_contact: str = Field(..., json_schema_extra={"example": "+15550192834"})
    caregiver_contact: str = Field(..., json_schema_extra={"example": "sarah.caregiver@example.com"})
    preferred_language: str = Field(default="English", json_schema_extra={"example": "English"})
    country: str = Field(default="United States", json_schema_extra={"example": "United States"})
    time_zone: str = Field(default="America/New_York", json_schema_extra={"example": "America/New_York"})
    routine_persona: str = Field(default="Senior Citizen", json_schema_extra={"example": "Senior Citizen"})  # Senior Citizen, Student, Office Worker, Night Shift, Retired, Traveling
    wake_time: str = Field(default="07:00", json_schema_extra={"example": "07:00"})
    sleep_time: str = Field(default="22:00", json_schema_extra={"example": "22:00"})
    breakfast_time: str = Field(default="08:00", json_schema_extra={"example": "08:00"})
    lunch_time: str = Field(default="13:00", json_schema_extra={"example": "13:00"})
    dinner_time: str = Field(default="19:00", json_schema_extra={"example": "19:00"})

class UserProfileResponse(BaseModel):
    user_id: str
    email: EmailStr
    full_name: str
    role: RoleEnum
    onboarded: bool = False
    age: Optional[int] = None
    gender: Optional[str] = None
    blood_group: Optional[str] = None
    medical_conditions: List[str] = []
    allergies: List[str] = []
    routine_persona: str = "Senior Citizen"
    emergency_contact: Optional[str] = None
    caregiver_contact: Optional[str] = None
    adherence_percentage: float = 100.0
    created_at: str

    model_config = ConfigDict(from_attributes=True)

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserProfileResponse
