import os
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from google import genai
import json

router = APIRouter()

class NoticeRequest(BaseModel):
    # Block A
    senderName: str
    senderFathersName: str
    senderAddress: str
    senderContact: str
    senderEmail: str
    # Block B
    opponentName: str
    opponentFathersName: str
    opponentAddress: str
    businessType: str
    # Block C
    relationship: str
    # Block D
    dateOfAgreement: str
    natureOfAgreement: str
    keyEventDate: str
    reminderDate: str
    breachDate: str
    # Block E
    amountInvolved: str
    modeOfTransaction: str
    proofAvailable: bool
    reliefSought: str
    # Block F
    legalGround: str
    # Language
    language: str = "English"

try:
    api_key = os.environ.get("GEMINI_API_KEY")
    client = genai.Client(api_key=api_key)
except Exception as e:
    client = None
    print(f"GenAI Client Error: {e}")

@router.get("/ipc-search")
async def search_ipc(query: str, language: str = "English"):
    if not client:
        return {"results": [{"section": "N/A", "title": "Error", "detail": "AI not configured", "simplified_explanation": "Backend Error. Please check API keys."}]}
    try:
        prompt = f'''
        The user is searching for Indian laws related to: "{query}".
        Act as an expert Indian legal advisor. Aggressively find ALL relevant Indian Penal Code (IPC) sections, Bharatiya Nyaya Sanhita (BNS) sections, or other major relevant Indian acts matching this keyword. 
        Return a JSON object with a "results" array. Each object in the array must have exactly these keys:
        - "section": The specific law/section number.
        - "title": The formal legal title of the offense.
        - "detail": The exact legal definition.
        - "simplified_explanation": A highly simplified, easy-to-understand explanation of what this law actually means for a common person.
        You MUST generate your ENTIRE response STRICTLY in {language} ONLY. Do NOT include any English translation or English text, unless the requested language is English.
        Do not use markdown blocks, return ONLY raw JSON.
        '''
        res = client.models.generate_content(model='gemini-2.5-flash', contents=prompt.strip())
        # Attempt to parse json from text
        text = res.text.replace('```json', '').replace('```', '').strip()
        return json.loads(text)
    except Exception as e:
        print(f"IPC Search Error: {e}")
        return {"results": [{"section": "378", "title": "Theft", "detail": "Mock detail (Fallback)", "simplified_explanation": "This means stealing someone's property."}]}

@router.get("/daily-legal-tip")
async def get_daily_tip(language: str = "English"):
    if not client:
        return {"tip": "AI not configured."}
    try:
        prompt = f"Provide one short, useful daily legal tip for Indian citizens. You MUST generate your ENTIRE response STRICTLY in {language} ONLY. Do NOT include any English translation."
        res = client.models.generate_content(model='gemini-2.5-flash', contents=prompt)
        return {"tip": res.text.strip()}
    except Exception as e:
        print(f"Daily Tip Error: {e}")
        return {"tip": "Under the IT Act, sharing explicit content online is an offense."}

@router.get("/law-updates")
async def get_law_updates(language: str = "English"):
    if not client:
        return {"updates": [{"title": "AI Error", "summary": "N/A"}]}
    try:
        prompt = f'Provide 2 recent or important Indian law updates. Return JSON with an "updates" array of objects with "title" and "summary". You MUST generate your ENTIRE response STRICTLY in {language} ONLY. Do NOT include any English translation.'
        res = client.models.generate_content(model='gemini-2.5-flash', contents=prompt)
        text = res.text.replace('```json', '').replace('```', '').strip()
        return json.loads(text)
    except Exception as e:
        print(f"Law Updates Error: {e}")
        return {"updates": [{"title": "New IT Rules 2026", "summary": "Changes to data privacy..."}]}

@router.get("/templates")
async def get_templates():
    if not client:
        return {"templates": [{"title": "AI Error", "content": "N/A"}]}
    try:
        prompt = 'Provide 2 common Indian legal document templates (e.g., FIR, Rental Agreement). Return JSON with a "templates" array of objects with "title" and "content".'
        res = client.models.generate_content(model='gemini-2.5-flash', contents=prompt)
        text = res.text.replace('```json', '').replace('```', '').strip()
        return json.loads(text)
    except Exception as e:
        print(f"Templates Error: {e}")
        return {"templates": [{"title": "FIR Template", "content": "To the Officer in Charge..."}]}

@router.post("/generate-notice")
async def generate_notice(req: NoticeRequest):
    if not client:
        return {"draft": "AI not configured. Cannot generate notice."}
    try:
        prompt = f'''
Act as an expert Indian Lawyer. Draft a highly professional, court-ready Legal Notice based on the following details.

# Block A — Sender Details
Name: {req.senderName} (Father: {req.senderFathersName})
Address: {req.senderAddress}
Contact: {req.senderContact}, Email: {req.senderEmail}

# Block B — Opposite Party Details
Name: {req.opponentName} (Father: {req.opponentFathersName})
Address: {req.opponentAddress}
Business Type: {req.businessType}

# Block C — Relationship Context
The relationship between Sender and Opposite Party is: {req.relationship}

# Block D — Timeline Facts
Date of Agreement: {req.dateOfAgreement} (Nature: {req.natureOfAgreement})
Key Event Date: {req.keyEventDate}
Reminder Date(s): {req.reminderDate}
Breach Date: {req.breachDate}

# Block E — Claim Details
Amount Involved: {req.amountInvolved} via {req.modeOfTransaction}
Proof Available: {"Yes" if req.proofAvailable else "No"}
Relief Sought: {req.reliefSought}

# Block F — Legal Ground Selection
Contextual Legal Ground/Dispute Type: {req.legalGround}
*(Map this appropriately: e.g. Money -> Indian Contract Act, Consumer -> Consumer Protection Act, Rent -> Transfer of Property Act/Rent Control, etc.)*

**CRITICAL INSTRUCTION: You MUST format the output EXACTLY matching the STRUCTURE TEMPLATE below.**

STRUCTURE TEMPLATE (STRICT FORMAT)

[ADVOCATE LETTERHEAD OR SENDER ADDRESS]
(Left aligned)

Date: DD/MM/YYYY

To,
{req.opponentName}
{req.opponentAddress}

Subject: Legal Notice for {req.legalGround}

Sir/Madam,

Under instructions from and on behalf of my client Mr./Ms. {req.senderName}, residing at {req.senderAddress}, I hereby serve upon you the following legal notice:

1. That my client states that on [Insert Date], you [Insert relevant action based on facts].
2. That pursuant to the above, you had agreed to [Insert based on nature of agreement].
3. That despite repeated requests and reminders dated [Insert Date], you failed to [Insert breach detail].
4. That your acts amount to breach of {req.legalGround} and are illegal under [Cite specific Indian Law based on Legal Ground].
5. That my client has suffered financial loss and mental agony due to your actions.

Therefore, you are hereby called upon to [Insert Relief Sought: {req.reliefSought}] within 15 (fifteen) days from receipt of this notice.

Failing which, my client shall be constrained to initiate appropriate civil and/or criminal proceedings against you at your risk as to costs and consequences.

A copy of this notice is retained in my office for future reference.

Yours faithfully,

[Signature]
[Advocate Name]

Draft the notice entirely and strictly in {req.language} ONLY. If {req.language} is not English, do NOT include any English text or translation, but preserve the exact semantic structure.

**Return ONLY the plaintext drafted notice. Do not include markdown blocks like ``` or any commentary.**
        '''
        res = client.models.generate_content(model='gemini-2.5-flash', contents=prompt.strip())
        return {"draft": res.text.strip()}
    except Exception as e:
        print(f"Generate Notice Error: {e}")
        return {"draft": "Error generating notice. Please try again."}

