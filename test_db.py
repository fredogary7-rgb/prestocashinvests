import psycopg

# ⚡ Remplace par tes infos exactes
DBNAME = "presto_admin"
USER = "presto_admin_user"
PASSWORD = "j7C6is6xvR3EsV4dG6ph4Ju7NWUMurou"
HOST = "dpg-d45j4kf5r7bs73ajiq20-a.oregon-postgres.render.com"

try:
    # Connexion à la base
    conn = psycopg.connect(
        dbname=DBNAME,
        user=USER,
        password=PASSWORD,
        host=HOST
    )
    cur = conn.cursor()
    
    # Test simple : récupérer la date actuelle
    cur.execute("SELECT NOW();")
    result = cur.fetchone()
    print("Connexion réussie ! Heure actuelle DB :", result[0])
    
    cur.close()
    conn.close()
except Exception as e:
    print("Erreur de connexion :", e)
