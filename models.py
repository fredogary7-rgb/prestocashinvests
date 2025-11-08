from flask_sqlalchemy import SQLAlchemy
from datetime import datetime, timedelta
db = SQLAlchemy()

class User(db.Model):
    __tablename__ = 'users'
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(100))
    email = db.Column(db.String(120), unique=True, nullable=False)
    phone = db.Column(db.String(20))
    password = db.Column(db.String(200))
    balance = db.Column(db.Float, default=0.0)
    parrain = db.Column(db.String(120), nullable=True)
    withdraw_number = db.Column(db.String(50))
    date_inscription = db.Column(db.String(50))
    has_made_first_deposit = db.Column(db.Boolean, default=False)
    last_bonus_date = db.Column(db.String(50), nullable=True)

    # Relation vers les investissements
    investissements = db.relationship('Investissement', backref='user', lazy=True)

    def to_dict(self):
        return {
            "id": self.id,
            "username": self.username,
            "email": self.email,
            "phone": self.phone,
            "balance": self.balance,
            "parrain": self.parrain,
            "withdraw_number": self.withdraw_number,
            "date_inscription": self.date_inscription,
            "has_made_first_deposit": self.has_made_first_deposit
        }

class Transaction(db.Model):
    __tablename__ = 'transactions'

    id = db.Column(db.String(32), primary_key=True)                         # transaction_id
    user_email = db.Column(db.String(120), db.ForeignKey('users.email'), nullable=False)  # email de l'utilisateur
    type = db.Column(db.String(100), nullable=False)                        # type de transaction, ex: "Dépôt via ..."
    amount = db.Column(db.Float, nullable=False)                             # montant
    status = db.Column(db.String(50), nullable=False, default='pending')    # statut
    reference = db.Column(db.String(100), unique=True, nullable=True)       # référence de transaction
    date = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)  # date/heure
    sender_phone = db.Column(db.String(20), nullable=True)                  # numéro de téléphone envoyé
    description = db.Column(db.String(255), nullable=True)                  # description optionnelle

    def __repr__(self):
        return f"<Transaction {self.id} | {self.user_email} | {self.amount}>"

# Exemple de création d'investissement

class Withdrawal(db.Model):
    __tablename__ = 'withdrawals'
    id = db.Column(db.String(64), primary_key=True)
    user_email = db.Column(db.String(120), db.ForeignKey('users.email'), nullable=False)
    amount = db.Column(db.Float, nullable=False)
    method = db.Column(db.String(50))
    receiver = db.Column(db.String(120))
    status = db.Column(db.String(20), default='En attente')
    timestamp = db.Column(db.DateTime, default=datetime.utcnow)  # <-- ici DateTime

class Historique(db.Model):
    __tablename__ = 'historique'
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'))
    date = db.Column(db.DateTime, default=datetime.utcnow)
    description = db.Column(db.String(255))
    montant = db.Column(db.Float)
    type = db.Column(db.String(50))
    status = db.Column(db.String(50))
    solde_apres = db.Column(db.Float)
    def __repr__(self):
        return f"<Historique id={self.id} user_id={self.user_id} type={self.type} montant={self.montant}>"

    def to_dict(self):
        """Convertit l'entrée historique en dictionnaire pour affichage ou API."""
        return {
            "id": self.id,
            "user_id": self.user_id,
            "date": self.date.strftime("%Y-%m-%d %H:%M:%S"),
            "description": self.description,
            "montant": self.montant,
            "type": self.type,
            "status": self.status,
            "solde_apres": self.solde_apres
        }

class Deposit(db.Model):
    __tablename__ = 'deposits'  # bon nom de table explicite

    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)  # corrigé ici !
    amount = db.Column(db.Float, nullable=False)
    status = db.Column(db.String(50), default='pending')
    date = db.Column(db.DateTime, default=datetime.utcnow)

    # Relation optionnelle pour accéder à l'utilisateur depuis le dépôt
    user = db.relationship('User', backref=db.backref('deposits', lazy=True))

    def __repr__(self):
        return f"<Deposit id={self.id} user_id={self.user_id} amount={self.amount} status={self.status}>"

class Investissement(db.Model):
    __tablename__ = 'investissements'

    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    user_email = db.Column(db.String(120), db.ForeignKey('users.email'), nullable=False)
    nom = db.Column(db.String(100), nullable=False)               # Exemple : "VIP1", "VIP3K"
    montant = db.Column(db.Float, nullable=False)                 # Montant investi
    date_debut = db.Column(db.DateTime, default=datetime.utcnow)  # Date de début
    duree_jours = db.Column(db.Integer, nullable=False)           # Durée du plan
    revenu_quotidien = db.Column(db.Float, nullable=False)        # Gain quotidien
    rendement_total = db.Column(db.Float, nullable=False)         # Gain total prévu
    status = db.Column(db.String(50), default="En cours")         # En cours / Terminé / Annulé
    last_credit = db.Column(db.DateTime, nullable=True)           # Dernière date de crédit

    def __repr__(self):
        return f"<Investissement {self.nom} - {self.montant} XOF>"
