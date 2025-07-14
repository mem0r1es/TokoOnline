from django.views.decorators.csrf import csrf_exempt
from django.shortcuts import render, redirect
from django.http import HttpResponse, HttpResponseRedirect
from django.contrib.auth.decorators import login_required
from django.urls import reverse
from supabase import create_client
import os
import uuid
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
    seller_email = request.user.email

    seller_lookup = supabase.table("sellers").select("id").eq("email", seller_email).execute()
    if not seller_lookup.data:
        return HttpResponse("Seller not found", status=404)

    seller_id = seller_lookup.data[0]['id']

    products = supabase.table("products").select("*").eq("seller_id", seller_id).execute().data

    return render(request, 'penjual/product_list.html', {'products': products})

@csrf_exempt
@login_required
def tambah_produk(request):
    if request.method == 'POST':
        name = request.POST.get('name', '').strip()
        price = request.POST.get('price', '').strip()
        stock = request.POST.get('stock', '').strip()
        description = request.POST.get('description', '').strip()
        category = request.POST.get('category', '').strip()
        image_file = request.FILES.get('image_file')

        if not name or not price or not image_file:
            return HttpResponse("Nama, harga, dan gambar wajib diisi", status=400)

        email = request.user.email
        seller_lookup = supabase.table("sellers").select("id").eq("email", email).execute()
        if not seller_lookup.data:
            return HttpResponse("Seller tidak ditemukan", status=404)

        seller_id = seller_lookup.data[0]['id']

        # Upload gambar (perbaikan: gunakan .read() untuk ambil isi file sebagai bytes)
        filename = f"{uuid.uuid4()}_{image_file.name}"
        supabase.storage.from_("product-images").upload(
            path=filename,
            file=image_file.read(),
            file_options={"content-type": image_file.content_type}
        )
        image_url = f"{SUPABASE_URL}/storage/v1/object/public/product-images/{filename}"

        supabase.table("products").insert({
            "name": name,
            "price": float(price),
            "stock": int(stock),
            "description": description,
            "category": category,
            "image_url": image_url,
            "seller_id": seller_id,
        }).execute()

        return HttpResponseRedirect(reverse('product_list'))

    return render(request, 'penjual/add_product.html')
