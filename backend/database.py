import os
from supabase import create_client, Client
from dotenv import load_dotenv

load_dotenv()

supabase_url = os.environ.get("SUPABASE_URL", "")
supabase_key = os.environ.get("SUPABASE_KEY", "")

supabase: Client | None = None

if supabase_url and supabase_key and "YOUR_PROJECT_ID" not in supabase_url:
    try:
        supabase = create_client(supabase_url, supabase_key)
    except Exception as e:
        print(f"Error initializing Supabase: {e}")
else:
    print("Warning: Valid SUPABASE_URL or SUPABASE_KEY not found in environment.")
