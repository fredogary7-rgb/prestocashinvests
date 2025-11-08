from app import app
from models import db

def init_db():
    """Créer les tables PostgreSQL"""
    with app.app_context():
        db.create_all()
        print("✅ Base PostgreSQL initialisée avec succès.")

if __name__ == "__main__":
    init_db()
