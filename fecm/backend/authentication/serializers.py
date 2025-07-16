from rest_framework import serializers
from django.contrib.auth import authenticate
from django.contrib.auth.password_validation import validate_password
from django.core.exceptions import ValidationError
from .models import CustomUser

class UserRegistrationSerializer(serializers.ModelSerializer):
    """
    Serializer untuk registrasi user baru
    """
    password = serializers.CharField(
        write_only=True, 
        min_length=8,
        style={'input_type': 'password'}
    )
    password_confirm = serializers.CharField(
        write_only=True,
        style={'input_type': 'password'}
    )
    
    class Meta:
        model = CustomUser
        fields = (
            'email', 
            'username', 
            'first_name', 
            'last_name', 
            'password', 
            'password_confirm'
        )
        extra_kwargs = {
            'email': {'required': True},
            'username': {'required': True},
            'first_name': {'required': True},
            'last_name': {'required': True},
        }
    
    def validate_email(self, value):
        """Validasi email unik"""
        if CustomUser.objects.filter(email=value.lower()).exists():
            raise serializers.ValidationError("Email sudah terdaftar")
        return value.lower()
    
    def validate_username(self, value):
        """Validasi username unik"""
        if CustomUser.objects.filter(username=value).exists():
            raise serializers.ValidationError("Username sudah digunakan")
        return value
    
    def validate_password(self, value):
        """Validasi password strength"""
        try:
            validate_password(value)
        except ValidationError as e:
            raise serializers.ValidationError(e.messages)
        return value
    
    def validate(self, attrs):
        """Validasi password confirm"""
        if attrs['password'] != attrs['password_confirm']:
            raise serializers.ValidationError({
                "password_confirm": "Password tidak cocok"
            })
        return attrs
    
    def create(self, validated_data):
        """Buat user baru"""
        # Hapus password_confirm sebelum create
        validated_data.pop('password_confirm')
        
        # Create user dengan password ter-hash
        user = CustomUser.objects.create_user(**validated_data)
        return user

class UserLoginSerializer(serializers.Serializer):
    """
    Serializer untuk login user
    """
    email = serializers.EmailField(required=True)
    password = serializers.CharField(
        required=True,
        style={'input_type': 'password'}
    )
    
    def validate(self, attrs):
        email = attrs.get('email')
        password = attrs.get('password')
        
        if email and password:
            # Authenticate user
            user = authenticate(username=email.lower(), password=password)
            
            if not user:
                raise serializers.ValidationError(
                    'Email atau password salah'
                )
            
            if not user.is_active:
                raise serializers.ValidationError(
                    'Akun telah dinonaktifkan'
                )
            
            # Add user to validated data
            attrs['user'] = user
            return attrs
        
        raise serializers.ValidationError(
            'Email dan password wajib diisi'
        )

class UserSerializer(serializers.ModelSerializer):
    """
    Serializer untuk data user (response)
    """
    full_name = serializers.SerializerMethodField()
    
    class Meta:
        model = CustomUser
        fields = (
            'id', 
            'email', 
            'username', 
            'first_name', 
            'last_name',
            'full_name',
            'is_verified', 
            'created_at'
        )
        read_only_fields = ('id', 'created_at')
    
    def get_full_name(self, obj):
        return obj.get_full_name()

class ChangePasswordSerializer(serializers.Serializer):
    """
    Serializer untuk ganti password
    """
    old_password = serializers.CharField(required=True)
    new_password = serializers.CharField(required=True, min_length=8)
    new_password_confirm = serializers.CharField(required=True)
    
    def validate_new_password(self, value):
        try:
            validate_password(value)
        except ValidationError as e:
            raise serializers.ValidationError(e.messages)
        return value
    
    def validate(self, attrs):
        if attrs['new_password'] != attrs['new_password_confirm']:
            raise serializers.ValidationError({
                "new_password_confirm": "Password baru tidak cocok"
            })
        return attrs