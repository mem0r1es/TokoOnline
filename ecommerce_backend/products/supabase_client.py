import os
from supabase import create_client, Client
from django.conf import settings

def get_supabase_client() -> Client:
    """Create and return Supabase client for products"""
    url = settings.SUPABASE_URL
    key = settings.SUPABASE_KEY
    
    if not url or not key:
        raise ValueError("Supabase URL and Key must be set in environment variables")
    
    return create_client(url, key)

# Initialize Supabase client
supabase_client = get_supabase_client()