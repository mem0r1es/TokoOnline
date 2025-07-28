from django.core.management.base import BaseCommand
from orders.services import SupabaseOrderService

class Command(BaseCommand):
    help = 'Sync orders dari Supabase ke Django'
    
    def add_arguments(self, parser):
        parser.add_argument(
            '--limit',
            type=int,
            default=100,
            help='Number of orders to sync (default: 100)'
        )
        parser.add_argument(
            '--force',
            action='store_true',
            help='Force sync even if orders exist'
        )
    
    def handle(self, *args, **options):
        service = SupabaseOrderService()
        limit = options['limit']
        
        self.stdout.write(f"Starting sync of {limit} orders from Supabase...")
        
        try:
            synced_count = service.sync_all_orders(limit)
            
            self.stdout.write(
                self.style.SUCCESS(f'Successfully synced {synced_count} orders')
            )
        except Exception as e:
            self.stdout.write(
                self.style.ERROR(f'Error during sync: {e}')
            )