from dotenv import load_dotenv
load_dotenv()

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routes import chat, legal
import os
from supabase import create_client, Client

app = FastAPI(title="Legal AI Assistant API")

# CORS Middleware (Allow Flutter app to connect)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register Routers
app.include_router(chat.router, prefix="/api/chat", tags=["Chat"])
app.include_router(legal.router, prefix="/api/legal", tags=["Legal Resources"])

@app.get("/")
def read_root():
    return {"status": "Legal AI Backend is running"}
