# Superset configuration (mounted at /app/pythonpath/superset_config.py). Values come from the environment
# set in docker-compose.yml; add any other Superset setting here.
import os

SECRET_KEY = os.environ["SUPERSET_SECRET_KEY"]
SQLALCHEMY_DATABASE_URI = os.environ["SUPERSET_DATABASE_URI"]

# Local development: no Celery/Redis; results and thumbnails are not cached between restarts
FEATURE_FLAGS = {
    "DASHBOARD_RBAC": True,
    "ENABLE_TEMPLATE_PROCESSING": True,
}
SQLLAB_TIMEOUT = 300
WTF_CSRF_ENABLED = True
TALISMAN_ENABLED = False
