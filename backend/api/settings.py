import os
from pathlib import Path
from dotenv import load_dotenv
from supabase import create_client

load_dotenv()

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_ANON_KEY = os.getenv("SUPABASE_ANON_KEY")
SUPABASE = create_client(SUPABASE_URL, SUPABASE_ANON_KEY)

BASE_DIR = Path(__file__).resolve().parent.parent

SECRET_KEY = 'django-insecure-your-secret-key-change-this-in-production'

DEBUG = True

ALLOWED_HOSTS = ['*']

INSTALLED_APPS = [
    'jazzmin',
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'rest_framework',
    'corsheaders',
    'myapi',
    'products',
    'penjual',

]

MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'api.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [BASE_DIR / 'templates'],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'api.wsgi.application'

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': 'postgres',
        'USER': 'postgres.mccdwczueketpqlbobyw',
        'PASSWORD': 'ayomagang12345',
        'HOST': 'aws-0-ap-southeast-1.pooler.supabase.com',
        'PORT': '5432',
    }
}

AUTH_PASSWORD_VALIDATORS = [
    {'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator'},
    {'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator'},
    {'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator'},
    {'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator'},
]

LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'Asia/Jakarta'
USE_I18N = True
USE_TZ = True

# Static files (CSS, JavaScript, Images)
STATIC_URL = '/static/'
STATIC_ROOT = BASE_DIR / 'staticfiles'

# Only include STATICFILES_DIRS if static directory exists
static_dir = BASE_DIR / 'static'
if static_dir.exists():
    STATICFILES_DIRS = [static_dir]
else:
    # Comment out STATICFILES_DIRS to avoid warning
    # STATICFILES_DIRS = [BASE_DIR / 'static']
    pass

MEDIA_URL = '/media/'
MEDIA_ROOT = BASE_DIR / 'media'

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

CORS_ALLOW_ALL_ORIGINS = True
CORS_ALLOWED_ORIGINS = [
    "http://localhost:3000",
    "http://127.0.0.1:8000",
]

REST_FRAMEWORK = {
    'DEFAULT_PERMISSION_CLASSES': ['rest_framework.permissions.AllowAny'],
    'DEFAULT_RENDERER_CLASSES': ['rest_framework.renderers.JSONRenderer'],
}

# DJANGO JAZZMIN CONFIGURATION
# settings.py - Simple Jazzmin Configuration

# settings.py - Simple Jazzmin Configuration

JAZZMIN_SETTINGS = {
    # Basic site info
    "site_title": "Store Admin",
    "site_header": "Store Management",
    "site_brand": "Store Admin",
    "welcome_sign": "Welcome to Store Management",
    "copyright": "Store Management 2024",
    
    # Simple navigation
    "topmenu_links": [
        {"name": "Home", "url": "admin:index"},
        {"name": "Sellers", "url": "admin:products_seller_changelist"},
        {"name": "Products", "url": "admin:products_supabaseproduct_changelist"},
        {"name": "Orders", "url": "admin:products_orderhistory_changelist"},
        {"name": "Contacts", "url": "admin:products_contact_changelist"},
    ],
    
    # Search
    "search_model": ["products.SupabaseProduct", "products.Seller"],
    
    # Clean sidebar
    "show_sidebar": True,
    "navigation_expanded": True,
    
    # Simple icons
    "icons": {
        "auth": "fas fa-users",
        "auth.user": "fas fa-user",
        "auth.Group": "fas fa-users",
        "products": "fas fa-store",
        "products.SupabaseProduct": "fas fa-box",
        "products.Seller": "fas fa-store",
        "products.OrderHistory": "fas fa-shopping-cart",
        "products.Contact": "fas fa-envelope",
    },
    
    # Clean form layout
    "changeform_format": "horizontal_tabs",
    "related_modal_active": False,
}

JAZZMIN_UI_TWEAKS = {
    # Clean color scheme - soft colors
    "navbar_small_text": False,
    "footer_small_text": False,
    "body_small_text": False,
    "brand_small_text": False,
    "brand_colour": "navbar-white",
    "accent": "accent-primary",
    "navbar": "navbar-white navbar-light",  # Clean white navbar
    "no_navbar_border": False,
    "navbar_fixed": False,
    "layout_boxed": False,
    "footer_fixed": False,
    "sidebar_fixed": True,
    "sidebar": "sidebar-light-primary",  # Light sidebar, easy on eyes
    "sidebar_nav_small_text": False,
    "sidebar_disable_expand": False,  # Allow expand/collapse
    "sidebar_nav_child_indent": False,
    "sidebar_nav_compact_style": True,  # Compact style - lebih kecil
    "sidebar_nav_legacy_style": False,
    "sidebar_nav_flat_style": True,  # Flat, clean style
    
    # Use default theme (clean & readable)
    "theme": "default",
    "dark_mode_theme": None,
    
    # Simple button styling
    "button_classes": {
        "primary": "btn-outline-primary",
        "secondary": "btn-outline-secondary", 
        "info": "btn-outline-info",
        "warning": "btn-outline-warning",
        "danger": "btn-outline-danger",
        "success": "btn-outline-success"
    },
}

# Optional: Very minimal custom CSS
JAZZMIN_SETTINGS["custom_css"] = "admin/css/simple_admin.css"