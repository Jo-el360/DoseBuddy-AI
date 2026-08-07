from typing import List, Dict, Any
from fastapi import APIRouter, Depends, HTTPException, status
from app.schemas.medication import MedicationCreate, MedicationUpdate, MedicationResponse, DrugInteractionRequest, DrugInteractionResponse
from app.services.firestore_service import db_service
from app.services.gemini_service import gemini_service
from app.core.security import verify_token

router = APIRouter()

@router.post("/check-interactions", response_model=DrugInteractionResponse, summary="Check drug-drug interaction safety")
async def check_interactions(req: DrugInteractionRequest, current_user: Dict[str, Any] = Depends(verify_token)):
    """Analyzes interaction safety between a proposed medication and existing prescription list using Gemini AI."""
    return await gemini_service.check_drug_interactions(req.new_medication_name, req.existing_medication_names)

@router.get("/", response_model=List[MedicationResponse], summary="Get list of medications")
def list_medications(current_user: Dict[str, Any] = Depends(verify_token)):
    """Retrieve all medications registered for the current diabetic patient."""
    patient_id = current_user.get("uid", "mock-elderly-user-123")
    return db_service.get_medications(patient_id)

@router.get("/{med_id}", response_model=MedicationResponse, summary="Get single medication detail")
def get_medication(med_id: str, current_user: Dict[str, Any] = Depends(verify_token)):
    med = db_service.get_medication(med_id)
    if not med:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Medication not found")
    return med

@router.post("/", response_model=MedicationResponse, status_code=status.HTTP_201_CREATED, summary="Create a new medication")
def create_medication(med_in: MedicationCreate, current_user: Dict[str, Any] = Depends(verify_token)):
    """Add a new medication entry with dosage, timing, and meal relation."""
    patient_id = current_user.get("uid", "mock-elderly-user-123")
    return db_service.create_medication(patient_id, med_in)

@router.put("/{med_id}", response_model=MedicationResponse, summary="Update an existing medication")
def update_medication(med_id: str, med_in: MedicationUpdate, current_user: Dict[str, Any] = Depends(verify_token)):
    updated = db_service.update_medication(med_id, med_in)
    if not updated:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Medication not found")
    return updated

@router.delete("/{med_id}", status_code=status.HTTP_204_NO_CONTENT, summary="Delete medication")
def delete_medication(med_id: str, current_user: Dict[str, Any] = Depends(verify_token)):
    deleted = db_service.delete_medication(med_id)
    if not deleted:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Medication not found")
    return None
