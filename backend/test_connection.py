import psycopg2

try:
    conn = psycopg2.connect(
        host="aws-0-ap-southeast-1.pooler.supabase.com",
        database="postgres", 
        user="postgres.mccdwczueketpqlbobyw",
        password="ayomagang12345",
        port="5432"
    )
    print("Koneksi berhasil!")
    conn.close()
except Exception as e:
    print(f"Error: {e}")