from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field
from typing import List, Optional
import os
import base64
import asyncio
from database import supabase
from google import genai
from google.genai import types

router = APIRouter()

# Initialize Gemini Client
try:
    api_key = os.environ.get("GEMINI_API_KEY")
    client = genai.Client(api_key=api_key)
except Exception as e:
    client = None
    print(f"GenAI Client Error: {e}")

class ChatMessage(BaseModel):
    role: str
    content: str
    
class ChatRequest(BaseModel):
    conversation_id: str
    messages: List[ChatMessage]
    language: str
    document_base64: Optional[str] = None
    document_mime_type: Optional[str] = None

class ChatResponseSchema(BaseModel):
    response: str = Field(description="The main text response of the AI assistant")
    suggestions: list[str] = Field(description="A list of 3 short follow-up suggestions for the user to ask next")

class TitleRequest(BaseModel):
    conversation_id: str
    messages: List[ChatMessage]

@router.post("/")
async def chat_endpoint(request: ChatRequest):
    if not client:
        raise HTTPException(status_code=500, detail="Gemini API is not fully configured.")

    # Convert messages into GenAI format
    contents = []
    
    for msg in request.messages:
        role = "model" if msg.role == "assistant" else "user"
        contents.append(types.Content(role=role, parts=[types.Part.from_text(text=msg.content)]))
    
    if request.document_base64 and request.document_mime_type:
        try:
            file_bytes = base64.b64decode(request.document_base64)
            doc_part = types.Part.from_bytes(data=file_bytes, mime_type=request.document_mime_type)
            # Find the last user message to attach the document
            for content in reversed(contents):
                if content.role == "user":
                    content.parts.append(doc_part)
                    break
        except Exception as e:
            print(f"Error decoding document: {e}")
    
    # Find the last user message to query the law DB
    last_user_message = ""
    for msg in reversed(request.messages):
        if msg.role == "user":
            last_user_message = msg.content
            break
            
    # RAG Retrieval
    legal_context = ""
    if last_user_message:
        try:
            from Rag_ingest import query_law_db
            retrieved_chunks = await asyncio.to_thread(query_law_db, last_user_message, 5)
            if retrieved_chunks:
                context_parts = []
                for c in retrieved_chunks:
                    context_parts.append(f"**{c['metadata']['title']}** ({c['metadata']['act']})\n{c['content']}")
                legal_context = "\n\n---\n\n".join(context_parts)
        except Exception as e:
            print(f"RAG Retrieval Error: {e}")
            
    # Instruction for legal and language translation with RAG context
    system_instruction = f"""You are Law.Ai, a helpful AI Legal Assistant specializing in Indian law. 
You MUST generate your ENTIRE response STRICTLY in {request.language} ONLY. Do NOT include any English translation or English text, unless the requested language is English. 
If interpreting an uploaded document (like an FIR copy, notice, or agreement), strictly provide 'Step-by-Step Legal Guidance' (e.g., 'What to do after FIR?' or 'How to file a complaint?'). 

Use the provided LEGAL CONTEXT below to inform your answer. If the answer is not in the context, you may use your general knowledge but prioritize the provided context. Always mention the relevant Act and Section from the context when applicable.

You must output valid JSON matching the schema. IMPORTANT FORMATTING RULE: When returning lists or points, strictly separate each point with double newlines (\\n\\n) so they start on a fresh line and have space between them.

LEGAL CONTEXT (Use this to anchor your response):
{legal_context if legal_context else 'No specific context retrieved.'}"""
    
    config = types.GenerateContentConfig(
        system_instruction=system_instruction,
        temperature=0.3,
        response_mime_type="application/json",
        response_schema=ChatResponseSchema,
    )
    
    try:
        response = await asyncio.to_thread(
            client.models.generate_content,
            model='gemini-2.5-flash',
            contents=contents,
            config=config,
        )
        return {"response": response.text}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to generate response: {e}")

@router.post("/generate-title")
async def generate_title(request: TitleRequest):
    if not client:
        return {"title": "New Legal Chat"}
    
    prompt = "Summarize the following chat into a 3 to 5 word title:\n\n"
    for msg in request.messages:
        prompt += f"{msg.role}: {msg.content}\n"
        
    try:
        response = await asyncio.to_thread(
            client.models.generate_content,
            model='gemini-2.5-flash',
            contents=prompt,
        )
        return {"title": response.text.replace('"', '').strip()}
    except Exception:
        return {"title": "New Legal Chat"}

@router.get("/chat-history")
async def get_chat_history(user_id: str):
    if not supabase:
        return {"conversations": []}
    try:
        data = supabase.table("conversations").select("*").eq("user_id", user_id).execute()
        return {"conversations": data.data}
    except Exception as e:
        print(f"Supabase Error: {e}")
        return {"conversations": []}

@router.put("/rename-chat/{conversation_id}")
async def rename_chat(conversation_id: str, new_title: str):
    if not supabase:
        return {"status": "error", "message": "Supabase not configured"}
    try:
        supabase.table("conversations").update({"title": new_title}).eq("id", conversation_id).execute()
        return {"status": "success"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/delete-chat/{conversation_id}")
async def delete_chat(conversation_id: str):
    if not supabase:
        return {"status": "error", "message": "Supabase not configured"}
    try:
        supabase.table("conversations").delete().eq("id", conversation_id).execute()
        return {"status": "success"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
