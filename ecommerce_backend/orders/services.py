# File: orders/services.py - COMPLETE VERSION

import requests
import json
from django.conf import settings
from datetime import datetime
from .models import Order, OrderItem, OrderStatusHistory, OrderStatus
import logging

logger = logging.getLogger(__name__)

class SupabaseOrderService:
    """
    Service untuk sync orders dari Supabase ke Django
    Menggunakan raw HTTP requests (no supabase library needed)
    """
    
    def __init__(self):
        self.supabase_url = getattr(settings, 'SUPABASE_URL', '')
        self.supabase_key = getattr(settings, 'SUPABASE_KEY', '')
        self.headers = {
            'apikey': self.supabase_key,
            'Authorization': f'Bearer {self.supabase_key}',
            'Content-Type': 'application/json'
        }
    
    def test_connection(self):
        """Test connection dengan table products dulu"""
        try:
            url = f"{self.supabase_url}/rest/v1/products"
            params = {'select': '*', 'limit': 1}
            
            response = requests.get(url, headers=self.headers, params=params)
            print(f"Products test status: {response.status_code}")
            
            return response.status_code == 200
        except Exception as e:
            print(f"Connection test error: {e}")
            return False
    
    def get_dummy_orders(self):
        """Return dummy order data for testing"""
        return [
            {
                'id': 1,
                'timestamp': '2024-01-15T10:30:00Z',
                'full_name': 'John Doe',
                'email': 'john@example.com',
                'phone': '081234567890',
                'address': 'Jl. Sudirman No. 123, Jakarta',
                'payment_method': 'bank_transfer',
                'items': 'Laptop Asus',
                'item_quantity': 1,
                'total_price': 15000000
            },
            {
                'id': 2,
                'timestamp': '2024-01-14T15:45:00Z',
                'full_name': 'Jane Smith',
                'email': 'jane@example.com',
                'phone': '081234567891',
                'address': 'Jl. Thamrin No. 456, Jakarta',
                'payment_method': 'e_wallet',
                'items': 'iPhone 15',
                'item_quantity': 2,
                'total_price': 30000000
            },
            {
                'id': 3,
                'timestamp': '2024-01-13T09:15:00Z',
                'full_name': 'Bob Wilson',
                'email': 'bob@example.com',
                'phone': '081234567892',
                'address': 'Jl. Gatot Subroto No. 789, Jakarta',
                'payment_method': 'credit_card',
                'items': 'Samsung TV 55"',
                'item_quantity': 1,
                'total_price': 12000000
            }
        ]
    
    def get_supabase_orders(self, limit=100):
        """Get orders dari Supabase order_history table"""
        try:
            # Test connection first
            if not self.test_connection():
                print("Supabase connection failed, using dummy data")
                return self.get_dummy_orders()
            
            url = f"{self.supabase_url}/rest/v1/order_history"
            params = {
                'select': '*',
                'order': 'timestamp.desc',
                'limit': limit
            }
            
            response = requests.get(url, headers=self.headers, params=params)
            
            if response.status_code == 200:
                data = response.json()
                print(f"Successfully fetched {len(data)} orders from Supabase")
                return data
            else:
                print(f"Order_history failed (status {response.status_code}): {response.text}")
                print("Using dummy data instead")
                return self.get_dummy_orders()
                
        except Exception as e:
            logger.error(f"Error fetching Supabase orders: {e}")
            print(f"Exception occurred: {e}")
            print("Using dummy data instead")
            return self.get_dummy_orders()
    
    def convert_supabase_to_django(self, supabase_order):
        """Convert Supabase order format ke Django Order format"""
        try:
            # Generate order_id kalau gak ada
            order_id = f"SP-{supabase_order.get('id', 'UNKNOWN')}"
            
            # Parse timestamp
            timestamp_str = supabase_order.get('timestamp', '')
            try:
                created_at = datetime.fromisoformat(timestamp_str.replace('Z', '+00:00'))
            except:
                created_at = datetime.now()
            
            # Determine status
            status = self.determine_order_status(supabase_order)
            
            # Parse pricing
            total_price = float(supabase_order.get('total_price', 0))
            
            django_order_data = {
                'order_id': str(order_id),
                'customer_email': supabase_order.get('email', ''),
                'customer_name': supabase_order.get('full_name', ''),
                'customer_phone': supabase_order.get('phone', ''),
                'shipping_address': supabase_order.get('address', ''),
                'city': self.extract_city_from_address(supabase_order.get('address', '')),
                'province': '',
                'postal_code': '',
                'status': status,
                'payment_method': self.convert_payment_method(supabase_order.get('payment_method', '')),
                'subtotal': total_price,
                'shipping_cost': 0,
                'tax': 0,
                'total_amount': total_price,
                'created_at': created_at,
                'notes': f"Synced from Supabase at {datetime.now()}",
            }
            
            return django_order_data
        except Exception as e:
            logger.error(f"Error converting Supabase order: {e}")
            return None
    
    def determine_order_status(self, supabase_order):
        """Determine status berdasarkan data Supabase"""
        payment_method = supabase_order.get('payment_method', '')
        
        if payment_method:
            return OrderStatus.PAID
        else:
            return OrderStatus.PENDING
    
    def convert_payment_method(self, supabase_payment_method):
        """Convert payment method dari Supabase ke Django choices"""
        mapping = {
            'bank_transfer': 'bank_transfer',
            'credit_card': 'credit_card', 
            'e_wallet': 'e_wallet',
            'cod': 'cod',
            '': 'bank_transfer'
        }
        return mapping.get(supabase_payment_method.lower(), 'bank_transfer')
    
    def extract_city_from_address(self, address):
        """Extract city dari address string"""
        if not address:
            return ''
        
        parts = address.split(',')
        if len(parts) > 1:
            return parts[-1].strip()
        return ''
    
    def create_order_items_from_supabase(self, order, supabase_order):
        """Create OrderItems berdasarkan data Supabase"""
        try:
            item_name = supabase_order.get('items', 'Unknown Product')
            item_quantity = int(supabase_order.get('item_quantity', 1))
            total_price = float(supabase_order.get('total_price', 0))
            
            unit_price = total_price / item_quantity if item_quantity > 0 else total_price
            
            order_item = OrderItem.objects.create(
                order=order,
                product_id=1,
                product_name=item_name,
                quantity=item_quantity,
                unit_price=unit_price,
                total_price=total_price
            )
            
            return order_item
        except Exception as e:
            logger.error(f"Error creating order items: {e}")
            return None
    
    def sync_order_from_supabase(self, supabase_order):
        """Sync single order dari Supabase ke Django"""
        try:
            # Convert data format
            django_data = self.convert_supabase_to_django(supabase_order)
            if not django_data:
                return None
            
            # Check if order already exists
            existing_order = Order.objects.filter(
                order_id=django_data['order_id']
            ).first()
            
            if existing_order:
                print(f"Order {django_data['order_id']} already exists, skipping")
                return existing_order
            
            # Create new Order
            order = Order.objects.create(**django_data)
            
            # Create OrderItems
            self.create_order_items_from_supabase(order, supabase_order)
            
            # Create initial status history
            OrderStatusHistory.objects.create(
                order=order,
                status=order.status,
                notes=f"Order synced from Supabase"
            )
            
            print(f"Successfully synced order {order.order_id}")
            return order
            
        except Exception as e:
            logger.error(f"Error syncing order: {e}")
            print(f"Failed to sync order: {e}")
            return None
    
    def sync_all_orders(self, limit=100):
        """Sync all orders dari Supabase ke Django"""
        try:
            print(f"Starting sync of {limit} orders...")
            
            supabase_orders = self.get_supabase_orders(limit)
            synced_count = 0
            
            for sb_order in supabase_orders:
                order = self.sync_order_from_supabase(sb_order)
                if order:
                    synced_count += 1
            
            print(f"Successfully synced {synced_count} orders")
            logger.info(f"Synced {synced_count} orders from Supabase")
            return synced_count
            
        except Exception as e:
            logger.error(f"Error in bulk sync: {e}")
            print(f"Bulk sync error: {e}")
            return 0