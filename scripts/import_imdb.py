# import os
# import csv
# import gzip
# import io

# import requests
# import psycopg2
# import sys
# from psycopg2.extras import execute_values

# # Verhoog CSV veld grootte limiet
# csv.field_size_limit(sys.maxsize)

# # ======================================================
# # CONFIG
# # =======================================================
# # Aantal rijen per batch bij COPY operaties
# BATCH_SIZE = 10_000
# # Test limiet: zet bv 10_000 om slechts 10k rijen te importeren (None = alles)
# TEST_LIMIT = None

# # IMDb dataset URLs
# IMDB = "https://datasets.imdbws.com"
# URLS = {
#     "titles": f"{IMDB}/title.basics.tsv.gz",      # Film/Serie basis info
#     "ratings": f"{IMDB}/title.ratings.tsv.gz",    # Rating data
# }

# # ======================================================
# # DATABASE CONNECTIE
# # ======================================================
# def connect_db():
#     """Maak verbinding met PostgreSQL database via omgevingsvariabelen."""
#     conn = psycopg2.connect(
#         host=os.environ["DB_HOST"],
#         dbname=os.environ["DB_NAME"],
#         user=os.environ["DB_USER"],
#         password=os.environ["DB_PASSWORD"],
#         port=os.environ.get("DB_PORT", 5432),
#     )
#     # Zet timeout op 10 minuten voor query's
#     with conn.cursor() as cur:
#         cur.execute("SET statement_timeout = '10min';")
#     conn.commit()
#     return conn


# # ======================================================
# # STREAM HELPER
# # ======================================================
# def imdb_reader(url):
#     """Stream gecomprimeerde TSV bestand van IMDb als CSV DictReader."""
#     print(f"⬇️ Streaming {url.split('/')[-1]}")
#     r = requests.get(url, stream=True)
#     r.raise_for_status()
#     gz = gzip.GzipFile(fileobj=r.raw)
#     return csv.DictReader(io.TextIOWrapper(gz, encoding="utf-8"), delimiter="\t")

# def none(val):
#     """Converteer IMDb 'null' waarde (\\N) naar Python None."""
#     return None if val == "\\N" else val

# # ======================================================
# # COPY HELPER (FAST IMPORT)
# # ======================================================
# def copy_to_table(conn, table, columns, rows):
#     """Snelle bulk import naar PostgreSQL met COPY commando."""
#     buffer = io.StringIO()

#     def _escape_text(s: str) -> str:
#         """Escape speciale karakters voor COPY format."""
#         # Backslashes eerst, dan newlines en carriage returns
#         return s.replace("\\", "\\\\").replace("\n", "\\n").replace("\r", "\\r").replace("\t", " ")

#     for row in rows:
#         out_fields = []
#         for v in row:
#             if v is None:
#                 # NULL waarden worden als leeg gerepresenteerd
#                 out_fields.append("")
#             elif isinstance(v, list):
#                 # Array elementen hebben dubbele escaping nodig
#                 # 1. Escape voor array parser
#                 # 2. Escape voor COPY parser
#                 escaped_items = []
#                 for item in v:
#                     s = str(item)
#                     # Escape voor array parser
#                     s = s.replace('\\', '\\\\').replace('"', '\\"')
#                     # Wrap in quotes
#                     s = f'"{s}"'
#                     # Escape voor COPY parser
#                     s = s.replace('\\', '\\\\')
#                     escaped_items.append(s)
#                 out_fields.append("{" + ",".join(escaped_items) + "}")
#             else:
#                 out_fields.append(_escape_text(str(v)))

#         buffer.write("\t".join(out_fields) + "\n")

#     # Lees buffer en voer COPY uit
#     buffer.seek(0)
#     with conn.cursor() as cur:
#         cur.copy_from(buffer, table, columns=columns, sep="\t", null="")
#     conn.commit()

# # ======================================================
# # IMPORTERS
# # ======================================================

# def clean_text(val):
#     """Verwijder tabs, newlines en carriage returns uit tekst."""
#     if val is None:
#         return None
#     return val.replace("\t", " ").replace("\n", " ").replace("\r", " ")

# def safe_int(val):
#     """Converteer veilig naar integer, retourneer None bij fout."""
#     try:
#         return int(val)
#     except (TypeError, ValueError):
#         return None


# def insert_titles_batch(conn, rows):
#     """Voeg batch van titels in, skip duplicaten."""
#     if not rows:
#         return
#     cols = ("tconst","title_type","primary_title", "start_year","end_year","runtime_minutes","genres")
#     q = f"INSERT INTO titles ({', '.join(cols)}) VALUES %s ON CONFLICT DO NOTHING"
#     with conn.cursor() as cur:
#         execute_values(cur, q, rows, page_size=1000)



# def import_titles():
#     """Importeer IMDb titels (films en series met filter van na 2000)."""
#     conn = connect_db()

#     # Maak titels tabel aan indien deze niet bestaat
#     with conn.cursor() as cur:
#         cur.execute("""
#             CREATE TABLE IF NOT EXISTS titles (
#                 tconst text PRIMARY KEY,
#                 title_type text,
#                 primary_title text,
#                 start_year integer,
#                 end_year integer,
#                 runtime_minutes integer,
#                 genres text[]
#             );
#         """)
#         conn.commit()

#     buffer, count, kept = [], 0, 0
#     for r in imdb_reader(URLS["titles"]):
#         title_type = r["titleType"]
#         start_year = safe_int(r.get("startYear"))
#         runtime = safe_int(r.get("runtimeMinutes"))
#         is_adult = r.get("isAdult") == "1"

#         # Filters: alleen bepaalde types, alleen na 2000, moet runtime hebben, geen volwassen content
#         if title_type not in ("movie", "tvSeries", "tvMiniSeries"):
#             continue
#         if start_year is None or start_year < 2000:
#             continue
#         if runtime is None:
#             continue
#         if is_adult:
#             continue

#         # Voeg gefilterde rij toe aan buffer
#         buffer.append((
#             r["tconst"],
#             title_type,
#             clean_text(r.get("primaryTitle")),
#             start_year,
#             safe_int(r.get("endYear")),
#             runtime,
#             # Genres als array of None
#             None if not r.get("genres") or r["genres"] == "\\N" else r["genres"].split(",")
#         ))

#         count += 1
#         kept += 1

#         # Voeg batch in als limiet bereikt
#         if len(buffer) >= BATCH_SIZE:
#             insert_titles_batch(conn, buffer)
#             conn.commit()
#             print(f"🎬 titles inserted: {kept} / processed: {count}")
#             buffer.clear()

#         # Stop bij test limiet
#         if TEST_LIMIT and count >= TEST_LIMIT:
#             break

#     # Voeg overgebleven rijen in
#     if buffer:
#         insert_titles_batch(conn, buffer)
#         conn.commit()
#         print(f"🎬 titles inserted: {kept} / processed: {count} (final batch)")

#     conn.close()



# def import_ratings():
#     """Importeer IMDb ratings (met min 100 votes filter)."""
#     conn = connect_db()
#     # Maak tijdelijke tabel voor snelle COPY operatie
#     staging = f"title_ratings_staging_{os.getpid()}"
#     with conn.cursor() as cur:
#         cur.execute(f"""
#             CREATE TEMP TABLE IF NOT EXISTS {staging} (
#                 tconst text PRIMARY KEY,
#                 average_rating numeric,
#                 num_votes integer
#             );
#         """)
#         conn.commit()

#     buffer = []
#     for r in imdb_reader(URLS["ratings"]):
#         num_votes = int(r["numVotes"])
#         # Filter: alleen ratings met minimaal 100 votes
#         if num_votes < 100:
#             continue
#         buffer.append((
#             r["tconst"],
#             float(r["averageRating"]),
#             num_votes,
#         ))

#         # Voeg batch in
#         if len(buffer) >= BATCH_SIZE:
#             copy_to_table(conn, staging, ["tconst","average_rating","num_votes"], buffer)
#             buffer.clear()
#     
#     # Voeg overige rijen in
#     if buffer:
#         copy_to_table(conn, staging, ["tconst","average_rating","num_votes"], buffer)

#     # Maak permanente tabel aan en merge staging data in
#     with conn.cursor() as cur:
#         cur.execute("""
#             CREATE TABLE IF NOT EXISTS title_ratings (
#                 tconst text PRIMARY KEY,
#                 average_rating numeric,
#                 num_votes integer
#             );
#         """)
#         # Upsert: voeg in of update bestaande records
#         cur.execute(f"""
#         INSERT INTO title_ratings (tconst, average_rating, num_votes)
#         SELECT tconst, average_rating, num_votes
#         FROM {staging}
#         ON CONFLICT (tconst) DO UPDATE
#         SET
#         average_rating = EXCLUDED.average_rating,
#         num_votes = EXCLUDED.num_votes;
#         """)
#         conn.commit()

#     conn.close()

# def get_allowed_tconsts(conn):
#     """Haal alle toegestane tconsts op uit titles tabel."""
#     with conn.cursor() as cur:
#         cur.execute("SELECT tconst FROM titles;")
#         return {row[0] for row in cur.fetchall()}



# def import_simple_table(url_key, table, columns, allowed_tconsts=None, convert_funcs=None, col_map=None):
#     """
#     Generieke importer voor extra tabellen.
#     Filtert op allowed_tconsts wanneer meegegeven (voor data consistency).
#     """
#     conn = connect_db()
#     buffer = []
#     count = 0
#     for r in imdb_reader(URLS[url_key]):
#         # Bepaal welke kolom de tconst bevat (verschilt per dataset)
#         key_tconst = r.get("tconst") or r.get("titleId")
#         # Skip rijen niet in allowed_tconsts
#         if allowed_tconsts is not None and key_tconst not in allowed_tconsts:
#             continue

#         row = []
#         for col in columns:
#             # Map kolom naam indien nodig
#             source_col = col_map[col] if col_map and col in col_map else col
#             val = r.get(source_col)
#             # Pas conversie functie toe indien aanwezig
#             if convert_funcs and col in convert_funcs:
#                 val = convert_funcs[col](val)
#             else:
#                 # Converteer IMDb null waarden naar Python None
#                 val = None if val == "\\N" else val
#             row.append(val)
#         buffer.append(tuple(row))
#         count += 1

#         # Voeg batch in
#         if len(buffer) >= BATCH_SIZE:
#             copy_to_table(conn, table, columns, buffer)
#             buffer.clear()
#         # Stop bij test limiet
#         if TEST_LIMIT and count >= TEST_LIMIT:
#             break

#     # Voeg resterende rijen in
#     if buffer:
#         copy_to_table(conn, table, columns, buffer)
#     conn.close()


# # ======================================================
# # MAIN
# # ======================================================
# if __name__ == "__main__":
#     # Test database verbinding
#     print("🔌 Connecting to Supabase...")
#     connect_db().close()
#     print("✅ Connected\n")

#     # 1. Importeer basis titels met filters
#     import_titles()

#     # 2. Haal toegestane tconsts op
#     conn = connect_db()
#     allowed_tconsts = get_allowed_tconsts(conn)
#     conn.close()
#     
#     # 3. Importeer ratings
#     import_ratings()

#     # Done!
#     print("\n🎉 IMDb FULL IMPORT COMPLETED")

