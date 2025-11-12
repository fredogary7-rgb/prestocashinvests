from flask import Flask, render_template, request, redirect, url_for, flash, session, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from datetime import datetime, timedelta
import uuid
import threading
from flask import Flask
from models import db, User, Deposit, Transaction, Withdrawal, Historique, Investissement  # adapte selon ton fichier# <- tu importes tout
import os

app = Flask(__name__)
app.secret_key = "ma_cle_ultra_secrete_2024_preto_cash"

DATABASE_URL = "postgresql+psycopg://neondb_owner:npg_P0EKkxdQ8Nit@..."
app.config['SQLALCHEMY_DATABASE_URI'] = "postgresql+psycopg://neondb_owner:npg_P0EKkxdQ8Nit@ep-solitary-tooth-abfeect2-pooler.eu-west-2.aws.neon.tech/neondb?sslmode=require&channel_binding=require"
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
# ----------------------------
# Configuration Kkiapay
# ----------------------------

migrate = Migrate(app, db)
DATA_DIR = "data"
UPLOAD_FOLDER = os.path.join(DATA_DIR, "uploads")
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

os.makedirs(DATA_DIR, exist_ok=True)
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

db.init_app(app)

BONUS_PARRAINAGE = 50.0
INITIAL_BALANCE = 0.0
VIP_DURATION_DAYS = 60

def load_json(path):
    if not os.path.exists(path):
        return {}
    try:
        with open(path, 'r', encoding='utf-8') as f:
            return json.load(f)
    except (json.JSONDecodeError, FileNotFoundError):
        return {}

file_lock = threading.Lock()
def save_json(path, data):
    with file_lock:
        with open(path, 'w', encoding='utf-8') as f:
            json.dump(data, f, indent=4, ensure_ascii=False)


def load_users_data():
    """Charge les utilisateurs depuis PostgreSQL (compatibilité avec le code existant)."""
    users_dict = {}
    all_users = User.query.all()
    for u in all_users:
        users_dict[u.email] = u.to_dict()
    return users_dict

def save_users_data(data):
    """Sauvegarde les données utilisateurs dans PostgreSQL."""
    from app import db, app
    from models import User

    with app.app_context():
        for email, user_data in data.items():
            # Vérifie si l'utilisateur existe déjà
            user = User.query.filter_by(email=email).first()
            if user:
                # Mise à jour des champs existants
                user.username = user_data.get("username", user.username)
                user.phone = user_data.get("phone", user.phone)
                user.password = user_data.get("password", user.password)  # Assurez-vous que le mot de passe est hashé
                user.balance = user_data.get("balance", user.balance)
                user.parrain = user_data.get("parrain", user.parrain)
                user.withdraw_number = user_data.get("withdraw_number", user.withdraw_number)
                user.date_inscription = user_data.get("date_inscription", user.date_inscription)
                user.has_made_first_deposit = user_data.get(
                    "has_made_first_deposit", getattr(user, "has_made_first_deposit", False)
                )
                user.last_bonus_date = user_data.get(
                    "last_bonus_date", getattr(user, "last_bonus_date", None)
                )
            else:
                # Création d'un nouvel utilisateur
                user = User(
                    username=user_data.get("username"),
                    email=email,
                    phone=user_data.get("phone"),
                    password=user_data.get("password"),  # Assurez-vous que le mot de passe est hashé
                    balance=user_data.get("balance", 0.0),
                    parrain=user_data.get("parrain"),
                    withdraw_number=user_data.get("withdraw_number"),
                    date_inscription=user_data.get("date_inscription"),
                    has_made_first_deposit=user_data.get("has_made_first_deposit", False),
                    last_bonus_date=user_data.get("last_bonus_date")
                )
                db.session.add(user)

        # Commit après avoir traité tous les utilisateurs
        db.session.commit()

from app import db, User, Transaction

def ensure_user_exists(email):
    """Créer un utilisateur dans PostgreSQL si inexistant."""
    email = email.strip().lower()
    user = User.query.filter_by(email=email).first()
    if not user:
        user = User(
            username="",
            email=email,
            balance=0.0,  # ou INITIAL_BALANCE si défini
            date_inscription=datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            has_made_first_deposit=False
        )
        db.session.add(user)
        db.session.commit()
    return user


def add_history_entry(user_email, description, montant, status):
    """Ajoute une transaction PostgreSQL pour un utilisateur."""
    user = User.query.filter_by(email=user_email).first()
    if not user:
        return

    txn = Transaction(
        id=uuid.uuid4().hex,  # ✅ génère un ID unique pour éviter le NULL
        user_email=user_email,
        type=description,
        amount=montant,
        status=status,
        date=datetime.now()
    )
    db.session.add(txn)
    db.session.commit()

def get_logged_in_user_email():
    """Récupère l'email de l'utilisateur connecté depuis la session."""
    return session.get('email')
def init_db():
    """Créer les tables PostgreSQL"""
    with app.app_context():
        db.create_all()
        print("✅ Base PostgreSQL initialisée avec succès.")

def migrate_users_from_json():
    """Importer les anciens utilisateurs depuis users.json vers PostgreSQL"""
    from sqlalchemy.exc import IntegrityError

    with app.app_context():
        users_data = load_users_data()
        for email, u in users_data.items():
            if not User.query.filter_by(email=email).first():
                user = User(
                    username=u.get("username", ""),
                    email=email,
                    phone=u.get("phone", ""),
                    password=u.get("password", ""),
                    balance=u.get("balance", 0.0),
                    parrain=u.get("parrain"),
                    withdraw_number=u.get("withdraw_number", ""),
                    date_inscription=u.get("date_inscription"),
                    has_made_first_deposit=u.get("has_made_first_deposit", False)
                )
                db.session.add(user)
                try:
                    db.session.commit()
                    print(f"✅ Importé : {email}")
                except IntegrityError:
                    db.session.rollback()
                    print(f"⚠️  Doublon ignoré : {email}")
        print("🎉 Migration terminée.")

class Referral(db.Model):
    __tablename__ = 'referrals'

    id = db.Column(db.Integer, primary_key=True)
    parrain_email = db.Column(db.String(120), db.ForeignKey('users.email'))
    filleul_email = db.Column(db.String(120), db.ForeignKey('users.email'))
    date = db.Column(db.String(30))  # tu peux aussi mettre DateTime si tu veux
# Connexion MongoDB
# ----------------------------
# Routes d'inscription / connexion
# ----------------------------
@app.route('/inscription', methods=['GET', 'POST'])
def inscription_page():
    referral_code = request.args.get('ref')
    message = None

    if request.method == 'POST':
        username = request.form.get('username', '').strip()
        email = request.form.get('email', '').strip().lower()
        password = request.form.get('password')
        phone = request.form.get('phone', '').strip()
        parrainage_code = request.form.get('referral_code', referral_code)

        if not email or not password:
            message = {"type": "error", "text": "Email et mot de passe requis."}
            return render_template('inscription.html', message=message, referral_code=referral_code)

        # Vérifie si l'utilisateur existe déjà
        existing_user = User.query.filter_by(email=email).first()
        if existing_user:
            message = {"type": "error", "text": "Cet email est déjà enregistré."}
            return render_template('inscription.html', message=message, referral_code=referral_code)

        # Création d'un nouvel utilisateur
        initial_balance = INITIAL_BALANCE + 300  # Bonus inscription

        new_user = User(
            username=username or email.split('@')[0],
            email=email,
            phone=phone,
            password=password,  # ⚠️ penser à hasher pour la prod
            balance=initial_balance,
            parrain=parrainage_code if parrainage_code else None,
            has_made_first_deposit=False,
            date_inscription=datetime.utcnow()
        )
        db.session.add(new_user)
        db.session.commit()  # Commit pour récupérer l'ID utilisateur

        # Ajouter l'historique du bonus inscription
        hist_entry = Historique(
            user_id=new_user.id,
            date=datetime.utcnow(),
            description="Bonus inscription",
            montant=300,
            type="Crédit",
            status="Credité",
            solde_apres=initial_balance
        )
        db.session.add(hist_entry)
        db.session.commit()

        # Gestion du parrainage
        if parrainage_code:
            parrain = User.query.filter_by(username=parrainage_code).first()
            if parrain:
                parrain.filleuls = parrain.filleuls or []
                parrain.filleuls.append(new_user.email)
                db.session.commit()

        # Connexion automatique après inscription
        session['email'] = new_user.email
        flash("Inscription réussie ! Vous avez reçu 300 XOF de bonus.", "success")
        return redirect(url_for('dashboard_page'))

    return render_template('inscription.html', message=message, referral_code=referral_code)

@app.route('/connexion', methods=['GET', 'POST'])
def connexion():
    message = None

    if request.method == 'POST':
        email = request.form.get('email', '').strip().lower()
        password = request.form.get('password')

        # Recherche l'utilisateur dans PostgreSQL
        user = User.query.filter_by(email=email).first()

        if user:
            if user.password == password:  # <-- ici tu compares directement
                session['email'] = user.email  # clé cohérente
                flash("Connexion réussie !", "success")
                return redirect(url_for('dashboard_page'))
            else:
                message = {"type": "error", "text": "Mot de passe incorrect."}
        else:
            message = {"type": "error", "text": "Aucun compte trouvé avec cet email."}

    return render_template('connexion.html', message=message)

@app.route('/logout')
def logout():
    session.pop('email', None)
    flash("Déconnecté.", "info")
    return redirect(url_for('connexion'))


# ----------------------------
# Dashboard / Profile
# ----------------------------
@app.route('/dashboard')
def dashboard_page():
    user_email = get_logged_in_user_email()
    if not user_email:
        flash("Veuillez vous connecter.", "warning")
        return redirect(url_for('connexion'))

    # Récupération de l'utilisateur depuis PostgreSQL
    user = User.query.filter_by(email=user_email).first()
    if not user:
        flash("Utilisateur introuvable.", "error")
        return redirect(url_for('connexion'))

    # Historique et transactions
    historique = Transaction.query.filter_by(user_email=user_email).order_by(Transaction.date.desc()).all()
    historique_list = [{
        "date": t.date.strftime("%d-%m-%Y %H:%M:%S"),
        "description": t.description or t.type,
        "montant": t.amount,
        "status": t.status
    } for t in historique]

    # Préparation des données pour le template
    user_display = {
        'username': user.username or user_email.split('@')[0],
        'email': user.email,
        'phone': user.phone or '',
        'balance': round(user.balance or 0.0, 2),
        'historique': historique_list,
        'transactions': historique_list,
        'parrain': user.parrain,
        'investments': [i.to_dict() for i in user.investments] if hasattr(user, 'investments') else [],
        'filleuls': [f.to_dict() for f in user.filleuls] if hasattr(user, 'filleuls') else []
    }

    message = None
    if request.args.get('message_text'):
        message = {
            'type': request.args.get('message_type', 'info'),
            'text': request.args.get('message_text')
        }

    return render_template('dashboard.html', user=user_display, message=message)


@app.route('/profile')
def profile_page():
    user_email = get_logged_in_user_email()
    user = User.query.filter_by(email=user_email).first() if user_email else None

    if not user:
        # invité
        guest = {
            'username': 'Invité',
            'email': 'N/A',
            'phone': 'N/A',
            'balance': 0.0,
            'date_inscription': None,
            'historique': [],
            'transactions': []
        }
        return render_template('profile.html',
                               user_name=guest['username'],
                               user_email=guest['email'],
                               user_phone=guest['phone'],
                               user_solde=guest['balance'],
                               date_joined=guest['date_inscription'],
                               parrain='Aucun',
                               historique=guest['historique'],
                               transactions=guest['transactions'])

    # Historique depuis PostgreSQL
    historique = Transaction.query.filter_by(user_email=user_email).order_by(Transaction.date.desc()).all()
    historique_list = [{
        "date": t.date.strftime("%d-%m-%Y %H:%M:%S"),
        "description": t.description or t.type,
        "montant": t.amount,
        "status": t.status
    } for t in historique]

    return render_template(
        'profile.html',
        user_name=user.username,
        user_email=user.email,
        user_phone=user.phone,
        user_solde=round(user.balance, 2),
        date_joined=user.date_inscription,
        parrain=user.parrain or 'Aucun',
        historique=historique_list,
        transactions=historique_list
    )


# ----------------------------
# Configuration Kkiapay
# ----------------------------

PAYMENT_ACCOUNTS = {
    "euro": {
        "name": "Tous les pays",
        "link": "https://www.pay.moneyfusion.net/presto-cash-_1762687066538/",
        "currency": "26 Pays"
    },
    "crypto": {
        "name": "Adresse Crypto BEP20",
        "address": "0x321FE3416D4612D8223b6fC58095f2ED511F8749",
        "currency": "USDT"
    }
}
# ----------------------------
# Dépôt : sélection / soumission / preuve
# ----------------------------

@app.route('/deposit')
def deposit_selection_page():
    return render_template('deposit.html', payment_methods=PAYMENT_ACCOUNTS)

@app.route('/deposit/<method>')
def deposit_page(method):
    if method not in PAYMENT_ACCOUNTS:
        return "Méthode de dépôt non supportée.", 404
    return render_template('deposit_form.html', payment_method=method)

@app.route('/process_deposit', methods=['POST'])
def process_deposit():
    amount = request.form.get('amount')
    method = request.form.get('method')
    sender_phone = request.form.get('sender_phone')

    try:
        amount = float(amount)
        if amount < 3000 and method != 'crypto':
            return "Le montant minimum de dépôt est de 3000 XOF.", 400
        if method == 'crypto' and amount < 5:
            return "Le montant minimum en crypto est de 5 USD.", 400
    except (ValueError, TypeError):
        return "Montant invalide.", 400

    payment_info = PAYMENT_ACCOUNTS.get(method)
    return redirect(url_for(
        'deposit_instructions',
        amount=amount,
        method=method,
        sender_phone=sender_phone,
        payment_info_name=payment_info.get('name', 'N/A'),
        payment_info_link=payment_info.get('link', ''),
        payment_info_address=payment_info.get('address', ''),
        currency=payment_info['currency']
    ))

@app.route('/deposit_instructions')
def deposit_instructions():
    context = request.args
    return render_template('deposit_instructions.html', **context)


@app.route('/api/submit_proof', methods=['POST'])
def submit_proof():
    transaction_id = uuid.uuid4().hex
    amount = request.form.get('amount')
    method = request.form.get('method')
    sender_phone = request.form.get('sender_phone')
    reference_text = request.form.get('reference_text')

    if not amount or not method:
        return "Erreur: Données de transaction incomplètes.", 400

    user_email = get_logged_in_user_email()
    if not user_email:
        return "Erreur : Utilisateur non connecté.", 401

    # --- Récupérer l'utilisateur depuis PostgreSQL ---
    user = User.query.filter_by(email=user_email).first()
    if not user:
        return "Utilisateur introuvable.", 404

    # --- Générer une référence unique si non fournie ou déjà existante ---
    from sqlalchemy.exc import IntegrityError
    if not reference_text:
        reference_text = str(uuid.uuid4().int)[:12]

    attempt = 0
    while True:
        if attempt > 5:
            return "Impossible de générer une référence unique. Réessayez plus tard.", 500
        if Transaction.query.filter_by(reference=reference_text).first():
            reference_text = str(uuid.uuid4().int)[:12]  # nouvelle référence
            attempt += 1
        else:
            break

    # --- Créer l'objet transaction ---
    txn = Transaction(
        id=transaction_id,
        user_email=user_email,
        type=f"Dépôt via {method}",
        amount=float(amount),
        status='pending',
        reference=reference_text,
        date=datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        sender_phone=sender_phone
    )

    db.session.add(txn)

    # --- Mettre à jour le numéro de téléphone si vide ---
    if not user.phone and sender_phone:
        user.phone = sender_phone

    try:
        db.session.commit()
    except IntegrityError:
        db.session.rollback()
        return "Erreur: Impossible d'enregistrer la transaction (référence dupliquée).", 500

    return redirect(url_for('deposit_success', transaction_id=transaction_id))

@app.route('/deposit_success')
def deposit_success():
    transaction_id = request.args.get('transaction_id')
    return render_template('deposit_success.html', transaction_id=transaction_id)

@app.route('/reglement')
def reglement_page():
    return render_template('reglement.html')


    # Chargement des produits VIP
PRODUITS_VIP = {
    'VIP10K': {
        'id': 'VIP10K',
        'nom': 'VIP Découverte',
        'montant_min': 10000,
        'duree_jours': 21,
        'revenu_quotidien': 1600,
        'rendement_total': 33600,
        'description': "Le meilleur point de départ pour l'investissement rapide.",
        'image_url': 'decouverte.png',
    },
    'VIP25K': {
        'id': 'VIP25K',
        'nom': 'VIP Pro',
        'montant_min': 25000,                                                                                                             'duree_jours': 21,
        'revenu_quotidien': 2600,
        'rendement_total': 54600,
        'description': "Augmentez votre potentiel avec un investissement intermédiaire.",
        'image_url': 'pro.png',
    },
    'VIP50K': {
        'id': 'VIP50K',
        'nom': 'VIP Expert',
        'montant_min': 50000,
        'duree_jours': 21,
        'revenu_quotidien': 5000,
        'rendement_total': 105000,
        'description': "La voie rapide vers des gains significatifs.",
        'image_url': 'expert.png',
    },
    'VIP100K': {
        'id': 'VIP100K',
        'nom': 'VIP Premium',
        'montant_min': 100000,
        'duree_jours': 21,
        'revenu_quotidien': 16000,
        'rendement_total': 336000,
        'description': "Optimisez vos revenus avec cette offre de pointe.",
        'image_url': 'premium.png',
    },
    'VIP250K': {
        'id': 'VIP250K',
        'nom': 'VIP Ultime',
        'montant_min': 250000,
        'duree_jours': 21,
        'revenu_quotidien': 26000,
        'rendement_total': 546000,
        'description': "Maximisez votre portefeuille avec un investissement majeur.",
        'image_url': 'ultime.png',
    },
    'VIP500K': {
        'id': 'VIP500K',
        'nom': 'VIP Prestige',
        'montant_min': 500000,
        'duree_jours': 21,
        'revenu_quotidien': 50000,
        'rendement_total': 1050000,
        'description': "Le summum des opportunités d'investissement rapide.",
        'image_url': 'prestige.png',
    }
}

@app.route('/decouvrir')
def decouvrir_page():
    """
    Page Découvrir - accessible uniquement si l'utilisateur a investi >= 3000 dans un produit de 60 jours.
    Utilise le modèle Investissement pour vérifier l'éligibilité.
    """
    user_email = get_logged_in_user_email()
    if not user_email:
        return render_template('decouvrir_bloque.html', user_info={'username': 'Invité', 'balance': 0.0, 'historique': []})

    user = User.query.filter_by(email=user_email).first()
    if not user:
        return render_template('decouvrir_bloque.html', user_info={'username': 'Invité', 'balance': 0.0, 'historique': []})

    # Récupère tous les investissements de cet utilisateur
    investissements = Investissement.query.filter_by(user_email=user.email).all()
    
    # Transforme les investissements en dictionnaire pour l'affichage et l'analyse
    historique = [h.to_dict() for h in Historique.query.filter_by(user_id=user.id).all()]
    investissements_dict = []
    eligible_vip = False

    now = datetime.now()
    for inv in investissements:
        # Mettre à jour le statut si terminé
        date_fin = inv.date_debut + timedelta(days=inv.duree_jours)
        if now >= date_fin and inv.status != 'Terminé':
            inv.status = 'Terminé'
            db.session.commit()

        # Vérifie l'éligibilité pour le produit Découvrir
        if inv.montant >= 3000 and inv.duree_jours == 60:
            eligible_vip = True

        investissements_dict.append({
            'nom': inv.nom,
            'montant': inv.montant,
            'date_debut': inv.date_debut.strftime("%Y-%m-%d"),
            'duree_jours': inv.duree_jours,
            'revenu_quotidien': inv.revenu_quotidien,
            'rendement_total': inv.rendement_total,
            'status': inv.status
        })

    user_info = {
        'username': user.username,
        'email': user.email,
        'balance': user.balance,
        'historique': historique,
        'investissements': investissements_dict
    }

    if not eligible_vip:
        # Bloque l'accès si l'utilisateur n'a pas investi un plan de 60 jours >= 3000
        return render_template('decouvrir_bloque.html', user_info=user_info)

    # Produits VIP disponibles
    produits_vip = list(PRODUITS_VIP.values()) if isinstance(PRODUITS_VIP, dict) else []

    return render_template(
        'decouvrir.html',
        products=produits_vip,
        user_info=user_info
    )

@app.route('/investir/<product_id>', methods=['GET', 'POST'])
def investir(product_id):
    """Permet à un utilisateur d'investir dans un produit Découvrir (VIP) avec historique persistant."""
    user_email = get_logged_in_user_email()
    if not user_email:
        return redirect(url_for('connexion'))

    user = User.query.filter_by(email=user_email).first()
    product = PRODUITS_VIP.get(product_id)

    if not product or not user:
        flash("Produit ou utilisateur introuvable.", "danger")
        return redirect(url_for('decouvrir_page'))

    if request.method == 'POST':
        try:
            investment_amount = float(product['montant_min'])
        except (TypeError, ValueError):
            flash("Montant du produit invalide.", "danger")
            return redirect(url_for('decouvrir_page'))

        current_balance = user.balance or 0.0
        if current_balance < investment_amount:
            return render_template(
                'investir.html',
                product=product,
                message="⚠️ Solde insuffisant pour cet investissement.",
                user_info=user
            )

        # --- Débiter le solde utilisateur ---
        user.balance = round(current_balance - investment_amount, 2)

        # --- Crée un investissement VIP dans la table Investissement ---
        new_invest = Investissement(
            user_email=user.email,
            nom=product['nom'],
            montant=investment_amount,
            date_debut=datetime.utcnow(),
            duree_jours=product.get('duree_jours', 21),
            revenu_quotidien=product.get('gain_quotidien', 0),
            rendement_total=product.get('rendement_total', investment_amount),
            status="En cours"
        )
        db.session.add(new_invest)

        # --- Historique de l’investissement ---
        hist_entry = Historique(
            user_id=user.id,
            date=datetime.utcnow(),
            description=f"Investissement VIP: {product['nom']}",
            montant=-investment_amount,
            type='debit',
            status='En cours',
            solde_apres=user.balance
        )
        db.session.add(hist_entry)

        # --- Commission du parrain ---
        if user.parrain:
            parrain = User.query.filter_by(email=user.parrain).first()
            if parrain:
                commission = round(investment_amount * 0.30, 2)
                parrain.balance = (parrain.balance or 0.0) + commission

                # Historique commission parrain
                hist_parrain = Historique(
                    user_id=parrain.id,
                    date=datetime.utcnow(),
                    description=f"Commission de parrainage (30%) sur investissement de {user.username}",
                    montant=commission,
                    type='credit',
                    status='Validé',
                    solde_apres=parrain.balance
                )
                db.session.add(hist_parrain)

        db.session.commit()

        message = f"✅ Félicitations ! Vous avez investi {investment_amount:,.0f} XOF dans {product['nom']}."
        return render_template('investir.html', product=product, message=message, user_info=user)

    return render_template('investir.html', product=product, message=None, user_info=user)

# --- Produits rapides ---
# ----------------------------
# Produits d’investissement rapide
# ----------------------------
# ----------------------------
# PRODUITS RAPIDES
# ----------------------------
VIP_PRODUITS = {
    'VIP3K': {
        'id': 'VIP3K',
        'nom': 'VIP Mini',
        'montant_min': 3000,
        'duree_jours': 5,
        'revenu_quotidien': 1080,
        'rendement_total': 5400,
        'description': "Le meilleur point de départ pour investir.",
        'image_url': 'prestige.png',
    },
    'VIP9K': {
        'id': 'VIP9K',
        'nom': 'VIP Découverte',
        'montant_min': 9000,
        'duree_jours': 5,
        'revenu_quotidien': 3240,
        'rendement_total': 16200,
        'description': "Augmentez votre potentiel avec un investissement intermédiaire.",
        'image_url': 'decouverte.png',
    },
    'VIP15K': {
        'id': 'VIP15K',
        'nom': 'VIP Pro',
        'montant_min': 15000,
        'duree_jours': 5,
        'revenu_quotidien': 5400,
        'rendement_total': 27000,
        'description': "La voie rapide vers des gains significatifs.",
        'image_url': 'pro.png',
    }
}

# ----------------------------
# PAGE DES PRODUITS RAPIDES
# ----------------------------
@app.route('/produits_rapide')
def produits_rapide_page():
    """
    Page Produits Rapides - accessible uniquement si l'utilisateur a fait un dépôt >= 9000.
    """
    user_email = get_logged_in_user_email()
    if not user_email:
        return redirect(url_for('connexion'))

    user = User.query.filter_by(email=user_email).first()
    if not user:
        return redirect(url_for('connexion'))

    # ✅ Vérifie le total des dépôts dans la table Transaction
    total_depots = db.session.query(
        db.func.sum(Transaction.amount)
    ).filter(
        Transaction.user_email == user.email,
        Transaction.type.like('Dépôt%'),
        Transaction.status == 'accepted'
    ).scalar() or 0

    eligible_rapide = total_depots >= 9000

    # ✅ Si pas encore éligible
    if not eligible_rapide:
        flash("Vous devez d'abord effectuer un dépôt d'au moins 9000 XOF pour accéder à ces produits.", "warning")
        return render_template('produits_bloque.html', user_info=user)

    # ✅ Sinon affiche les produits rapides
    produits_rapide = list(VIP_PRODUITS.values())
    return render_template('produits_rapide.html', produits=produits_rapide, user_info=user)


# ----------------------------
# INVESTIR DANS UN PRODUIT RAPIDE
# ----------------------------
@app.route('/investir_rapide/<product_id>', methods=['GET', 'POST'])
def investir_rapide(product_id):
    """Permet à un utilisateur d'investir dans un produit rapide (revenus à la fin de 5 jours)."""
    user_email = get_logged_in_user_email()
    if not user_email:
        return redirect(url_for('connexion'))

    user = User.query.filter_by(email=user_email).first()
    product = VIP_PRODUITS.get(product_id)

    if not product or not user:
        flash("Produit ou utilisateur introuvable.", "danger")
        return redirect(url_for('produits_rapide_page'))

    montant = float(product['montant_min'])
    duree_jours = product['duree_jours']
    revenu_total = product['revenu_quotidien'] * duree_jours

    # Vérifie si le solde est suffisant
    if request.method == 'POST':
        if user.balance < montant:
            flash("⚠️ Solde insuffisant pour investir dans ce produit.", "danger")
            return render_template('investir.html', product=product, user_info=user)

        # ✅ Débit du solde utilisateur
        user.balance -= montant

        # ✅ Création d’un investissement rapide (revenu à la fin)
        new_invest = Investissement(
            user_email=user.email,
            nom=product['nom'],
            montant=montant,
            date_debut=datetime.utcnow(),
            duree_jours=duree_jours,
            revenu_quotidien=product['revenu_quotidien'],
            rendement_total=revenu_total,
            status="En cours"
        )
        db.session.add(new_invest)

        # ✅ Ajout dans l’historique
        hist_entry = Historique(
            user_id=user.id,
            date=datetime.utcnow(),
            description=f"Investissement Rapide - {product['nom']} (5 jours)",
            montant=-montant,
            type='Débit',
            status='En cours',
            solde_apres=user.balance
        )
        db.session.add(hist_entry)
        db.session.commit()

        flash(f"✅ Investissement de {montant:,.0f} XOF effectué dans {product['nom']} ! Revenus à la fin de 5 jours.", "success")
        return render_template('investir.html', product=product, user_info=user)

    return render_template('investir.html', product=product, user_info=user)

# ----------------------------
@app.route('/mes_commandes')
def mes_commandes_page():
    user_email = get_logged_in_user_email()
    if not user_email:
        flash("Veuillez vous connecter.", "error")
        return redirect(url_for('connexion'))

    user = User.query.filter_by(email=user_email).first()
    if not user:
        flash("Utilisateur introuvable.", "error")
        return redirect(url_for('connexion'))

    commandes = Investissement.query.filter_by(user_email=user.email).all()

    return render_template('mes_commandes.html', user=user, commandes=commandes)

@app.route('/retrait', methods=['GET', 'POST'])
def retrait_selection():
    email = get_logged_in_user_email()
    if not email:
        return redirect(url_for('connexion'))

    user = User.query.filter_by(email=email).first()
    if not user:
        return redirect(url_for('connexion'))

    # --- Récupère toutes les transactions de l'utilisateur ---
    transactions = Transaction.query.filter_by(user_email=email).all()

    # --- Total des dépôts (non retirables) ---
    total_deposits = sum(
        t.amount for t in transactions
        if str(t.status).lower() in ['accepté', 'accepted', 'validé']
        and 'dépôt' in str(t.type).lower()
    )

    # --- Total des revenus, bonus et commissions (retirables) ---
    total_revenus = sum(
        t.amount for t in transactions
        if str(t.status).lower() in ['accepté', 'validé', 'terminé']
        and any(x in str(t.type).lower() for x in ['revenu', 'commission', 'bonus'])
    )

    # --- Solde total utilisateur ---
    total_balance = float(getattr(user, 'balance', 0.0))

    # --- Calcul du solde retirable ---
    # On autorise le retrait de tout sauf les dépôts
    withdrawable_balance = max(total_balance - total_deposits, 0.0)

    # --- Si le total des revenus dépasse le calcul, on l’ajuste ---
    if total_revenus > withdrawable_balance:
        withdrawable_balance = total_revenus

    # --- Méthodes de retrait disponibles ---
    methods = [
        "Moov Money", "MTN", "Mix by YAS", "Orange Money",
        "Airtel", "Vodacom", "Crypto BEP20"
    ]

    if request.method == 'POST':
        try:
            amount = float(request.form.get('amount', 0))
            method = request.form.get('method')

            if amount < 1500:
                flash("Le montant minimum de retrait est de 1500 XOF.", "warning")
                return redirect(url_for('retrait_selection'))

            if amount > withdrawable_balance:
                flash("⚠️ Solde disponible pour retrait insuffisant.", "danger")
                return redirect(url_for('retrait_selection'))

            # --- Calcul frais 10% ---
            frais = round(amount * 0.10, 2)
            net_amount = round(amount - frais, 2)

            # --- Déduction du solde utilisateur ---
            user.balance = round(user.balance - amount, 2)

            # --- Enregistrement dans l'historique ---
            hist_entry = Historique(
                user_id=user.id,
                date=datetime.utcnow(),
                description=f"Retrait via {method}",
                montant=-net_amount,
                type='Débit',
                status='En cours',
                solde_apres=user.balance
            )
            db.session.add(hist_entry)

            # --- Enregistrement dans la table des retraits ---
            withdrawal_entry = Withdrawal(
                id=str(uuid.uuid4()),
                user_email=user.email,
                amount=amount,
                method=method,
                receiver=getattr(user, 'phone', ''),
                status='En attente',
                timestamp=datetime.utcnow()
            )
            db.session.add(withdrawal_entry)
            db.session.commit()

            return render_template(
                'confirmer_retrait.html',
                amount=amount,
                frais=frais,
                net_amount=net_amount,
                method=method,
                address_or_number=getattr(user, 'phone', '')
            )

        except (ValueError, TypeError):
            flash("Montant invalide.", "danger")
            return redirect(url_for('retrait_selection'))

    return render_template(
        'retrait.html',
        user=user,
        methods=methods,
        withdrawable_balance=withdrawable_balance
    )

@app.route('/confirmer_retrait', methods=['POST'])
def confirmer_retrait():
    user_email = get_logged_in_user_email()
    if not user_email:
        return redirect(url_for('connexion'))

    user = User.query.filter_by(email=user_email).first()
    if not user:
        return redirect(url_for('connexion'))

    try:
        # --- Récupération des données du formulaire ---
        amount = float(request.form.get('amount', 0))
        method = request.form.get('method')
        address_or_number = request.form.get('address_or_number')

        if amount < 1500:
            flash("Le montant minimum de retrait est de 1500 XOF.", "warning")
            return redirect(url_for('retrait_selection'))

        # --- Calcul frais 10% ---
        frais = round(amount * 0.10, 2)
        net_amount = round(amount - frais, 2)

        if net_amount > user.balance:
            flash("Solde insuffisant.", "danger")
            return redirect(url_for('retrait_selection'))

        # --- Débit du solde utilisateur ---
        user.balance = round(user.balance - net_amount, 2)

        # --- Créer l'entrée Withdrawal pour admin ---
        withdrawal_entry = Withdrawal(
            id=str(uuid.uuid4()),
            user_email=user.email,
            amount=amount,
            method=method,
            receiver=address_or_number,
            status='En attente',
            timestamp=datetime.utcnow()
        )
        db.session.add(withdrawal_entry)

        # --- Historique utilisateur ---
        hist_entry = Historique(
            user_id=user.id,
            date=datetime.utcnow(),
            description=f"Retrait via {method}",
            montant=-net_amount,
            type='debit',
            status='En attente',
            solde_apres=user.balance
        )
        db.session.add(hist_entry)

        db.session.commit()

        # Redirection vers la page de succès
        return redirect(url_for(
            'retrait_success',
            transaction_id=withdrawal_entry.id,
            amount=amount,
            method=method,
            address_or_number=address_or_number
        ))

    except Exception as e:
        db.session.rollback()
        flash(f"Erreur lors du retrait : {str(e)}", "danger")
        return redirect(url_for('retrait_selection'))


@app.route('/retrait_success')
def retrait_success():
    transaction_id = request.args.get('transaction_id')
    method = request.args.get('method')
    address_or_number = request.args.get('address_or_number')

    try:
        amount = float(request.args.get('amount', 0))
    except (ValueError, TypeError):
        amount = 0.0

    timestamp = datetime.utcnow().strftime("%d-%m-%Y %H:%M:%S")

    return render_template(
        'retrait_success.html',
        transaction_id=transaction_id,
        amount=amount,
        method=method,
        address_or_number=address_or_number,
        timestamp=timestamp
    )
# ----------------------------
# Admin: lister / valider / rejeter dépôts
# (Important: ici il n'y a PAS d'auth admin; protège ces routes en prod)
# ----------------------------
def admin_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        # placeholder simple: tu peux définir session['is_admin']=True manuellement pour tester
        if not session.get('is_admin'):
            flash("Accès admin requis.", "error")
            return redirect(url_for('connexion'))
        return f(*args, **kwargs)
    return decorated

@app.route('/admin/deposits', methods=['GET', 'POST'])
def admin_deposits():
    # --- 1. Lister tous les dépôts depuis la table Transaction ---
    depots_list = Transaction.query.filter(Transaction.type.startswith('Dépôt')) \
                                   .order_by(Transaction.date.desc()).all()

    # --- 2. Validation ou rejet d'un dépôt ---
    if request.method == 'POST':
        depot_id = request.form.get('depot_id')
        action = request.form.get('action')

        if not depot_id:
            flash("Aucun dépôt sélectionné.", "warning")
            return redirect(url_for('admin_deposits'))

        txn = Transaction.query.filter_by(id=depot_id).first()
        if not txn:
            flash("Dépôt introuvable.", "error")
            return redirect(url_for('admin_deposits'))

        user = User.query.filter_by(email=txn.user_email).first()
        if not user:
            flash("Utilisateur introuvable.", "error")
            return redirect(url_for('admin_deposits'))

        # --- Valider le dépôt ---
        if action == 'validate' and txn.status == 'pending':
            txn.status = 'accepted'
            user.balance = round(user.balance + txn.amount, 2)

            # Historique du filleul
            historique = getattr(user, 'mon_historique', [])
            historique.append({
                'date': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
                'description': 'Dépôt validé (admin)',
                'montant': txn.amount,
                'status': 'validé'
            })
            user.mon_historique = historique

            # Commission du parrain
            parrain_username = getattr(user, 'parrain', None)
            if parrain_username and not user.has_made_first_deposit:
                commission = round(txn.amount * 0.3, 2)
                parrain_user = User.query.filter_by(username=parrain_username).first()
                if parrain_user:
                    parrain_user.balance = round(parrain_user.balance + commission, 2)
                    parrain_user.mon_historique = getattr(parrain_user, 'mon_historique', []) + [{
                        'date': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
                        'description': f'Commission de 30% du dépôt de {user.username}',
                        'montant': commission,
                        'status': 'reçu'
                    }]
                    flash(f"Commission de {commission} XOF ajoutée à {parrain_username}.", "info")

                user.has_made_first_deposit = True

            flash(f"Dépôt {depot_id} validé et solde crédité.", "success")

        # --- Rejeter le dépôt ---
        elif action == 'reject' and txn.status == 'pending':
            txn.status = 'rejected'
            flash(f"Dépôt {depot_id} rejeté.", "info")

        db.session.commit()
        return redirect(url_for('admin_deposits'))

    # --- 3. Affichage du tableau ---
    depots_display = [{
        'id': d.id,
        'email': d.user_email,
        'amount': d.amount,
        'method': d.type.replace('Dépôt via ', ''),
        'status': d.status,
        'created_at': d.date.strftime('%Y-%m-%d %H:%M:%S')
    } for d in depots_list]

    return render_template('admin_deposits.html', depots=depots_display)

# ----------------------------
# Admin: lister / valider / rejeter retraits
# ----------------------------
@app.route('/admin/retraits')
def admin_retraits():
    users_data = load_users_data()
    withdrawals = []

    for email, user in users_data.items():
        for h in user.get('historique', []):  # ✅ clé correcte
            if h.get('type') == 'retrait':  # ✅ type correct
                withdrawal_entry = {
                    'user_email': email,
                    'amount': h.get('amount', 0),
                    'country': h.get('country', 'Inconnu'),
                    'method': h.get('method', 'Inconnu'),
                    'receiver': h.get('receiver', ''),
                    'status': h.get('status', 'En attente'),
                    'timestamp': h.get('timestamp', '')
                }
                withdrawals.append(withdrawal_entry)

    return render_template('admin_retraits.html', withdrawals=withdrawals)

@app.route('/admin/retraits/validate/<user_email>/<timestamp>')
def validate_retraits(user_email, timestamp):
    users_data = load_users_data()
    user = users_data.get(user_email)
    if user:
        for h in user.get('historique', []):
            if h.get('type') == 'retrait' and h.get('timestamp') == timestamp:
                h['status'] = 'Validé'
                break
        users_data[user_email] = user
        save_users_data(users_data)
    return redirect(url_for('admin_retraits'))

@app.route('/admin/retraits/reject/<user_email>/<timestamp>')
def reject_retraits(user_email, timestamp):
    users_data = load_users_data()
    user = users_data.get(user_email)
    if user:
        for h in user.get('historique', []):
            if h.get('type') == 'retrait' and h.get('timestamp') == timestamp:
                h['status'] = 'Rejeté'
                # ✅ Restitution du montant au solde
                user['balance'] += h.get('amount', 0)
                break
        users_data[user_email] = user
        save_users_data(users_data)
    return redirect(url_for('admin_retraits'))

@app.route('/parrainage')
def parrainage_page():
    """Affiche la page de parrainage avec le lien, la liste des filleuls et le total des commissions."""
    user_email = get_logged_in_user_email()
    if not user_email:
        flash("Veuillez vous connecter pour accéder à votre page de parrainage.", "error")
        return redirect(url_for('connexion'))

    # 🔹 Récupérer l'utilisateur connecté
    user = User.query.filter_by(email=user_email).first()
    if not user:
        flash("Utilisateur introuvable.", "error")
        return redirect(url_for('connexion'))

    # 🔹 Déterminer le nom d'utilisateur (ou fallback sur l'email)
    username = user.username or user_email.split('@')[0]

    # 🔹 Générer le lien de parrainage complet
    referral_link = f"{request.url_root.replace('http://', 'https://')}inscription?ref={username}"

    # 🔹 Lister les filleuls (ceux qui ont mis le parrain à 'username')
    filleuls_query = User.query.filter_by(parrain=username).all()
    filleuls = [{"username": f.username or f.email, "email": f.email} for f in filleuls_query]
    referrals_count = len(filleuls)

    # 🔹 Calculer le total des commissions depuis la table Historique
    total_commissions = 0.0
    historiques = Historique.query.filter(
        Historique.user_id == user.id,
        Historique.description.ilike('%Commission de parrainage%')
    ).all()

    for h in historiques:
        try:
            total_commissions += float(h.montant)
        except (TypeError, ValueError):
            continue

    # 🔹 Rendre la page
    return render_template(
        'parrainage.html',
        user=user,
        referral_link=referral_link,
        referrals_count=referrals_count,
        total_commissions=f"{total_commissions:.2f}",
        filleuls=filleuls
    )

@app.route('/admin/withdrawals', methods=['GET', 'POST'])
def admin_withdrawals():
    # --- Récupérer tous les retraits ---
    withdrawals = Withdrawal.query.order_by(Withdrawal.timestamp.desc()).all()

    if request.method == 'POST':
        withdrawal_id = request.form.get('withdrawal_id')
        action = request.form.get('action')

        if not withdrawal_id:
            flash("Aucun retrait sélectionné.", "warning")
            return redirect(url_for('admin_withdrawals'))

        w = Withdrawal.query.filter_by(id=withdrawal_id).first()
        if not w:
            flash("Retrait introuvable.", "danger")
            return redirect(url_for('admin_withdrawals'))

        user = User.query.filter_by(email=w.user_email).first()
        if not user:
            flash("Utilisateur introuvable.", "danger")
            return redirect(url_for('admin_withdrawals'))

        if w.status.lower() in ['en attente', 'pending']:
            if action == 'validate':
                w.status = 'accepted'
                user.balance = round(user.balance - w.amount, 2)

                # Historique
                hist_entry = Historique(
                    user_id=user.id,
                    date=datetime.utcnow(),
                    description=f"Retrait validé (admin)",
                    montant=-w.amount,
                    type='debit',
                    status='validé',
                    solde_apres=user.balance
                )
                db.session.add(hist_entry)
                flash(f"Retrait {withdrawal_id} validé.", "success")

            elif action == 'reject':
                w.status = 'rejected'
                flash(f"Retrait {withdrawal_id} rejeté.", "info")

            db.session.commit()
        else:
            flash("Ce retrait a déjà été traité.", "warning")

        return redirect(url_for('admin_withdrawals'))

    # Préparer affichage
    withdrawals_display = [{
        'id': w.id,
        'email': w.user_email,
        'amount': w.amount,
        'method': w.method,
        'receiver': w.receiver,
        'status': w.status,
        'created_at': w.timestamp.strftime("%Y-%m-%d %H:%M:%S") if w.timestamp else ""
    } for w in withdrawals]

    return render_template('admin_withdrawals.html', withdrawals=withdrawals_display)

@app.route('/historique')
def historique_page():
    """Affiche l'historique complet (dépôts + retraits) de l'utilisateur actuel."""
    user_email = get_logged_in_user_email()
    if not user_email:
        user_info = {'username': 'Invité', 'balance': 0.0}
        user_history = []
    else:
        user_info = User.query.filter_by(email=user_email).first()
        if not user_info:
            user_info = {'username': 'Invité', 'balance': 0.0}
            user_history = []
        else:
            user_history = []

            # --- 1️⃣ Transactions de dépôts ---
            transactions = Transaction.query.filter_by(user_email=user_email)\
                                            .order_by(Transaction.date.desc()).all()
            for t in transactions:
                user_history.append({
                    'date': t.date.strftime('%Y-%m-%d %H:%M:%S') if t.date else '',
                    'description': t.description or t.type or 'Dépôt',
                    'montant': t.amount if t.type.startswith('Dépôt') else -t.amount,
                    'status': t.status
                })

            # --- 2️⃣ Historique des retraits (table Historique) ---
            retraits = Historique.query.join(User).filter(User.email == user_email)\
                                       .order_by(Historique.date.desc()).all()
            for h in retraits:
                user_history.append({
                    'date': h.date.strftime('%Y-%m-%d %H:%M:%S') if h.date else '',
                    'description': h.description or 'Retrait',
                    'montant': h.montant,
                    'status': h.status
                })

            # --- 3️⃣ Fusionner avec ancien historique JSON s’il existe ---
            if getattr(user_info, 'mon_historique', None):
                user_history.extend(user_info.mon_historique)

            # --- 4️⃣ Trier par date décroissante ---
            user_history.sort(
                key=lambda x: datetime.strptime(x['date'], '%Y-%m-%d %H:%M:%S') if x.get('date') else datetime.min,
                reverse=True
            )

    return render_template('mon-historique.html', user_history=user_history, user_info=user_info)

INVESTMENT_PLANS = {
    "plan_60_jours": {
        "VIP1": {"investissement": 3000, "duree_jours": 60, "gain_quotidien": 600, "gain_total": 36000},
        "VIP2": {"investissement": 9000, "duree_jours": 60, "gain_quotidien": 1800, "gain_total": 108000},
        "VIP3": {"investissement": 15000, "duree_jours": 60, "gain_quotidien": 3000, "gain_total": 180000},
        "VIP4": {"investissement": 30000, "duree_jours": 60, "gain_quotidien": 6000, "gain_total": 360000},
        "VIP5": {"investissement": 90000, "duree_jours": 60, "gain_quotidien": 18000, "gain_total": 1080000},
        "VIP6": {"investissement": 150000, "duree_jours": 60, "gain_quotidien": 30000, "gain_total": 1800000},
        "VIP7": {"investissement": 300000, "duree_jours": 60, "gain_quotidien": 60000, "gain_total": 3600000},
        "VIP8": {"investissement": 900000, "duree_jours": 60, "gain_quotidien": 180000, "gain_total": 10800000},
    },
    "plan_bien_etre": {
        "VIP1": {"investissement": 5000, "duree_jours": 30, "gain_quotidien": 500, "gain_total": 15000},
        "VIP2": {"investissement": 12000, "duree_jours": 30, "gain_quotidien": 1200, "gain_total": 36000},
        "VIP3": {"investissement": 25000, "duree_jours": 30, "gain_quotidien": 2500, "gain_total": 75000},
        "VIP4": {"investissement": 45000, "duree_jours": 30, "gain_quotidien": 4500, "gain_total": 135000},
    }
}


@app.route('/investi', methods=['GET', 'POST'])
def investi_page():
    email = get_logged_in_user_email()
    if not email:
        flash("Veuillez vous connecter pour investir.", "error")
        return redirect(url_for('connexion'))

    user = User.query.filter_by(email=email).first()
    if not user:
        flash("Utilisateur introuvable.", "error")
        return redirect(url_for('connexion'))

    current_solde = user.balance or 0.0
    message = None

    if request.method == 'POST':
        plan_id = request.form.get('plan_id')
        try:
            plan_parts = plan_id.split('_')
            vip_level = plan_parts[-1]
            plan_type = "_".join(plan_parts[:-1])
            plan = INVESTMENT_PLANS[plan_type][vip_level]
            cost = plan['investissement']
            duree_jours = plan['duree_jours']
            revenu_quotidien = plan.get('gain_quotidien', 0)
            rendement_total = plan.get('gain_total', revenu_quotidien * duree_jours)
        except Exception:
            message = {"type": "error", "text": "Plan invalide."}
            return render_template('investi.html', plans=INVESTMENT_PLANS, user_solde=current_solde, message=message)

        if current_solde < cost:
            message = {"type": "error", "text": f"Solde insuffisant. Vous avez besoin de {cost} XOF."}
            return render_template('investi.html', plans=INVESTMENT_PLANS, user_solde=current_solde, message=message)

        user.balance = round(current_solde - cost, 2)

        new_investment = Investissement(
            user_email=user.email,
            nom=f"{vip_level} ({plan_type})",
            montant=cost,
            date_debut=datetime.now(),
            duree_jours=duree_jours,
            revenu_quotidien=revenu_quotidien,
            rendement_total=rendement_total,
            status="En cours",
            last_credit=None
        )
        db.session.add(new_investment)

        # Historique
        historique_entry = Historique(
            user_id=user.id,
            date=datetime.now(),
            description=f"Investissement {vip_level} ({plan_type})",
            montant=-cost,
            type='debit',
            status='réussi',
            solde_apres=user.balance
        )
        db.session.add(historique_entry)

        # Commission parrain
        if user.parrain:
            parrain = User.query.filter_by(email=user.parrain).first()
            if parrain:
                commission = round(cost * 0.30, 2)
                parrain.balance = (parrain.balance or 0.0) + commission
                hist_parrain = Historique(
                    user_id=parrain.id,
                    date=datetime.now(),
                    description=f"Commission parrainage (30%) sur investissement de {user.username}",
                    montant=commission,
                    type='credit',
                    status='Validé',
                    solde_apres=parrain.balance
                )
                db.session.add(hist_parrain)

        db.session.commit()
        flash(f"✅ Vous avez investi {cost:,.0f} XOF dans {vip_level} ({plan_type}).", "success")
        return redirect(url_for('invest_confirm', investment_id=new_investment.id))

    return render_template('investi.html', plans=INVESTMENT_PLANS, user_solde=current_solde, message=message)


# --- Confirmation d'investissement ---
@app.route('/invest_confirm/<int:investment_id>')
def invest_confirm(investment_id):
    email = get_logged_in_user_email()
    if not email:
        flash("Veuillez vous connecter.", "error")
        return redirect(url_for('connexion'))

    user = User.query.filter_by(email=email).first()
    investment = Investissement.query.filter_by(id=investment_id, user_email=user.email).first()

    if not investment:
        flash("Investissement introuvable.", "error")
        return redirect(url_for('investi_page'))

    return render_template('invest_confirm.html', investment=investment, user=user)


# --- Validation d'investissement ---
@app.route('/invest_validate/<int:investment_id>', methods=['POST'])
def invest_validate(investment_id):
    email = get_logged_in_user_email()
    if not email:
        flash("Veuillez vous connecter.", "error")
        return redirect(url_for('connexion'))

    user = User.query.filter_by(email=email).first()
    investment = Investissement.query.filter_by(id=investment_id, user_email=user.email).first()

    if not investment:
        flash("Investissement introuvable.", "error")
        return redirect(url_for('investi_page'))

    investment.status = 'En cours'

    historique_entry = Historique(
        user_id=user.id,
        date=datetime.now(),
        description=f"Confirmation de l'investissement {investment.nom}",
        montant=investment.montant,
        type='debit',
        status='En cours',
        solde_apres=user.balance
    )
    db.session.add(historique_entry)
    db.session.commit()

    flash("Votre investissement a été confirmé et ajouté à votre historique ✅", "success")
    return redirect(url_for('dashboard_page'))

@app.route('/referral')
def referral_page():
    """Affiche la page de parrainage avec lien et liste des filleuls, avec commission sur premier dépôt."""
    from flask import request

    user_email = get_logged_in_user_email()
    if not user_email:
        return render_template(
            'referral.html',
            referral_link=None,
            filleuls=[],
            message="Veuillez vous connecter pour accéder à votre lien de parrainage."
        )

    # --- Récupération de l'utilisateur depuis la base ---
    user = User.query.filter_by(email=user_email).first()
    if not user:
        return render_template(
            'referral.html',
            referral_link=None,
            filleuls=[],
            message="Utilisateur introuvable."
        )

    username = user.username or user_email.split('@')[0]

    # --- Génération du lien de parrainage ---
    referral_code = username
    referral_link = f"{request.url_root}inscription?ref={referral_code}".replace("http://", "https://")

    filleuls_list = []
    now = datetime.now()

    # --- Recherche des filleuls ---
    filleuls_users = User.query.filter_by(parrain=username).all()

    for f in filleuls_users:
        total_depot = 0.0

        # Cherche tous les dépôts validés du filleul
        valid_deposits = Deposit.query.filter_by(user_id=f.id, status='accepted').all()

        for d in valid_deposits:
            total_depot += d.amount

        # Vérifie si commission à créditer (premier dépôt seulement)
        if valid_deposits and not f.has_made_first_deposit:
            first_deposit = valid_deposits[0]
            commission = round(first_deposit.amount * 0.3, 2)

            # Créditer le solde du parrain
            user.balance = (user.balance or 0) + commission

            # Ajouter dans l'historique
            historique_entry = Historique(
                user_id=user.id,
                date=now,
                description=f"Commission de parrainage (30%) sur le dépôt de {f.username or f.email}",
                montant=commission,
                status="Validé",
                solde_apres=user.balance
            )
            db.session.add(historique_entry)

            # Marquer le filleul comme ayant fait son premier dépôt
            f.has_made_first_deposit = True

        filleuls_list.append({
            "nom": f.username or f.email,
            "email": f.email,
            "total_depot": total_depot
        })

    # Commit final pour tous les changements
    db.session.commit()

    return render_template(
        'referral.html',
        referral_link=referral_link,
        filleuls=filleuls_list,
        user_info=user
    )

@app.route('/tasks', methods=['GET', 'POST'])
def tasks_page():
    """Gère la réclamation du bonus quotidien (Route publique)."""

    BONUS_AMOUNT = 50.0  # Montant du bonus quotidien en XOF
    today_str = datetime.utcnow().strftime("%Y-%m-%d")
    message = None

    user_email = get_logged_in_user_email()

    if not user_email:
        # Utilisateur non connecté
        return render_template(
            'tasks.html',
            user_solde=0.0,
            message={"type": "error", "text": "Veuillez vous connecter pour réclamer votre Bonus Quotidien."},
            bonus_claimed_today=True,
            bonus_amount=BONUS_AMOUNT
        )

    # Récupère l'utilisateur depuis PostgreSQL
    user = User.query.filter_by(email=user_email).first()
    if not user:
        return render_template(
            'tasks.html',
            user_solde=0.0,
            message={"type": "error", "text": "Utilisateur introuvable."},
            bonus_claimed_today=True,
            bonus_amount=BONUS_AMOUNT
        )

    # Vérifie si le bonus a été réclamé aujourd'hui
    bonus_claimed_today = (str(user.last_bonus_date) == today_str)

    if request.method == 'POST':
        if not bonus_claimed_today:
            # Crédit du bonus
            user.balance = (user.balance or 0.0) + BONUS_AMOUNT
            user.last_bonus_date = today_str

            # Ajout dans l'historique
            transaction = Historique(
                user_id=user.id,
                date=datetime.utcnow(),
                description="Bonus Quotidien réclamé",
                montant=BONUS_AMOUNT,
                type="credit",
                status="Validé",
                solde_apres=user.balance
            )
            db.session.add(transaction)
            db.session.commit()

            bonus_claimed_today = True
            message = {"type": "success", "text": f"Félicitations ! Vous avez reçu {BONUS_AMOUNT} XOF de Bonus Quotidien."}
        else:
            message = {"type": "error", "text": "Vous avez déjà réclamé votre Bonus Quotidien pour aujourd'hui."}

    current_solde = user.balance or 0.0

    return render_template(
        'tasks.html',
        user_solde=current_solde,
        message=message,
        bonus_claimed_today=bonus_claimed_today,
        bonus_amount=BONUS_AMOUNT
    )

if __name__ == "__main__":
    if not os.path.exists(USERS_FILE):
        with open(USERS_FILE, 'w') as f:
            json.dump({}, f)

    port = int(os.environ.get("PORT", 10000))  # Render demande d'utiliser PORT ou 10000
    app.run(host="0.0.0.0", port=port, debug=False)
