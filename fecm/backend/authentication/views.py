from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.exceptions import TokenError
from django.contrib.auth import authenticate, update_session_auth_hash
from django.contrib.auth.hashers import make_password
from django.conf import settings
from django.utils import timezone
from django.db import transaction
from google.oauth2 import id_token
from google.auth.transport import requests
import json
import requests as python_requests
import logging

from .serializers import (
    UserRegistrationSerializer, 
    UserLoginSerializer, 
    UserSerializer,
    ChangePasswordSerializer
)
from .models import CustomUser

# Setup logging
logger = logging.getLogger(__name__)

def get_tokens_for_user(user):
    """
    Helper function untuk generate JWT tokens
    """
    refresh = RefreshToken.for_user(user)
    return {
        'refresh': str(refresh),
        'access': str(refresh.access_token),
    }

@api_view(['POST'])
@permission_classes([AllowAny])
def register(request):
    """
    POST /api/auth/register/
    Register user baru
    """
    try:
        logger.info(f"Registration attempt for email: {request.data.get('email')}")
        
        serializer = UserRegistrationSerializer(data=request.data)
        
        if serializer.is_valid():
            try:
                with transaction.atomic():
                    # Create user
                    user = serializer.save()
                    
                    # Generate tokens
                    tokens = get_tokens_for_user(user)
                    
                    # Serialize user data
                    user_data = UserSerializer(user).data
                    
                    logger.info(f"User successfully registered: {user.email}")
                    
                    return Response({
                        'success': True,
                        'message': 'Registrasi berhasil',
                        'user': user_data,
                        'tokens': tokens
                    }, status=status.HTTP_201_CREATED)
                    
            except Exception as e:
                logger.error(f"Registration error: {str(e)}")
                return Response({
                    'success': False,
                    'message': 'Terjadi kesalahan saat registrasi',
                    'errors': str(e)
                }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        
        logger.warning(f"Registration validation failed: {serializer.errors}")
        return Response({
            'success': False,
            'message': 'Data tidak valid',
            'errors': serializer.errors
        }, status=status.HTTP_400_BAD_REQUEST)
        
    except Exception as e:
        logger.error(f"Unexpected registration error: {str(e)}")
        return Response({
            'success': False,
            'message': 'Terjadi kesalahan sistem',
            'errors': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['POST'])
@permission_classes([AllowAny])
def login(request):
    """
    POST /api/auth/login/
    Login user dengan email dan password
    """
    try:
        logger.info(f"Login attempt for email: {request.data.get('email')}")
        
        serializer = UserLoginSerializer(data=request.data)
        
        if serializer.is_valid():
            try:
                # Get authenticated user
                user = serializer.validated_data['user']
                
                # Update last login
                user.last_login = timezone.now()
                user.save(update_fields=['last_login'])
                
                # Generate tokens
                tokens = get_tokens_for_user(user)
                
                # Serialize user data
                user_data = UserSerializer(user).data
                
                logger.info(f"User successfully logged in: {user.email}")
                
                return Response({
                    'success': True,
                    'message': 'Login berhasil',
                    'user': user_data,
                    'tokens': tokens,
                    'auth_method': 'regular'
                }, status=status.HTTP_200_OK)
                
            except Exception as e:
                logger.error(f"Login processing error: {str(e)}")
                return Response({
                    'success': False,
                    'message': 'Terjadi kesalahan saat login',
                    'errors': str(e)
                }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
        
        logger.warning(f"Login validation failed: {serializer.errors}")
        return Response({
            'success': False,
            'message': 'Email atau password salah',
            'errors': serializer.errors
        }, status=status.HTTP_400_BAD_REQUEST)
        
    except Exception as e:
        logger.error(f"Unexpected login error: {str(e)}")
        return Response({
            'success': False,
            'message': 'Terjadi kesalahan sistem',
            'errors': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['POST'])
@permission_classes([AllowAny])
def google_login(request):
    """
    POST /api/auth/google-login/
    Login dengan Google OAuth token (support both ID token and Access token)
    """
    try:
        google_token = request.data.get('google_token')
        token_type = request.data.get('token_type', 'id_token')
        
        if not google_token:
            logger.warning("Google login attempted without token")
            return Response({
                'success': False,
                'message': 'Google token is required'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        logger.info(f"Google login attempt with {token_type}")
        
        # Verify Google token and get user info
        user_info = None
        
        # Handle ID Token (preferred method)
        if token_type == 'id_token':
            try:
                # Verify the ID token with Google
                idinfo = id_token.verify_oauth2_token(
                    google_token, 
                    requests.Request(),
                    settings.GOOGLE_CLIENT_ID
                )
                
                user_info = {
                    'google_user_id': idinfo['sub'],
                    'email': idinfo['email'],
                    'first_name': idinfo.get('given_name', ''),
                    'last_name': idinfo.get('family_name', ''),
                    'name': idinfo.get('name', ''),
                    'picture': idinfo.get('picture', ''),
                    'email_verified': idinfo.get('email_verified', False)
                }
                
                logger.info(f"Google ID token verified for: {user_info['email']}")
                
            except ValueError as e:
                logger.error(f"Google ID token verification failed: {str(e)}")
                return Response({
                    'success': False,
                    'message': 'Invalid Google ID token'
                }, status=status.HTTP_400_BAD_REQUEST)
                
        # Handle Access Token (fallback for web)
        elif token_type == 'access_token':
            try:
                # Verify access token by calling Google's userinfo endpoint
                userinfo_url = f'https://www.googleapis.com/oauth2/v2/userinfo?access_token={google_token}'
                response = python_requests.get(userinfo_url, timeout=10)
                
                if response.status_code != 200:
                    logger.error(f"Google access token verification failed: {response.status_code}")
                    return Response({
                        'success': False,
                        'message': 'Invalid Google access token'
                    }, status=status.HTTP_400_BAD_REQUEST)
                
                userinfo = response.json()
                
                user_info = {
                    'google_user_id': userinfo['id'],
                    'email': userinfo['email'],
                    'first_name': userinfo.get('given_name', ''),
                    'last_name': userinfo.get('family_name', ''),
                    'name': userinfo.get('name', ''),
                    'picture': userinfo.get('picture', ''),
                    'email_verified': userinfo.get('verified_email', False)
                }
                
                logger.info(f"Google access token verified for: {user_info['email']}")
                
            except Exception as e:
                logger.error(f"Google access token verification failed: {str(e)}")
                return Response({
                    'success': False,
                    'message': 'Invalid Google access token'
                }, status=status.HTTP_400_BAD_REQUEST)
        
        else:
            logger.warning(f"Invalid token type: {token_type}")
            return Response({
                'success': False,
                'message': 'Invalid token type'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Process user info
        if not user_info:
            logger.error("Failed to get user info from Google")
            return Response({
                'success': False,
                'message': 'Failed to get user info from Google'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Extract user data
        email = user_info['email']
        first_name = user_info['first_name']
        last_name = user_info['last_name']
        name = user_info['name'] or f"{first_name} {last_name}".strip()
        picture = user_info['picture']
        
        logger.info(f"Processing Google user: {name} ({email})")
        
        # Find or create user
        with transaction.atomic():
            try:
                # Check if user exists
                user = CustomUser.objects.get(email=email)
                logger.info(f"Existing user found: {user.email}")
                
                # Update user info if needed
                update_fields = []
                if user.first_name != first_name:
                    user.first_name = first_name
                    update_fields.append('first_name')
                if user.last_name != last_name:
                    user.last_name = last_name
                    update_fields.append('last_name')
                
                if update_fields:
                    user.save(update_fields=update_fields)
                    logger.info(f"Updated user info for: {user.email}")
                    
            except CustomUser.DoesNotExist:
                # Create new user
                logger.info(f"Creating new user for: {email}")
                
                # Generate unique username from email
                username = email.split('@')[0]
                counter = 1
                original_username = username
                while CustomUser.objects.filter(username=username).exists():
                    username = f"{original_username}{counter}"
                    counter += 1
                
                user = CustomUser.objects.create_user(
                    email=email,
                    username=username,
                    first_name=first_name,
                    last_name=last_name,
                    password=None,  # No password for Google users
                    is_active=True,
                    is_verified=user_info.get('email_verified', False)
                )
                
                logger.info(f"Created new user: {user.email} with username: {user.username}")
            
            # Update last login
            user.last_login = timezone.now()
            user.save(update_fields=['last_login'])
            
            # Generate JWT tokens
            tokens = get_tokens_for_user(user)
            
            # Serialize user data
            user_data = UserSerializer(user).data
            
            logger.info(f"Google login successful for: {user.email}")
            
            return Response({
                'success': True,
                'message': 'Google login berhasil',
                'user': user_data,
                'tokens': tokens,
                'auth_method': 'google',
                'google_info': {
                    'picture': picture,
                    'email_verified': user_info.get('email_verified', False)
                }
            }, status=status.HTTP_200_OK)
        
    except Exception as e:
        logger.error(f"Unexpected Google login error: {str(e)}")
        return Response({
            'success': False,
            'message': 'Google login failed',
            'errors': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def logout(request):
    """
    POST /api/auth/logout/
    Logout user (blacklist refresh token)
    """
    try:
        refresh_token = request.data.get("refresh")
        
        if refresh_token:
            try:
                token = RefreshToken(refresh_token)
                token.blacklist()
                
                logger.info(f"User logged out successfully: {request.user.email}")
                
                return Response({
                    'success': True,
                    'message': 'Logout berhasil'
                }, status=status.HTTP_200_OK)
                
            except TokenError as e:
                logger.warning(f"Token error during logout: {str(e)}")
                return Response({
                    'success': False,
                    'message': 'Token tidak valid atau sudah expired'
                }, status=status.HTTP_400_BAD_REQUEST)
        else:
            logger.warning("Logout attempted without refresh token")
            return Response({
                'success': False,
                'message': 'Refresh token diperlukan'
            }, status=status.HTTP_400_BAD_REQUEST)
            
    except Exception as e:
        logger.error(f"Unexpected logout error: {str(e)}")
        return Response({
            'success': False,
            'message': 'Terjadi kesalahan saat logout',
            'errors': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def profile(request):
    """
    GET /api/auth/profile/
    Get user profile (butuh authentication)
    """
    try:
        user_data = UserSerializer(request.user).data
        
        logger.info(f"Profile accessed by: {request.user.email}")
        
        return Response({
            'success': True,
            'user': user_data
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        logger.error(f"Profile access error: {str(e)}")
        return Response({
            'success': False,
            'message': 'Terjadi kesalahan saat mengambil profil',
            'errors': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['PUT', 'PATCH'])
@permission_classes([IsAuthenticated])
def update_profile(request):
    """
    PUT/PATCH /api/auth/profile/update/
    Update user profile
    """
    try:
        serializer = UserSerializer(
            request.user, 
            data=request.data, 
            partial=True
        )
        
        if serializer.is_valid():
            with transaction.atomic():
                user = serializer.save()
                
                logger.info(f"Profile updated for: {user.email}")
                
                return Response({
                    'success': True,
                    'message': 'Profil berhasil diupdate',
                    'user': UserSerializer(user).data
                }, status=status.HTTP_200_OK)
        
        logger.warning(f"Profile update validation failed: {serializer.errors}")
        return Response({
            'success': False,
            'message': 'Data tidak valid',
            'errors': serializer.errors
        }, status=status.HTTP_400_BAD_REQUEST)
        
    except Exception as e:
        logger.error(f"Profile update error: {str(e)}")
        return Response({
            'success': False,
            'message': 'Terjadi kesalahan saat update profil',
            'errors': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def change_password(request):
    """
    POST /api/auth/change-password/
    Ganti password user
    """
    try:
        serializer = ChangePasswordSerializer(data=request.data)
        
        if serializer.is_valid():
            user = request.user
            
            # Check if user has password (Google users might not have password)
            if not user.password:
                logger.warning(f"Password change attempted for Google user: {user.email}")
                return Response({
                    'success': False,
                    'message': 'Akun Google tidak memiliki password. Gunakan Google untuk login.'
                }, status=status.HTTP_400_BAD_REQUEST)
            
            # Check old password
            if not user.check_password(serializer.validated_data['old_password']):
                logger.warning(f"Wrong old password for user: {user.email}")
                return Response({
                    'success': False,
                    'message': 'Password lama salah'
                }, status=status.HTTP_400_BAD_REQUEST)
            
            # Set new password
            with transaction.atomic():
                user.set_password(serializer.validated_data['new_password'])
                user.save()
                
                # Update session (optional untuk web)
                update_session_auth_hash(request, user)
                
                logger.info(f"Password changed successfully for: {user.email}")
                
                return Response({
                    'success': True,
                    'message': 'Password berhasil diubah'
                }, status=status.HTTP_200_OK)
        
        logger.warning(f"Password change validation failed: {serializer.errors}")
        return Response({
            'success': False,
            'message': 'Data tidak valid',
            'errors': serializer.errors
        }, status=status.HTTP_400_BAD_REQUEST)
        
    except Exception as e:
        logger.error(f"Password change error: {str(e)}")
        return Response({
            'success': False,
            'message': 'Terjadi kesalahan saat mengubah password',
            'errors': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['POST'])
@permission_classes([AllowAny])
def refresh_token(request):
    """
    POST /api/auth/refresh/
    Refresh access token
    """
    try:
        refresh_token = request.data.get('refresh')
        
        if refresh_token:
            try:
                refresh = RefreshToken(refresh_token)
                
                logger.info("Token refreshed successfully")
                
                return Response({
                    'success': True,
                    'access': str(refresh.access_token)
                }, status=status.HTTP_200_OK)
                
            except TokenError as e:
                logger.warning(f"Token refresh failed: {str(e)}")
                return Response({
                    'success': False,
                    'message': 'Refresh token tidak valid atau expired'
                }, status=status.HTTP_401_UNAUTHORIZED)
        else:
            logger.warning("Token refresh attempted without refresh token")
            return Response({
                'success': False,
                'message': 'Refresh token diperlukan'
            }, status=status.HTTP_400_BAD_REQUEST)
            
    except Exception as e:
        logger.error(f"Unexpected token refresh error: {str(e)}")
        return Response({
            'success': False,
            'message': 'Terjadi kesalahan saat refresh token',
            'errors': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def verify_email(request):
    """
    POST /api/auth/verify-email/
    Verify user email (placeholder for future implementation)
    """
    try:
        user = request.user
        
        # TODO: Implement email verification logic
        # For now, just mark as verified
        user.is_verified = True
        user.save(update_fields=['is_verified'])
        
        logger.info(f"Email verified for: {user.email}")
        
        return Response({
            'success': True,
            'message': 'Email berhasil diverifikasi'
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        logger.error(f"Email verification error: {str(e)}")
        return Response({
            'success': False,
            'message': 'Terjadi kesalahan saat verifikasi email',
            'errors': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['POST'])
@permission_classes([AllowAny])
def forgot_password(request):
    """
    POST /api/auth/forgot-password/
    Forgot password (placeholder for future implementation)
    """
    try:
        email = request.data.get('email')
        
        if not email:
            return Response({
                'success': False,
                'message': 'Email is required'
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # TODO: Implement forgot password logic
        # For now, just return success message
        logger.info(f"Forgot password requested for: {email}")
        
        return Response({
            'success': True,
            'message': 'Jika email terdaftar, link reset password akan dikirim'
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        logger.error(f"Forgot password error: {str(e)}")
        return Response({
            'success': False,
            'message': 'Terjadi kesalahan saat memproses permintaan',
            'errors': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['DELETE'])
@permission_classes([IsAuthenticated])
def delete_account(request):
    """
    DELETE /api/auth/delete-account/
    Delete user account
    """
    try:
        user = request.user
        email = user.email
        
        # TODO: Add additional confirmation logic
        # For now, just deactivate account
        user.is_active = False
        user.save(update_fields=['is_active'])
        
        logger.info(f"Account deleted/deactivated for: {email}")
        
        return Response({
            'success': True,
            'message': 'Akun berhasil dihapus'
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        logger.error(f"Account deletion error: {str(e)}")
        return Response({
            'success': False,
            'message': 'Terjadi kesalahan saat menghapus akun',
            'errors': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def user_stats(request):
    """
    GET /api/auth/stats/
    Get user statistics
    """
    try:
        user = request.user
        
        # Calculate stats
        stats = {
            'total_logins': 0,  # TODO: Implement login tracking
            'account_age_days': (timezone.now() - user.date_joined).days,
            'is_verified': user.is_verified,
            'last_login': user.last_login.isoformat() if user.last_login else None,
            'date_joined': user.date_joined.isoformat(),
            'auth_method': 'google' if not user.password else 'regular'
        }
        
        logger.info(f"Stats accessed by: {user.email}")
        
        return Response({
            'success': True,
            'stats': stats
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        logger.error(f"User stats error: {str(e)}")
        return Response({
            'success': False,
            'message': 'Terjadi kesalahan saat mengambil statistik',
            'errors': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)