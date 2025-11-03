from functools import wraps
from flask import Flask, render_template, request, redirect, url_for, flash, session, jsonify
from datetime import datetime, timedelta
import json, os, uuid
from werkzeug.utils import secure_filename

# ----------------------------
# Configuration de l'application
# ----------------------------
app = Flask(__name__, template_folder='templates')
app.secret_key = 'votre_cle_secrete_tres_securisee'  # change en prod
app.config['UPLOAD_FOLDER'] = 'static/proofs'

# Fichiers de données
DATA_DIR = "data"
USERS_FILE = os.path.join(DATA_DIR, 'users.json')
DEPOTS_FILE = os.path.join(DATA_DIR, 'depots_en_attente.json')
RETRAITS_FILE = os.path.join(DATA_DIR, 'retraits_en_attente.json')

# Constantes
BONUS_PARRAINAGE = 50.0  # (si tu veux garder ce bonus en plus)
INITIAL_BALANCE = 0.0
VIP_DURATION_DAYS = 60

# Création des dossiers si nécessaire
os.makedirs(DATA_DIR, exist_ok=True)
os.makedirs(app.config['UPLOAD_FOLDER'], exist_ok=True)


# ----------------------------
# Utilitaires JSON
# ----------------------------
def load_json(path):
    if not os.path.exists(path):
        return {}
    try:
        with open(path, 'r', encoding='utf-8') as f:
            return json.load(f)
    except (json.JSONDecodeError, FileNotFoundError):
        return {}


def save_json(path, data):
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=4, ensure_ascii=False)


# Users helpers (centralisés)
def load_users_data():
    """Charge users depuis data/users.json"""
    return load_json(USERS_FILE)


def save_users_data(data):
    save_json(USERS_FILE, data)


def ensure_user_exists(email):
    """
    Si l'utilisateur n'existe pas dans users.json, le crée avec structure minimale.
    Retourne (user_dict, users_data)
    """
    users_data = load_users_data()
    if email not in users_data:
        users_data[email] = {
            "username": "",
            "email": email,
            "phone": "",
            "password": "",
            "balance": INITIAL_BALANCE,
            "historique": [],
            "transactions": [],
            "parrain": None,
            "investments": [],
            "has_made_first_deposit": False,
            "date_inscription": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        }
        save_users_data(users_data)
    return users_data[email], users_data


def add_history_entry(user_email, description, montant, status, users_data=None):
    """
    Ajoute une entrée d'historique pour un utilisateur (et sauvegarde).
    Compatible avec ou sans users_data (pour éviter l'erreur de trop d'arguments).
    """
    # Charger les données si non fournies
    if users_data is None:
        users_data = load_users_data()

    # Vérifier que l'utilisateur existe
    if user_email not in users_data:
        return

    user = users_data[user_email]

    # Préparer l'entrée
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    entry = {
        'date': timestamp,
        'description': description,
        'montant': montant,
        'solde_apres': user.get('balance', 0.0),
        'status': status
    }

    # Ajouter dans l’historique
    user.setdefault('historique', []).append(entry)

    # Sauvegarder
    users_data[user_email] = user
    save_users_data(users_data)

def get_logged_in_user_email():
    """Retourne l'email de l'utilisateur connecté (session['email'])."""
    return session.get('email')


# ----------------------------
# Routes d'inscription / connexion
# ----------------------------
@app.route('/inscription', methods=['GET', 'POST'])
def inscription_page():
    referral_code = request.args.get('ref')
    message = None

    users_data = load_users_data()

    if request.method == 'POST':
        username = request.form.get('username')
        email = request.form.get('email', '').strip().lower()
        password = request.form.get('password')
        phone = request.form.get('phone', '')
        parrainage_code = request.form.get('referral_code', referral_code)

        if not email or not password:
            message = {"type": "error", "text": "Email et mot de passe requis."}
            return render_template('inscription.html', message=message, referral_code=referral_code)

        if email in users_data:
            message = {"type": "error", "text": "Cet email est déjà enregistré."}
        else:
            users_data[email] = {
                "username": username or email.split('@')[0],
                "email": email,
                "phone": phone,
                "password": password,          # ⚠️ à hasher en production
                "balance": INITIAL_BALANCE,
                "historique": [],
                "transactions": [],
                "parrain": parrainage_code if parrainage_code else None,
                "investments": [],
                "has_made_first_deposit": False,
                "date_inscription": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            }

            # Si parrain valide, on peut ajouter le filleul à une liste si souhaité.
            if parrainage_code and parrainage_code in users_data:
                # Optionnel : ajouter field 'filleuls' si absent
                users_data.setdefault(parrainage_code, {}).setdefault('filleuls', [])
                users_data[parrainage_code].setdefault('filleuls', []).append(email)

            save_users_data(users_data)
            # Connexion auto après inscription
            session['email'] = email
            flash("Inscription réussie !", "success")
            return redirect(url_for('dashboard_page'))

    return render_template('inscription.html', message=message, referral_code=referral_code)


@app.route('/connexion', methods=['GET', 'POST'])
def connexion():
    message = None
    users_data = load_users_data()

    if request.method == 'POST':
        email = request.form.get('email', '').strip().lower()
        password = request.form.get('password')

        if email in users_data:
            user = users_data[email]
            if user.get('password') == password:
                session['email'] = email  # <-- clé cohérente avec le reste du code
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
    users_data = load_users_data()
    user_email = get_logged_in_user_email()

    if not user_email or user_email not in users_data:
        flash("Veuillez vous connecter.", "warning")
        return redirect(url_for('connexion'))

    user = users_data[user_email]
    # Normalisation pour templates
    user_display = {
        'username': user.get('username', user_email.split('@')[0]),
        'email': user.get('email', user_email),
        'phone': user.get('phone', ''),
        'balance': round(user.get('balance', 0.0), 2),
        'historique': user.get('mon_historique', []),
        'transactions': user.get('transactions', []),
        'parrain': user.get('parrain'),
        'filleuls': user.get('filleuls', []),
        'investments': user.get('investments', [])
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
    users_data = load_users_data()

    user_info = users_data.get(user_email) if user_email else None

    if not user_info:
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
                               historique=guest['mon_historique'],
                               transactions=guest['transactions'])
    # utilisateur connecté
    return render_template(
        'profile.html',
        user_name=user_info.get('username'),
        user_email=user_info.get('email'),
        user_phone=user_info.get('phone'),
        user_solde=round(user_info.get('balance', 0.0), 2),
        date_joined=user_info.get('date_inscription'),
        parrain=user_info.get('parrain'),
        historique=user_info.get('mon_historique', []),
        transactions=user_info.get('transactions', [])
    )


PAYMENT_ACCOUNTS = {
    "xof": {
        "name": "3000 XOF",
        "link": "https://app.payix.me/payment/c7584d8a-0390-493b-9225-8c6b5ac3d9c0",
        "currency": "5 Pays"
    },
    "xaf": {
        "name": "5000 XOF",
        "link": "https://app.payix.me/payment/908ab136-1c02-4090-9796-debb91d1ca37",
        "currency": "5 Pays"
    },
    "usdt": {
        "name": "10000 XOF",
        "link": "https://app.payix.me/payment/d6195d97-c317-49d7-9f0e-890edb7d0d66",
        "currency": "5 Pays"
    },
    "euro": {
        "name": "Tous les pays",
        "link": "https://www.pay.moneyfusion.net/presto-cash-_1761998050886/",
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

    if not amount or not method or not reference_text:
        return "Erreur: Données de transaction incomplètes.", 400

    user_email = get_logged_in_user_email()
    if not user_email:
        return "Erreur : Utilisateur non connecté.", 401

    users = load_users_data()

    transaction_data = {
        'id': transaction_id,
        'amount': float(amount),
        'method': method,
        'sender_phone': sender_phone,
        'reference': reference_text,
        'status': 'pending',  # ⚡ statut pour l'admin
        'timestamp': datetime.today().isoformat()
    }

    if user_email in users:
        user = users[user_email]
        # Ajout dans transactions existantes
        user.setdefault('transactions', []).append(transaction_data)
        # ⚡ Ajout dans deposits pour l'admin
        user.setdefault('deposits', []).append(transaction_data)
        if not user.get('phone') and sender_phone:
            user['phone'] = sender_phone
        users[user_email] = user
        save_users_data(users)

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
    """Affiche la liste complète des produits VIP pour tous les utilisateurs."""

    user_email = get_logged_in_user_email()
    all_users_data = load_users_data()

    user_info = None
    if user_email:
        user_info = all_users_data.get(user_email)

    # Si l'utilisateur n'est pas connecté, on crée un profil invité
    if user_info is None:
        user_info = {
            'username': 'Invité',
            'balance': 0.0
        }

    # ✅ Vérification du droit d'accès aux produits VIP :
    # L'utilisateur doit avoir investi 9000 XOF dans un produit de 60 jours avant d’accéder aux VIP
    historique = user_info.get('mon_historique', [])
    eligible_vip = any(
        "9000" in str(h.get('montant', '')) or "60 jours" in str(h.get('description', '')).lower()
        for h in historique
    )

    # Si pas éligible, on affiche un message d’accès restreint
    if not eligible_vip:
        return render_template(
            'decouvrir_bloque.html',
            user_info=user_info
        )

    # Sinon on affiche les produits VIP
    return render_template(
        'decouvrir.html',
        products=list(PRODUITS_VIP.values()),
        user_info=user_info
    )

@app.route('/investir/<product_id>', methods=['GET', 'POST'])
def investir(product_id):
    """Permet à un utilisateur d'investir dans un produit Découvrir (VIP)."""
    user_email = get_logged_in_user_email()
    if not user_email:
        return redirect(url_for('connexion'))

    all_users_data = load_users_data()
    user_data = all_users_data.get(user_email)
    product = PRODUITS_VIP.get(product_id)

    if not product:
        return redirect(url_for('decouvrir_page'))

    if not user_data:
        flash("Utilisateur introuvable.", "danger")
        return redirect(url_for('decouvrir_page'))

    if request.method == 'POST':
        current_balance = float(user_data.get('balance', 0.0))
        investment_amount = float(product['montant_min'])

        if current_balance < investment_amount:
            return render_template(
                'investir.html',
                product=product,
                message="⚠️ Solde insuffisant pour cet investissement.",
                user_info=user_data
            )

        # --- Débiter le solde ---
        user_data['balance'] = round(current_balance - investment_amount, 2)

        # --- Historique de l’investissement ---
        add_history_entry(
            user_email,
            f"Investissement VIP: {product['nom']}",
            -investment_amount,
            'En cours'
        )

        # ✅ NOUVEAU : Enregistrement de la date et heure d’investissement
        user_data.setdefault('investissements_vip', [])
        investissement = {
            "produit_id": product_id,
            "nom": product['nom'],
            "montant": investment_amount,
            "date_investissement": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            "duree_jours": product.get('duree_jours', 21),
            "statut": "en cours"
        }
        user_data['investissements_vip'].append(investissement)

        # --- Commission du parrain ---
        parrain_email = user_data.get('parrain') or user_data.get('parrain_id')
        if parrain_email and parrain_email in all_users_data:
            commission = round(investment_amount * 0.30, 2)
            parrain_data = all_users_data[parrain_email]
            parrain_data['balance'] = round(parrain_data.get('balance', 0.0) + commission, 2)

            add_history_entry(
                parrain_email,
                f"Commission de parrainage (30%) sur investissement de {user_data.get('username', user_email)}",
                commission,
                'Validé'
            )
         # --- Enregistre aussi dans la liste des investissements VIP ---

        user_data.setdefault('investissements_vip', []).append(investment_amount)

        # ✅ Sauvegarde finale
        all_users_data[user_email] = user_data
        save_users_data(all_users_data)

        message = f"✅ Félicitations ! Vous avez investi {investment_amount:,.0f} XOF dans {product['nom']}."
        return render_template('investir.html', product=product, message=message, user_info=user_data)

    return render_template('investir.html', product=product, message=None, user_info=user_data)
# --- Produits rapides ---
VIP_PRODUITS = {
    'VIP3K': {
        'id': 'VIP3K',
        'nom': 'VIP Mini',
        'montant_min': 3000,
        'duree_jours': 3,
        'revenu_quotidien': 1800,
        'rendement_total': 5400,
        'description': "Le meilleur point de départ pour investir.",
        'image_url': 'prestige.png',
    },
    'VIP9K': {
        'id': 'VIP9K',
        'nom': 'VIP Découverte',
        'montant_min': 9000,
        'duree_jours': 3,
        'revenu_quotidien': 5400,
        'rendement_total': 16200,
        'description': "Augmentez votre potentiel avec un investissement intermédiaire.",
        'image_url': 'decouverte.png',
    },
    'VIP15K': {
        'id': 'VIP15K',
        'nom': 'VIP Pro',
        'montant_min': 15000,
        'duree_jours': 3,
        'revenu_quotidien': 9000,
        'rendement_total': 27000,
        'description': "La voie rapide vers des gains significatifs.",
        'image_url': 'pro.png',
    },
    'VIP30K': {
        'id': 'VIP30K',
        'nom': 'VIP Expert',
        'montant_min': 30000,
        'duree_jours': 3,
        'revenu_quotidien': 18000,
        'rendement_total': 54000,
        'description': "Optimisez vos revenus avec cette offre de pointe.",
        'image_url': 'expert.png',
    },
    'VIP60K': {
        'id': 'VIP60K',
        'nom': 'VIP Premium',
        'montant_min': 60000,
        'duree_jours': 3,
        'revenu_quotidien': 36000,
        'rendement_total': 108000,
        'description': "Maximisez votre portefeuille avec un investissement majeur.",
        'image_url': 'premium.png',
    },
    'VIP120K': {
        'id': 'VIP120K',
        'nom': 'VIP Ultime',
        'montant_min': 120000,
        'duree_jours': 3,
        'revenu_quotidien': 72000,
        'rendement_total': 216000,
        'description': "Le summum des opportunités d'investissement rapide.",
        'image_url': 'ultime.png',
    }
}

@app.route('/produits_rapide')
def produits_rapide_page():
    """Affiche les produits rapides (3 jours) si l'utilisateur a déposé au moins 15 000 XOF."""

    user_email = get_logged_in_user_email()
    all_users_data = load_users_data()

    # 🔒 Vérifie si l'utilisateur est connecté
    if not user_email or user_email not in all_users_data:
        flash("Veuillez vous connecter pour accéder aux produits rapides.", "error")
        return redirect(url_for('connexion'))

    user_info = all_users_data[user_email]

    # 🧾 1️⃣ Total des dépôts confirmés
    total_depots = sum(
        float(dep.get('amount', 0))
        for dep in user_info.get('deposits', [])
        if str(dep.get('status', '')).lower() in ['accepté', 'accepted', 'validé']
    )

    # 🧾 2️⃣ Ajoute aussi les dépôts depuis l’historique
    total_depots += sum(
        float(h.get('montant', 0))
        for h in user_info.get('mon_historique', [])
        if 'dépôt' in str(h.get('description', '')).lower() and float(h.get('montant', 0)) > 0
    )

    # 🚫 Vérifie si le total des dépôts atteint 15 000 XOF
    if total_depots < 15000:
        flash("⚠️ Vous devez avoir au moins 15 000 XOF de dépôts cumulés pour accéder aux produits rapides.", "warning")
        return render_template('produits_bloque.html', user_info=user_info, total_depots=total_depots)

    # ✅ Sécurité : VIP_PRODUITS doit être un dict
    if not isinstance(VIP_PRODUITS, dict):
        flash("Erreur interne : les produits rapides ne sont pas correctement configurés.", "error")
        return render_template('produits_bloque.html', user_info=user_info)

    produits_rapide = list(VIP_PRODUITS.values())
    return render_template('produits_rapide.html', user_info=user_info, produits=produits_rapide)
    

@app.route('/investir_rapide/<product_id>', methods=['GET', 'POST'])
def investir_rapide(product_id):
    """Permet d'investir dans un produit rapide (max 2 investissements par produit)."""

    user_email = get_logged_in_user_email()
    if not user_email:
        flash("Veuillez vous connecter pour investir.", "error")
        return redirect(url_for('connexion'))

    users = load_users_data()
    user = users.get(user_email)

    # 🧩 Trouver le produit selon son ID
    product = None
    if isinstance(VIP_PRODUITS, list):
        for p in VIP_PRODUITS:
            if isinstance(p, dict) and str(p.get("id")) == str(product_id):
                product = p
                break
    elif isinstance(VIP_PRODUITS, dict):
        product = VIP_PRODUITS.get(product_id)

    # 🔍 Vérification
    if not product or not user:
        flash("Produit ou utilisateur introuvable.", "error")
        return redirect(url_for('produits_rapide_page'))

    # 🔢 Vérifie le nombre d'investissements existants sur ce produit
    existing_investments = [
        i for i in user.get('investissements_vip', [])
        if isinstance(i, dict) and i.get('id') == product_id
    ]
    if len(existing_investments) >= 2:
        flash("❌ Vous avez déjà investi 2 fois dans ce produit.", "warning")
        return redirect(url_for('produits_rapide_page'))

    if request.method == 'POST':
        try:
            amount = float(product.get('montant_min', 0))
        except (TypeError, ValueError):
            flash("Montant du produit invalide.", "error")
            return redirect(url_for('produits_rapide_page'))

        balance = float(user.get('balance', 0.0))

        # 💰 Vérifie le solde
        if balance < amount:
            flash("⚠️ Solde insuffisant pour cet investissement.", "danger")
            return redirect(url_for('produits_rapide_page'))

        # 💸 Débit du solde
        user['balance'] = round(balance - amount, 2)

        # 🧾 Enregistre l’investissement
        investment_entry = {
            'id': product_id,
            'nom': product.get('nom', 'Produit rapide'),
            'montant': amount,
            'revenu_quotidien': product.get('revenu_quotidien', 0),
            'rendement_total': product.get('rendement_total', 0),
            'duree_jours': product.get('duree_jours', 3),
            'date_debut': datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            'status': 'En cours'
        }

        user.setdefault('investissements_vip', [])
        # Nettoyage avant ajout
        user['investissements_vip'] = [
            i for i in user['investissements_vip'] if isinstance(i, dict)
        ]
        user['investissements_vip'].append(investment_entry)

        # 🕓 Historique
        add_history_entry(
            user_email,
            f"Investissement rapide : {product.get('nom', 'Produit rapide')}",
            -amount,
            'En cours'
        )

        # 💾 Sauvegarde
        users[user_email] = user
        save_users_data(users)

        flash(f"✅ Vous avez investi {amount:,.0f} XOF dans {product.get('nom', 'Produit rapide')}.", "success")
        return redirect(url_for('produits_rapide_page'))

    return render_template('investir.html', product=product, user_info=user)

# ----------------------------
# Retrait : sélection / soumission
# ----------------------------
@app.route('/mes_commandes')
def mes_commandes_page():
    """Affiche les investissements de l'utilisateur (en cours ou terminés)."""

    user_email = get_logged_in_user_email()
    users = load_users_data()

    # Vérifie connexion
    if not user_email or user_email not in users:
        return render_template('mes_commandes.html', commandes=[])

    user = users[user_email]

    # 🧾 Récupère les investissements valides (seulement les dictionnaires)
    commandes = [
        i for i in user.get('investissements_vip', [])
        if isinstance(i, dict)
    ]

    return render_template('mes_commandes.html', commandes=commandes, user_info=user)
@app.route('/retrait', methods=['GET', 'POST'])
def retrait_selection():
    email = get_logged_in_user_email()  # récupère l'utilisateur connecté
    users_data = load_users_data()

    if not email or email not in users_data:
        return redirect(url_for('connexion'))  # redirige si non connecté

    user = users_data[email]

    # Méthodes disponibles selon le pays ou crypto
    methods = [
        "Mobile Money Bénin", "Mobile Money Burkina Faso", "Mobile Money Cameroun",
        "Mobile Money Sénégal", "Mobile Money Mali", "Mobile Money Gabon",
        "Mobile Money Côte d'Ivoire", "Mobile Money Togo", "Mobile Money Ouganda", "Mobile Money RD Congo",
        "Mobile Money Zambie", "Crypto BEP20"
    ]

    return render_template('retrait.html', user=user, methods=methods)

@app.route('/process_retrait', methods=['POST'])
def process_retrait():
    user_email = get_logged_in_user_email()
    if not user_email:
        return redirect(url_for('connexion'))

    users = load_users_data()
    user = users.get(user_email)
    if not user:
        return redirect(url_for('connexion'))

    amount = request.form.get('amount')
    method = request.form.get('method')
    address_or_number = request.form.get('address_or_number')

    try:
        amount = float(amount)
        if amount < 1500:
            return "Le montant minimum de retrait est de 1500 XOF.", 400
        if amount > user['balance']:
            return "Solde insuffisant.", 400
    except (ValueError, TypeError):
        return "Montant invalide.", 400

    # Débit provisoire du solde
    user['balance'] -= amount

    # Ajouter la transaction à l'historique
    transaction_id = str(uuid.uuid4())
    transaction = {
        'id': transaction_id,
        'amount': amount,
        'method': method,
        'address_or_number': address_or_number,
        'status': 'En attente',
        'timestamp': datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    }
    user.setdefault('transactions', []).append(transaction)
    user.setdefault('mon_historique', []).append({
        'date': transaction['timestamp'],
        'description': f"Retrait {method}",
        'montant': -amount,
        'solde_apres': user['balance'],
        'status': 'En attente'
    })

    users[user_email] = user
    save_users_data(users)

    return redirect(url_for('retrait_success',
                            transaction_id=transaction_id,
                            amount=amount,
                            method=method,
                            address_or_number=address_or_number))


@app.route('/retrait_success')
def retrait_success():
    transaction_id = request.args.get('transaction_id')
    method = request.args.get('method')
    address_or_number = request.args.get('address_or_number')
    timestamp = datetime.now().strftime("%d-%m-%Y %H:%M:%S")

    try:
        amount = float(request.args.get('amount', 0))
    except (ValueError, TypeError):
        amount = 0.0

    return render_template('retrait_success.html',
                           transaction_id=transaction_id,
                           amount=amount,
                           method=method,
                           address_or_number=address_or_number,
                           timestamp=timestamp)
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
    users = load_users_data()
    depots_list = []

    # --- 1. Lister tous les dépôts ---
    for email, user in users.items():
        for d in user.get('deposits', []):
            depots_list.append({
                'id': d.get('id'),
                'email': email,
                'amount': d.get('amount', 0),
                'method': d.get('method', ''),
                'status': d.get('status', 'pending'),
                'created_at': d.get('timestamp', '')
            })

    depots_list.sort(key=lambda x: x.get('created_at', ''), reverse=True)

    # --- 2. Si l'admin valide ou rejette un dépôt ---
    if request.method == 'POST':
        depot_id = request.form.get('depot_id')
        action = request.form.get('action')

        if not depot_id:
            flash("Aucun dépôt sélectionné.", "warning")
            return redirect(url_for('admin_deposits'))

        found = False
        for email, user in users.items():
            for d in user.get('deposits', []):
                if d.get('id') == depot_id:
                    found = True

                    # === VALIDATION DU DÉPÔT ===
                    if action == 'validate' and d['status'] == 'pending':
                        d['status'] = 'accepted'
                        user['balance'] = round(user.get('balance', 0.0) + float(d['amount']), 2)

                        # 🔹 Historique du filleul
                        user.setdefault('mon_historique', []).append({
                            'date': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
                            'description': 'Dépôt validé (admin)',
                            'montant': float(d['amount']),
                            'status': 'validé'
                        })

                        # === COMMISSION DE 30% POUR LE PARRAIN ===
                        parrain_username = user.get('parrain')
                        if parrain_username and not user.get('has_made_first_deposit', False):
                            commission = round(float(d['amount']) * 0.3, 2)

                            # Trouver le parrain par son username
                            for parrain_email, parrain_data in users.items():
                                if parrain_data.get('username') == parrain_username:
                                    parrain_data['balance'] = round(parrain_data.get('balance', 0.0) + commission, 2)
                                    parrain_data.setdefault('mon_historique', []).append({
                                        'date': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
                                        'description': f'Commission de 30% du dépôt de {user["username"]}',
                                        'montant': commission,
                                        'status': 'reçu'
                                    })
                                    users[parrain_email] = parrain_data
                                    flash(f"Commission de {commission} XOF ajoutée à {parrain_username}.", "info")
                                    break

                            # Marquer le filleul comme ayant fait son premier dépôt
                            user['has_made_first_deposit'] = True

                        flash(f"Dépôt {depot_id} validé et solde crédité.", "success")

                    # === REJET DU DÉPÔT ===
                    elif action == 'reject' and d['status'] == 'pending':
                        d['status'] = 'rejected'
                        flash(f"Dépôt {depot_id} rejeté.", "info")

                    users[email] = user
                    save_users_data(users)
                    break
            if found:
                break

        if not found:
            flash("Dépôt introuvable.", "error")

        return redirect(url_for('admin_deposits'))

    # --- 3. Affichage du tableau ---
    return render_template('admin_deposits.html', depots=depots_list)

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
    """Affiche la page de parrainage uniquement pour les utilisateurs connectés."""
    user_email = get_logged_in_user_email()
    if not user_email:
        flash("Veuillez vous connecter pour accéder à votre page de parrainage.", "error")
        return redirect(url_for('connexion'))
    from flask import request

    users_data = load_users_data()
    user = users_data.get(user_email)
    if not user:
        flash("Utilisateur introuvable.", "error")
        return redirect(url_for('connexion'))

    username = user.get('username', user_email.split('@')[0])

    # 🔹 Liste des filleuls (parrain = username)
    filleuls = [
        u_email for u_email, u_data in users_data.items()
        if u_data.get('parrain') == username
    ]
    referrals_count = len(filleuls)

    # 🔹 Calcul du total des commissions (dans historique + transactions)
    total_commissions = 0.0

    for h in user.get('mon_historique', []):
        if "Commission 30%" in h.get('description', ""):
            try:
                total_commissions += float(h.get('montant', 0))
            except (TypeError, ValueError):
                pass

    for t in user.get('transactions', []):
        if "Commission 30%" in t.get('description', ""):
            try:
                total_commissions += float(t.get('montant', 0))
            except (TypeError, ValueError):
                pass

    # 🔹 Lien de parrainage unique
    referral_link = f"{request.url_root}inscription?ref={referral_code}"
    referral_link = referral_link.replace("http://", "https://")
    # 🔹 Rendu HTML
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
    users = load_users_data()
    withdrawals = {}

    # Extraire tous les retraits "En attente" de tous les utilisateurs
    for email, u in users.items():
        for t in u.get('transactions', []):
            if t.get('status') == 'En attente' and 'address_or_number' in t:
                withdrawals[t['id']] = {
                    'email': email,
                    'amount': t.get('amount', 0),
                    'method': t.get('method', ''),
                    'receiver': t.get('address_or_number', ''),
                    'status': t.get('status', 'En attente'),
                    'timestamp': t.get('timestamp', '')
                }

    # --- Gestion POST (validation / rejet) ---
    if request.method == 'POST':
        withdrawal_id = request.form.get('withdrawal_id')
        action = request.form.get('action')

        if not withdrawal_id:
            flash("Aucun retrait sélectionné.", "warning")
            return redirect(url_for('admin_withdrawals'))

        # Retrouver l’utilisateur concerné
        for email, u in users.items():
            for t in u.get('transactions', []):
                if t['id'] == withdrawal_id:
                    if action == 'validate' and t['status'] == 'En attente':
                        t['status'] = 'Validé'
                        u.setdefault('mon_historique', []).append({
                            'date': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
                            'description': 'Retrait validé (admin)',
                            'montant': -float(t['amount']),
                            'status': 'Validé'
                        })
                        flash(f"Retrait {withdrawal_id} validé.", "success")
                    elif action == 'reject' and t['status'] == 'En attente':
                        t['status'] = 'Rejeté'
                        flash(f"Retrait {withdrawal_id} rejeté.", "info")
                    save_users_data(users)
                    return redirect(url_for('admin_withdrawals'))

        flash("Retrait introuvable.", "error")
        return redirect(url_for('admin_withdrawals'))

    # Tri par date décroissante
    sorted_withdrawals = dict(sorted(withdrawals.items(), key=lambda kv: kv[1].get('timestamp', ''), reverse=True))

    return render_template('admin_withdrawals.html', withdrawals=sorted_withdrawals)

@app.route('/historique')
def historique_page():
    """Affiche l'historique des transactions de l'utilisateur actuel (ou de l'invité)."""

    user_email = get_logged_in_user_email()
    all_users_data = load_users_data()

    user_data = None
    if user_email:
        user_data = all_users_data.get(user_email)

    if user_data is None:
        user_data = {
            'username': 'Invité',
            'balance': 0.0,
            'mon_historique': [] # L'historique des invités est vide
        }

    user_history = user_data.get('mon_historique', [])

    try:
        # Tente de trier l'historique par date
        # Assurez-vous que le format de date ('%d-%m-%Y %H:%M:%S') correspond à celui utilisé à l'enregistrem>
        user_history.sort(key=lambda x: datetime.strptime(x['date'], '%d-%m-%Y %H:%M:%S'), reverse=True)
    except Exception as e:
        print(f"Avertissement: Erreur de tri de l'historique: {e}")
        pass

    return render_template('mon-historique.html', user_history=user_history, user_info=user_data)

INVESTMENT_PLANS = {
    "plan_60_jours": {
        "VIP1": {"investissement": 3000, "gain_quotidien": 300, "duree_jours": 60},
        "VIP2": {"investissement": 9000, "gain_quotidien": 900, "duree_jours": 60},
        "VIP3": {"investissement": 15000, "gain_quotidien": 1500, "duree_jours": 60},
        "VIP4": {"investissement": 30000, "gain_quotidien": 3000, "duree_jours": 60},
        "VIP5": {"investissement": 90000, "gain_quotidien": 9000, "duree_jours": 60},
        "VIP6": {"investissement": 150000, "gain_quotidien": 15000, "duree_jours": 60},
        "VIP7": {"investissement": 300000, "gain_quotidien": 30000, "duree_jours": 60},
        "VIP8": {"investissement": 900000, "gain_quotidien": 90000, "duree_jours": 60},
    },
    "plan_bien_etre": {
        "VIP1": {"investissement": 3000, "gain_total": 18000, "duree_jours": 30},
        "VIP2": {"investissement": 9000, "gain_total": 54000, "duree_jours": 30},
        "VIP3": {"investissement": 25000, "gain_total": 150000, "duree_jours": 30},
        "VIP4": {"investissement": 45000, "gain_total": 270000, "duree_jours": 30},
    }
}

@app.route('/investi', methods=['GET', 'POST'])
def investi_page():
    email = get_logged_in_user_email()
    if not email:
        flash("Veuillez vous connecter pour investir.", "error")
        return redirect(url_for('connexion'))

    # Charge toutes les données utilisateurs
    users_data = load_users_data()
    user = users_data.get(email)
    if not user:
        flash("Utilisateur introuvable.", "error")
        return redirect(url_for('connexion'))

    current_solde = user.get('balance', 0.0)
    message = None

    if request.method == 'POST':
        plan_id = request.form.get('plan_id')
        try:
            plan_parts = plan_id.split('_')
            vip_level = plan_parts[-1]
            plan_type = "_".join(plan_parts[:-1])
            plan = INVESTMENT_PLANS[plan_type][vip_level]
            cost = plan['investissement']
        except:
            message = {"type": "error", "text": "Plan invalide."}
            return render_template('investi.html', plans=INVESTMENT_PLANS, user_solde=current_solde, message=message)

        if current_solde < cost:
            message = {"type": "error", "text": f"Solde insuffisant. Vous avez besoin de {cost} XOF."}
        else:
            # Débite le solde
            user['balance'] = round(current_solde - cost, 2)

            # Crée l'investissement
            new_investment = {
                "id": str(uuid.uuid4()),
                "plan_id": plan_id,
                "cout": cost,
                "date_debut": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
                "date_fin": (datetime.now() + timedelta(days=plan['duree_jours'])).strftime("%Y-%m-%d %H:%M:%S"),
                "statut": "actif",
                "gain_quotidien": plan.get('gain_quotidien', 0),
                "gain_total": plan.get('gain_total', 0)
            }

            user.setdefault('investments', []).append(new_investment)

            # Ajoute l'historique
            timestamp = datetime.now().strftime('%d-%m-%Y %H:%M:%S')
            user.setdefault('mon_historique', []).append({
                'date': timestamp,
                'description': f"Investissement {vip_level} ({plan_type})",
                'montant': -cost,
                'solde_apres': user['balance'],
                'status': 'réussi'
            })

            # Sauvegarde les données
            users_data[email] = user
            save_users_data(users_data)

            # Redirection vers confirmation
            return redirect(url_for('invest_confirm', investment_id=new_investment['id']))

    return render_template('investi.html', plans=INVESTMENT_PLANS, user_solde=current_solde, message=message)

@app.route('/invest_confirm/<investment_id>')
def invest_confirm(investment_id):
    email = get_logged_in_user_email()
    if not email:
        flash("Veuillez vous connecter.", "error")
        return redirect(url_for('connexion'))

    # Charger toutes les données utilisateurs
    users_data = load_users_data()

    # Récupérer l'utilisateur correspondant à l'email
    user = users_data.get(email)

    if not user:
        flash("Utilisateur introuvable.", "error")
        return redirect(url_for('connexion'))

    # Rechercher l'investissement correspondant
    investment = next((i for i in user.get('investments', []) if i['id'] == investment_id), None)

    if not investment:
        flash("Investissement introuvable.", "error")
        return redirect(url_for('investi_page'))

    # Rendre la page de confirmation
    return render_template('invest_confirm.html', investment=investment, user=user)

@app.route('/invest_validate/<investment_id>', methods=['POST'])
def invest_validate(investment_id):
    email = get_logged_in_user_email()
    if not email:
        flash("Veuillez vous connecter.", "error")
        return redirect(url_for('connexion'))

    users_data = load_users_data()
    user = users_data.get(email)

    if not user:
        flash("Utilisateur introuvable.", "error")
        return redirect(url_for('connexion'))

    # Trouver l'investissement à confirmer
    investment = next((i for i in user.get('investments', []) if i['id'] == investment_id), None)
    if not investment:
        flash("Investissement introuvable.", "error")
        return redirect(url_for('investi_page'))

    # Mettre à jour le statut et enregistrer dans l’historique
    investment['statut'] = 'Confirmé'
    if 'historique' not in user:
        user['historique'] = []
    user['historique'].append(investment)

    save_users_data(users_data)

    flash("Votre investissement a été confirmé et ajouté à votre historique ✅", "success")
    return redirect(url_for('dashboard_page'))

@app.route('/referral')
def referral_page():
    """Affiche la page de parrainage avec lien et liste des filleuls."""
    import datetime
    from flask import request

    user_email = get_logged_in_user_email()
    users_data = load_users_data()

    # --- Vérification utilisateur connecté ---
    if not user_email or user_email not in users_data:
        return render_template(
            'referral.html',
            referral_link=None,
            filleuls=[],
            message="Veuillez vous connecter pour accéder à votre lien de parrainage."
        )

    user_info = users_data[user_email]
    username = user_info.get('username', user_email.split('@')[0])

    # --- Génération du lien de parrainage ---
    referral_code = username
    referral_link = f"{request.url_root}inscription?ref={referral_code}"
    referral_link = referral_link.replace("http://", "https://")

    filleuls = []
    now = datetime.datetime.now()

    # --- Recherche des filleuls dans users.json ---
    for email, data in users_data.items():
        if data.get('parrain') == referral_code:  # Le filleul a ce parrain
            filleul_nom = data.get('username', email)
            total_depot = 0
            has_first_deposit = data.get('has_made_first_deposit', False)

            # --- Vérifier s'il a un dépôt validé ---
            for tx in data.get('deposits', []):
                if tx.get('status', '').lower() in ['validé', 'valide'] and tx.get('amount', 0) > 0:
                    total_depot += tx.get('amount', 0)

                    # --- Créditer 30% au parrain sur le premier dépôt ---
                    if not has_first_deposit:
                        commission = tx.get('amount', 0) * 0.3
                        user_info['balance'] = user_info.get('balance', 0) + commission
                        user_info.setdefault('mon_historique', []).append({
                            "date": now.strftime("%d-%m-%Y %H:%M:%S"),
                            "description": f"Commission de parrainage (30%) sur le dépôt de {filleul_nom}",
                            "montant": commission,
                            "type": "credit",
                            "status": "Validé",
                            "solde_apres": user_info['balance']
                        })
                        data['has_made_first_deposit'] = True

                        print(f"Commission de {commission} XOF ajoutée à {username} pour le filleul {filleul_nom}")
                        break

            filleuls.append({
                "nom": filleul_nom,
                "email": email,
                "total_depot": total_depot
            })

    # --- Sauvegarde après mise à jour des commissions ---
    save_users_data(users_data)

    return render_template(
        'referral.html',
        referral_link=referral_link,
        filleuls=filleuls,
        user_info=user_info
    )

@app.route('/tasks', methods=['GET', 'POST'])
def tasks_page():
    """Gère la réclamation du bonus quotidien (Route publique)."""

    user_email = get_logged_in_user_email()
    users_data = load_users_data()
    user_info = users_data.get(user_email)

    message = None
    BONUS_AMOUNT = 50.00 # Montant du bonus quotidien en XOF

    if user_info is None:
        current_solde = 0.00
        bonus_claimed_today = True # Un invité est toujours considéré comme ayant réclamé (ou ne pouvant pas réclamer)
        message = {"type": "error", "text": "Veuillez vous connecter pour réclamer votre Bonus Quotidien."}
    else:
        current_solde = user_info.get('balance', 0.00)

        today_str = datetime.today().strftime("%Y-%m-%d")
        last_bonus_date = user_info.get('last_bonus_date', '2000-01-01')

        bonus_claimed_today = (last_bonus_date == today_str)

    if request.method == 'POST' and user_info:
        if not bonus_claimed_today:

            user_info['balance'] = round(user_info['balance'] + BONUS_AMOUNT, 2)
            user_info['last_bonus_date'] = today_str
            transaction = {
                "date": datetime.today().strftime("%d-%m-%Y %H:%M:%S"), # Format ajusté pour la compatibilité
                "description": "Bonus Quotidien réclamé",
                "montant": BONUS_AMOUNT,
                "type": "credit", # Ajout du type pour clarification dans l'historique
                "status": "Validé",
                "solde_apres": user_info['balance']
            }
            user_info.setdefault('mon_historique', []).append(transaction)
            users_data[user_email] = user_info
            save_users_data(users_data)

            current_solde = user_info['balance']
            bonus_claimed_today = True

            message = {"type": "success", "text": f"Félicitations ! Vous avez reçu {BONUS_AMOUNT} XOF de Bonus Quotidien."}
        else:
            message = {"type": "error", "text": "Vous avez déjà réclamé votre Bonus Quotidien pour aujourd'hui."}

    return render_template('tasks.html',
                           user_solde=current_solde,
                           message=message,
                           bonus_claimed_today=bonus_claimed_today,
                           bonus_amount=BONUS_AMOUNT)

if __name__ == '__main__':
    if not os.path.exists(USERS_FILE):
        with open(USERS_FILE, 'w') as f:
            json.dump({}, f)

    app.run(debug=True, port=8080)
