from django.shortcuts import render
from django.contrib.auth.decorators import login_required
from supabase import create_client
import os
from dotenv import load_dotenv

load_dotenv()
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_ANON_KEY = os.getenv("SUPABASE_ANON_KEY")
supabase = create_client(SUPABASE_URL, SUPABASE_ANON_KEY)

@login_required
def dashboard(request):
    return render(request, 'penjual/dashboard.html')

@login_required
def product_list(request):
    email = request.user.email

    # Ambil produk milik seller ini
    response = supabase.table('products').select('*').eq('seller_email', email).execute()
    products = response.data or []

    context = {
        'products': products
    }
    return render(request, 'penjual/product_list.html', context)
