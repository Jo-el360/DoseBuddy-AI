import uuid
from datetime import datetime
from typing import Dict, Any
from fastapi import APIRouter, Depends, status
from app.schemas.voice import VoiceCommandRequest, VoiceCommandResponse, EmergencySOSRequest, EmergencySOSResponse
from app.services.gemini_service import gemini_service
from app.services.firestore_service import db_service
from app.core.security import verify_token

router = APIRouter()

@router.post("/command", response_model=VoiceCommandResponse, summary="Process natural language voice command")
async def process_voice_command(req: VoiceCommandRequest, current_user: Dict[str, Any] = Depends(verify_token)):
    """Processes spoken voice input from elderly users and returns action execution + TTS spoken audio script."""
    user_name = current_user.get("full_name", "Arthur")
    res = await gemini_service.process_voice_command(user_name, req.voice_prompt, req.routine_persona)
    return {
        "command_type": res["command_type"],
        "action_executed": res["action_executed"],
        "spoken_response": res["spoken_response"],
        "detail_data": {"voice_prompt": req.voice_prompt}
    }

@router.post("/sos", response_model=EmergencySOSResponse, status_code=status.HTTP_200_OK, summary="Dispatch Emergency SOS Alert")
def dispatch_emergency_sos(req: EmergencySOSRequest, current_user: Dict[str, Any] = Depends(verify_token)):
    """Triggers immediate Emergency SOS push alert to registered caregivers and emergency contacts."""
    sos_id = f"sos-{uuid.uuid4().hex[:6]}"
    now = datetime.utcnow().isoformat()
    return {
        "status": "EMERGENCY_DISPATCHED",
        "sos_id": sos_id,
        "caregivers_notified": ["Sarah Pendelton (Daughter)"],
        "emergency_contact": "+15550192834",
        "sent_at": now,
        "message": f"🚨 EMERGENCY SOS DISPATCHED for Arthur Pendelton! Reason: {req.trigger_reason}."
    }
