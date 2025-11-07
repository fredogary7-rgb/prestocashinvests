from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime

# --- Configuration Flask / DB ---
app = Flask(__name__)
DATABASE_URL = "postgresql+psycopg://presto_admin_user:j7C6is6xvR3EsV4dG6ph4Ju7NWUMurou@dpg-d45j4kf5r7bs73ajiq20-a.oregon-postgres.render.com/presto_admin"
app.config['SQLALCHEMY_DATABASE_URI'] = DATABASE_URL
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

# --- Modèle test ---
class TestUser(db.Model):
    __tablename__ = 'test_users'
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    balance = db.Column(db.Float, default=0.0)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

# --- Test de connexion et création table ---
with app.app_context():
    try:
        db.create_all()  # Crée la table si elle n'existe pas
        # Ajouter un utilisateur test
        user = TestUser(username="Test", email="test@example.com", balance=300.0)
        db.session.add(user)
        db.session.commit()

        # Récupérer et afficher
        saved_user = TestUser.query.first()
        print("✅ Connexion OK ! Utilisateur enregistré :")
        print(f"ID: {saved_user.id}, Nom: {saved_user.username}, Email: {saved_user.email}, Balance: {saved_user.balance}")
    except Exception as e:
        print("❌ Erreur :", e)
