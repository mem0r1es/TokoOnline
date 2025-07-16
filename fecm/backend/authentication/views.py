from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.exceptions import TokenError
from django.contrib.auth import update_session_auth_hash
from .serializers import (
    UserRegistrationSerializer, 
    UserLoginSerializer, 
    UserSerializer,
    ChangePasswordSerializer
)
from .models import CustomUser

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
    serializer = UserRegistrationSerializer(data=request.data)
    
    if serializer.is_valid():
        try:
            # Create user
            user = serializer.save()
            
            # Generate tokens
            tokens = get_tokens_for_user(user)
            
            # Serialize user data
            user_data = UserSerializer(user).data
            
            return Response({
                'success': True,
                'message': 'Registrasi berhasil',
                'user': user_data,
                'tokens': tokens
            }, status=status.HTTP_201_CREATED)
            
        except Exception as e:
            return Response({
                'success': False,
                'message': 'Terjadi kesalahan saat registrasi',
                'errors': str(e)
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
    return Response({
        'success': False,
        'message': 'Data tidak valid',
        'errors': serializer.errors
    }, status=status.HTTP_400_BAD_REQUEST)

@api_view(['POST'])
@permission_classes([AllowAny])
def login(request):
    """
    POST /api/auth/login/
    Login user
    """
    serializer = UserLoginSerializer(data=request.data)
    
    if serializer.is_valid():
        try:
            # Get authenticated user
            user = serializer.validated_data['user']
            
            # Generate tokens
            tokens = get_tokens_for_user(user)
            
            # Serialize user data
            user_data = UserSerializer(user).data
            
            return Response({
                'success': True,
                'message': 'Login berhasil',
                'user': user_data,
                'tokens': tokens
            }, status=status.HTTP_200_OK)
            
        except Exception as e:
            return Response({
                'success': False,
                'message': 'Terjadi kesalahan saat login',
                'errors': str(e)
            }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
    return Response({
        'success': False,
        'message': 'Login gagal',
        'errors': serializer.errors
    }, status=status.HTTP_400_BAD_REQUEST)

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
            token = RefreshToken(refresh_token)
            token.blacklist()
            
            return Response({
                'success': True,
                'message': 'Logout berhasil'
            }, status=status.HTTP_200_OK)
        else:
            return Response({
                'success': False,
                'message': 'Refresh token diperlukan'
            }, status=status.HTTP_400_BAD_REQUEST)
            
    except TokenError:
        return Response({
            'success': False,
            'message': 'Token tidak valid atau sudah expired'
        }, status=status.HTTP_400_BAD_REQUEST)
    except Exception as e:
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
        
        return Response({
            'success': True,
            'user': user_data
        }, status=status.HTTP_200_OK)
        
    except Exception as e:
        return Response({
            'success': False,
            'message': 'Terjadi kesalahan saat mengambil profil',
            'errors': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

@api_view(['PUT'])
@permission_classes([IsAuthenticated])
def update_profile(request):
    """
    PUT /api/auth/profile/
    Update user profile
    """
    try:
        serializer = UserSerializer(
            request.user, 
            data=request.data, 
            partial=True
        )
        
        if serializer.is_valid():
            serializer.save()
            
            return Response({
                'success': True,
                'message': 'Profil berhasil diupdate',
                'user': serializer.data
            }, status=status.HTTP_200_OK)
        
        return Response({
            'success': False,
            'message': 'Data tidak valid',
            'errors': serializer.errors
        }, status=status.HTTP_400_BAD_REQUEST)
        
    except Exception as e:
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
            
            # Check old password
            if not user.check_password(serializer.validated_data['old_password']):
                return Response({
                    'success': False,
                    'message': 'Password lama salah'
                }, status=status.HTTP_400_BAD_REQUEST)
            
            # Set new password
            user.set_password(serializer.validated_data['new_password'])
            user.save()
            
            # Update session (optional untuk web)
            update_session_auth_hash(request, user)
            
            return Response({
                'success': True,
                'message': 'Password berhasil diubah'
            }, status=status.HTTP_200_OK)
        
        return Response({
            'success': False,
            'message': 'Data tidak valid',
            'errors': serializer.errors
        }, status=status.HTTP_400_BAD_REQUEST)
        
    except Exception as e:
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
            refresh = RefreshToken(refresh_token)
            
            return Response({
                'success': True,
                'access': str(refresh.access_token)
            }, status=status.HTTP_200_OK)
        else:
            return Response({
                'success': False,
                'message': 'Refresh token diperlukan'
            }, status=status.HTTP_400_BAD_REQUEST)
            
    except TokenError:
        return Response({
            'success': False,
            'message': 'Refresh token tidak valid atau expired'
        }, status=status.HTTP_401_UNAUTHORIZED)
    except Exception as e:
        return Response({
            'success': False,
            'message': 'Terjadi kesalahan saat refresh token',
            'errors': str(e)
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)