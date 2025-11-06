import os
import smtplib
import subprocess
from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email import encoders
from datetime import datetime

# --- Configuration ---
DB_URL = "postgresql://presto_admin_user:j7C6is6xvR3EsV4dG6ph4Ju7NWUMurou@dpg-d45j4kf5r7bs73ajiq20-a.oregon-postgres.render.com/presto_admin"

EMAIL_SENDER = "prestocashfinance0@gmail.com"
EMAIL_PASSWORD = "oggx xwkb akyr xgtq"  # ton mot de passe d'application Gmail
EMAIL_RECEIVER = "prestocashfinance0@gmail.com"  # l’adresse où tu veux recevoir le backup

# --- Nom du fichier ---
backup_name = f"backup_presto_{datetime.now().strftime('%Y-%m-%d_%H-%M-%S')}.sql"
compressed_backup = f"{backup_name}.gz"

# --- Étape 1 : Créer un dump PostgreSQL ---
print("📦 Sauvegarde de la base de données en cours...")
os.system(f"pg_dump {DB_URL} > {backup_name}")

# --- Étape 2 : Compresser le fichier ---
os.system(f"gzip {backup_name}")
print(f"✅ Sauvegarde compressée : {compressed_backup}")

# --- Étape 3 : Envoi par e-mail ---
msg = MIMEMultipart()
msg["From"] = EMAIL_SENDER
msg["To"] = EMAIL_RECEIVER
msg["Subject"] = f"Backup PRESTO CASH - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"

part = MIMEBase("application", "octet-stream")
with open(compressed_backup, "rb") as file:
    part.set_payload(file.read())
encoders.encode_base64(part)
part.add_header("Content-Disposition", f"attachment; filename={compressed_backup}")
msg.attach(part)

try:
    server = smtplib.SMTP("smtp.gmail.com", 587)
    server.starttls()
    server.login(EMAIL_SENDER, EMAIL_PASSWORD)
    server.send_message(msg)
    server.quit()
    print("📧 Backup envoyé avec succès à ton adresse Gmail !")
except Exception as e:
    print("❌ Erreur lors de l’envoi du mail :", e)

# --- Étape 4 : Nettoyage local ---
os.remove(compressed_backup)
print("🧹 Fichier temporaire supprimé.")
