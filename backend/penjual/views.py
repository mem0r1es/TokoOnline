from django.shortcuts import render
from django.shortcuts import render
from django.contrib.auth.decorators import login_required

@login_required
def dashboard(request):
    return render(request, 'penjual/dashboard.html')

@login_required
def product_list(request):
    return render(request, 'penjual/product_list.html')

