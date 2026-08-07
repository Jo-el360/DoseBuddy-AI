from typing import Dict, Any
from fastapi import APIRouter, Depends, HTTPException, status
from app.schemas.ocr import OCRScanRequest, OCRScanResponse
from app.services.gemini_service import gemini_service
from app.services.firestore_service import db_service
from app.core.security import verify_token

router = APIRouter()

@router.post("/scan-label", response_model=OCRScanResponse, summary="Scan prescription or medicine label using Gemini Vision OCR")
async def scan_label(
    req: OCRScanRequest,
    current_user: Dict[str, Any] = Depends(verify_token)
):
    """
    Parses medicine bottles, prescriptions, or pill labels via Gemini Vision / OCR and extracts medication details.
    """
    parsed_info = await gemini_service.scan_prescription_or_label(
        image_base64=req.image_base64,
        scan_type=req.scan_type
    )

    scan_record = db_service.save_ocr_scan({
        "scan_type": req.scan_type,
        "raw_text": parsed_info["raw_text"],
        "parsed_medication": {
            "name": parsed_info["name"],
            "dosage": parsed_info["dosage"],
            "frequency_per_day": parsed_info["frequency_per_day"],
            "meal_relation": parsed_info["meal_relation"],
            "category": parsed_info["category"],
            "notes": parsed_info["notes"],
            "warnings": parsed_info["warnings"]
        },
        "confidence_score": parsed_info["confidence_score"]
    })

    return scan_record
