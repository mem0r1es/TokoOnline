import os
import django
from django.conf import settings

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'core.settings')
django.setup()

import jwt
import json
from datetime import datetime
from django.contrib.auth import get_user_model

User = get_user_model()

# Token dari response register lo
access_token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzUyNjQ2MjYzLCJpYXQiOjE3NTI2NDI2NjMsImp0aSI6IjJmNDFmMmI3ZWM5NzRlOTc4ODVkMDAzMjNjOTk3NzVjIiwidXNlcl9pZCI6MX0.zOrPMC_UbiXJpUTv_rS1QWALa4VKNOpPibBj2pZ939E"

print("=== JWT DEBUG ===")
print(f"Token: {access_token[:50]}...")
print(f"Token length: {len(access_token)}")

# Cek isi token (decode tanpa verify)
try:
    decoded = jwt.decode(access_token, options={"verify_signature": False})
    print("\n=== TOKEN CONTENTS ===")
    print(json.dumps(decoded, indent=2))
    
    # Cek expiry
    if 'exp' in decoded:
        exp_time = decoded['exp']
        current_time = datetime.now().timestamp()
        
        print(f"\n=== TOKEN EXPIRY ===")
        print(f"Expires at: {datetime.fromtimestamp(exp_time)}")
        print(f"Current time: {datetime.fromtimestamp(current_time)}")
        
        if current_time > exp_time:
            print("❌ TOKEN EXPIRED!")
        else:
            print("✅ Token masih valid")
            
    # Cek user_id
    if 'user_id' in decoded:
        user_id = decoded['user_id']
        try:
            user = User.objects.get(id=user_id)
            print(f"\n=== USER CHECK ===")
            print(f"User found: {user.email}")
            print(f"User active: {user.is_active}")
        except User.DoesNotExist:
            print(f"❌ User ID {user_id} tidak ditemukan!")
            
except Exception as e:
    print(f"❌ Error decoding token: {e}")

# Cek Django JWT settings
print(f"\n=== DJANGO SETTINGS ===")
print(f"SECRET_KEY: {settings.SECRET_KEY[:10]}...")
print(f"JWT Settings: {getattr(settings, 'SIMPLE_JWT', 'Not found')}")

# Test manual verify
try:
    from rest_framework_simplejwt.tokens import AccessToken
    token_obj = AccessToken(access_token)
    print(f"\n✅ JWT Library bisa parse token")
    print(f"User ID: {token_obj['user_id']}")
except Exception as e:
    print(f"\n❌ JWT Library error: {e}")