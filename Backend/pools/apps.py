from django.apps import AppConfig
#from .http_scheduler import start_http_scheduler
from .listener import start_event_listener
#from asgiref.sync import async_to_sync


class PoolsConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'pools'

    def ready(self):
        start_event_listener()