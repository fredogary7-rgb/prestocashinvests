import json
import os
from datetime import datetime, timedelta

from flask import Flask, render_template, request, redirect, url_for, session, jsonify

# --- Configuration et Initialisation ---

app = Flask(__name__)
# Définir une clé secrète pour gérer les sessions (OBLIGATOIRE pour Flask)
# CHANGEZ CECI DANS UNE VRAIE APPLICATION !
app.secret_key = 'super_secret_key_to_be_replaced' 
app.permanent_session_lifetime = timedelta(minutes=30) # Session expire après 30 minutes

USERS_FILE = 'users.json'
REFERRAL_BONUS = 500

# Fonction utilitaire pour charger les données des utilisateurs
def load_users():
    """Charge les données des utilisateurs depuis le fichier JSON."""
    if not os.path.exists(USERS_FILE):
        return {}
    try:
        with open(USERS_FILE, 'r') as f:
            return json.load(f)
    except json.JSONDecodeError:
        return {} # Retourne un dictionnaire vide si le fichier est corrompu

# Fonction utilitaire pour sauvegarder les données des utilisateurs
def save_users(users):
    """Sauvegarde les données des utilisateurs dans le fichier JSON."""
    with open(USERS_FILE, 'w') as f:
        json.dump(users, f, indent=4)

# Décorateur pour vérifier si l'utilisateur est connecté
def login_required(f):
    """Décorateur pour les routes nécessitant une connexion."""
    from functools import wraps
    @wraps(f)
    def decorated_function(*args, **kwargs):
        # Vérifie si l'email est dans la session
        if 'email' not in session:
            return redirect(url_for('connexion_page'))
        return f(*args, **kwargs)
    return decorated_function

# --- Routes d'Affichage des Pages ---

@app.route('/')
@app.route('/connexion')
def connexion_page():
    """Page de connexion."""
    if 'email' in session:
        return redirect(url_for('dashboard_page'))
    return render_template('connexion.html')

@app.route('/inscription')
def inscription_page():
    """Page d'inscription."""
    if 'email' in session:
        return redirect(url_for('dashboard_page'))
    return render_template('inscription.html')

# CORRECTION: Ajout du slash de début à la route comme indiqué par l'erreur dans 980222.png
@app.route('/dashboard')
@login_required
def dashboard_page():
    """Page du tableau de bord. Nécessite une connexion."""
    users = load_users()
    email = session.get('email')
    
    # Vérification que l'email existe dans les données utilisateurs
    user_data = users.get(email)
    
    if user_data is None:
        # Si les données ne sont pas trouvées (fichier users.json modifié)
        session.pop('email', None)
        return redirect(url_for('connexion_page'))

    # Les erreurs précédentes venaient du fait que 'user_data' n'était pas un dict complet.
    # On s'assure qu'il est complet avant de le passer au template.
    # Correction de l'erreur 'balance' / 'UndefinedError' (976283.png)
    return render_template('dashboard.html', user_data=user_data)


@app.route('/deposit')
@login_required
def deposit_page():
    """Page de dépôt."""
    users = load_users()
    email = session.get('email')
    user_data = users.get(email, {})
    return render_template('deposit.html', user_data=user_data)


@app.route('/withdrawal')
@login_required
def withdrawal_page():
    """Page de retrait."""
    users = load_users()
    email = session.get('email')
    user_data = users.get(email, {})
    return render_template('withdrawal.html', user_data=user_data)


@app.route('/equipe')
@login_required
def equipe_page():
    """Page de l'équipe (parrainage)."""
    users = load_users()
    email = session.get('email')
    user_data = users.get(email, {})
    return render_template('parrainage.html', user_data=user_data) # Supposons que tu as un template parrainage.html


@app.route('/gains')
@login_required
def gains_page():
    """Page des gains."""
    users = load_users()
    email = session.get('email')
    user_data = users.get(email, {})
    return render_template('gains.html', user_data=user_data) # Supposons que tu as un template gains.html


@app.route('/logout')
def logout_page():
    """Déconnecte l'utilisateur."""
    # Correction de l'erreur 'BuildError: Could not build url for endpoint 'handle_logout'.' (978401.png)
    session.pop('email', None) 
    return redirect(url_for('connexion_page'))

# --- Routes API pour la logique (POST) ---

@app.route('/api/register', methods=['POST'])
def handle_register():
    """Gère l'inscription d'un nouvel utilisateur."""
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')
    username = data.get('username')
    phone = data.get('phone')
    referral_code = data.get('referral_code')
    
    users = load_users()

    if email in users:
        return jsonify({'success': False, 'message': 'Cet email est déjà enregistré.'}), 409

    # Créer un code de parrainage simple (peut être amélioré)
    new_referral_code = os.urandom(4).hex().upper() 

    # Initialisation des données de l'utilisateur
    users[email] = {
        'password': password, # Idéalement, hacher le mot de passe
        'username': username,
        'phone': phone,
        'balance': 0.0, # Assurez-vous que le champ 'balance' existe
        'referral_code': new_referral_code,
        'referred_by': None,
        'transactions': []
    }

    # Logique de parrainage
    if referral_code:
        referrer_found = False
        for user_email, user_data in users.items():
            if user_data.get('referral_code') == referral_code:
                # Appliquer le bonus à celui qui parraine
                user_data['balance'] += REFERRAL_BONUS
                # Enregistrer qui a parrainé le nouvel utilisateur
                users[email]['referred_by'] = user_email
                referrer_found = True
                break
        
        if not referrer_found:
             # Si le code est invalide, on ne bloque pas l'inscription, on l'ignore.
             print(f"Code de parrainage invalide: {referral_code}")


    save_users(users)
    
    # Connexion automatique après inscription
    session.permanent = True
    session['email'] = email
    
    return jsonify({'success': True, 'redirect': url_for('dashboard_page')})


@app.route('/api/connexion', methods=['POST'])
def handle_connexion():
    """Gère la tentative de connexion d'un utilisateur."""
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')
    
    users = load_users()
    user_data = users.get(email)

    if user_data and user_data['password'] == password: # Comparaison du mot de passe (non sécurisé)
        session.permanent = True
        session['email'] = email
        return jsonify({'success': True, 'redirect': url_for('dashboard_page')})
    else:
        # Correction de l'erreur de connexion dans 978115.png et Screenshot_20251010-184717.png
        return jsonify({'success': False, 'message': 'Email ou mot de passe incorrect.'}), 401

@app.route('/api/deposit', methods=['POST'])
@login_required
def handle_deposit():
    """Gère un nouveau dépôt."""
    data = request.get_json()
    amount = float(data.get('amount', 0))
    method = data.get('method')
    sender_phone = data.get('sender_phone')
    reference = data.get('reference')
    proof_url = data.get('proof_url')
    
    if amount <= 0:
        return jsonify({'success': False, 'message': 'Montant invalide.'}), 400

    users = load_users()
    email = session.get('email')
    user_data = users.get(email)

    if user_data is None:
        return jsonify({'success': False, 'message': 'Utilisateur non trouvé.'}), 404

    # Générer un ID unique pour la transaction
    import uuid
    transaction_id = str(uuid.uuid4())

    new_transaction = {
        'id': transaction_id,
        'user': email,
        'amount': amount,
        'method': method,
        'sender_phone': sender_phone,
        'reference': reference,
        'proof_url': proof_url,
        'status': 'Pending Verification', # Les dépôts doivent être vérifiés manuellement
        'timestamp': datetime.now().isoformat()
    }
    
    user_data['transactions'].append(new_transaction)
    
    # Note : Le solde n'est pas mis à jour ici car le statut est "Pending Verification"
    
    save_users(users)
    
    return jsonify({'success': True, 'message': 'Dépôt soumis. En attente de vérification.', 'transaction_id': transaction_id})

# --- Démarrage de l'Application ---
if __name__ == '__main__':
    # Initialisation pour s'assurer qu'il y a un users.json
    if not os.path.exists(USERS_FILE):
        save_users({})
        
    # Le port 8080 est couramment utilisé dans Termux
    app.run(debug=True, host='0.0.0.0', port=8080)
