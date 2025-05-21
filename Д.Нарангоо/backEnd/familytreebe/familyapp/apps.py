from django.apps import AppConfig
from neomodel import config

class FamilyAppConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'familyapp'

    def ready(self):
        config.DATABASE_URL = "bolt://neo4j:05070109@localhost:7687"
