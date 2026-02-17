import os
import csv
import gzip
import io
import requests
import psycopg2
from psycopg2.extras import execute_values
# ======================================================
# CONFIG
# =======================================================balbalblalblablaejrejhrejhrejhrjehr
BATCH_SIZE = 10_000  # copy in grote chunks
TEST_LIMIT = None     # zet bv 10_000 voor testen

IMDB = "https://datasets.imdbws.com"
URLS = {
    "titles": f"{IMDB}/title.basics.tsv.gz",
    "akas": f"{IMDB}/title.akas.tsv.gz",
    "crew": f"{IMDB}/title.crew.tsv.gz",
    "episodes": f"{IMDB}/title.episode.tsv.gz",
    "principals": f"{IMDB}/title.principals.tsv.gz",
    "ratings": f"{IMDB}/title.ratings.tsv.gz",
    "names": f"{IMDB}/name.basics.tsv.gz",
}

# ======================================================werkt het Burak?
# DATABASE CONNECTIE
# ======================================================
def connect_db():
    conn = psycopg2.connect(
        host=os.environ["DB_HOST"],
        dbname=os.environ["DB_NAME"],
        user=os.environ["DB_USER"],
        password=os.environ["DB_PASSWORD"],
        port=os.environ.get("DB_PORT", 5432),
    )
    with conn.cursor() as cur:
        cur.execute("SET statement_timeout = '10min';")
    conn.commit()
    return conn


# ======================================================
# STREAM HELPER
# ======================================================
def imdb_reader(url):
    print(f"⬇️ Streaming {url.split('/')[-1]}")
    r = requests.get(url, stream=True)
    r.raise_for_status()
    gz = gzip.GzipFile(fileobj=r.raw)
    return csv.DictReader(io.TextIOWrapper(gz, encoding="utf-8"), delimiter="\t")

def none(val):
    return None if val == "\\N" else val

# ======================================================
# COPY HELPER (FAST IMPORT)
# ======================================================
def copy_to_table(conn, table, columns, rows):
    buffer = io.StringIO()
    writer = csv.writer(buffer, delimiter="\t", quoting=csv.QUOTE_MINIMAL)

    for row in rows:
        writer.writerow([
            "" if v is None else (
                "{" + ",".join(v) + "}" if isinstance(v, list) else v
            )
            for v in row
        ])

    buffer.seek(0)
    with conn.cursor() as cur:
        cur.copy_from(buffer, table, columns=columns, sep="\t", null="")
    conn.commit()

# ======================================================
# IMPORTERS
# ======================================================

def clean_text(val):
    if val is None:
        return None
    return val.replace("\t", " ").replace("\n", " ").replace("\r", " ")

def safe_int(val):
    try:
        return int(val)
    except (TypeError, ValueError):
        return None


def insert_titles_batch(conn, rows):
    if not rows:
        return
    cols = ("tconst","title_type","primary_title","original_title",
            "is_adult","start_year","end_year","runtime_minutes","genres")
    q = f"INSERT INTO titles ({', '.join(cols)}) VALUES %s ON CONFLICT DO NOTHING"
    with conn.cursor() as cur:
        execute_values(cur, q, rows, page_size=1000)


def import_titles():
    conn = connect_db()

    buffer, count, kept = [], 0, 0
    for r in imdb_reader(URLS["titles"]):
        title_type = r["titleType"]
        start_year = safe_int(r.get("startYear"))
        runtime = safe_int(r.get("runtimeMinutes"))
        is_adult = r.get("isAdult") == "1"

        # ❌ Filters
        if title_type not in ("movie", "tvSeries", "tvMiniSeries"):
            continue
        if start_year is None or start_year < 1980:
            continue
        if runtime is None:
            continue
        if is_adult:  # optioneel
            continue

        buffer.append((
            r["tconst"],
            title_type,
            clean_text(r.get("primaryTitle")),
            clean_text(r.get("originalTitle")),
            False,
            start_year,
            safe_int(r.get("endYear")),
            runtime,
            None if not r.get("genres") or r["genres"] == "\\N" else r["genres"].split(",")
        ))

        count += 1
        kept += 1

        if len(buffer) >= BATCH_SIZE:
            insert_titles_batch(conn, buffer)
            conn.commit()
            print(f"🎬 titles inserted: {kept} / processed: {count}")
            buffer.clear()

        if TEST_LIMIT and count >= TEST_LIMIT:
            break

    if buffer:
        insert_titles_batch(conn, buffer)
        conn.commit()
        print(f"🎬 titles inserted: {kept} / processed: {count} (final batch)")

    conn.close()



def import_ratings():
    conn = connect_db()
    staging = "title_ratings_staging"
    with conn.cursor() as cur:
        cur.execute(f"TRUNCATE {staging};")
        conn.commit()

    buffer = []
    for r in imdb_reader(URLS["ratings"]):
        num_votes = int(r["numVotes"])
        if num_votes < 100:
            continue
        buffer.append((
            r["tconst"],
            float(r["averageRating"]),
            num_votes,
        ))

        if len(buffer) >= BATCH_SIZE:
            copy_to_table(conn, staging, ["tconst","average_rating","num_votes"], buffer)
            buffer.clear()
    if buffer:
        copy_to_table(conn, staging, ["tconst","average_rating","num_votes"], buffer)

    with conn.cursor() as cur:
        cur.execute(f"""
        INSERT INTO title_ratings
        SELECT * FROM {staging}
        ON CONFLICT (tconst) DO UPDATE SET
          average_rating = EXCLUDED.average_rating,
          num_votes = EXCLUDED.num_votes;
        """)
        conn.commit()
    conn.close()

def get_allowed_tconsts(conn):
    with conn.cursor() as cur:
        cur.execute("SELECT tconst FROM titles;")
        return {row[0] for row in cur.fetchall()}


def import_names():
    conn = connect_db()
    staging = "names_staging"
    with conn.cursor() as cur:
        cur.execute(f"TRUNCATE {staging};")
        conn.commit()

    allowed_tconsts = get_allowed_tconsts(conn)
    buffer = []
    for r in imdb_reader(URLS["names"]):
        known_for = r["knownForTitles"]
        if known_for == "\\N":
            continue
        if not any(t in allowed_tconsts for t in known_for.split(",")):
            continue
        buffer.append((
            r["nconst"],
            r["primaryName"],
            none(r["birthYear"]),
            none(r["deathYear"]),
            None if r["primaryProfession"] == "\\N" else r["primaryProfession"].split(","),
            known_for.split(","),
        ))
        if len(buffer) >= BATCH_SIZE:
            copy_to_table(conn, staging,
                          ["nconst","primary_name","birth_year","death_year",
                           "primary_profession","known_for_titles"],
                          buffer)
            buffer.clear()

    if buffer:  # final batch
        copy_to_table(conn, staging,
                      ["nconst","primary_name","birth_year","death_year",
                       "primary_profession","known_for_titles"],
                      buffer)

    with conn.cursor() as cur:
        cur.execute(f"""
        INSERT INTO names
        SELECT * FROM {staging}
        ON CONFLICT (nconst) DO UPDATE SET
          primary_name = EXCLUDED.primary_name;
        """)
        conn.commit()
    conn.close()

def import_simple_table(url_key, table, columns, allowed_tconsts=None, convert_funcs=None, col_map=None):
    """Generic importer voor akas, crew, principals — filtert op allowed_tconsts indien meegegeven."""
    conn = connect_db()
    buffer = []
    count = 0
    for r in imdb_reader(URLS[url_key]):
        # Filter op tconst/titleId wanneer allowed_tconsts is opgegeven
        key_tconst = r.get("tconst") or r.get("titleId")
        if allowed_tconsts is not None and key_tconst not in allowed_tconsts:
            continue

        row = []
        for col in columns:
            source_col = col_map[col] if col_map and col in col_map else col
            val = r.get(source_col)
            if convert_funcs and col in convert_funcs:
                val = convert_funcs[col](val)
            else:
                val = None if val == "\\N" else val
            row.append(val)
        buffer.append(tuple(row))
        count += 1

        if len(buffer) >= BATCH_SIZE:
            copy_to_table(conn, table, columns, buffer)
            buffer.clear()
        if TEST_LIMIT and count >= TEST_LIMIT:
            break

    if buffer:
        copy_to_table(conn, table, columns, buffer)
    conn.close()


def import_all_simple():
    # akas
    import_simple_table(
        "akas",
        "title_akas",
        ["tconst","ordering","title","region","language","types","attributes","isOriginalTitle"],
        convert_funcs={
            "types": lambda x: None if x=="\\N" else x.split(","),
            "attributes": lambda x: None if x=="\\N" else x.split(","),
            "ordering": int,
            "isOriginalTitle": lambda x: x=="1"
        }
    )
    # crew
    import_simple_table(
        "crew",
        "title_crew",
        ["tconst","directors","writers"],
        convert_funcs={
            "directors": lambda x: None if x=="\\N" else x.split(","),
            "writers": lambda x: None if x=="\\N" else x.split(","),
        }
    )
    # principals
    import_simple_table(
        "principals",
        "title_principals",
        ["tconst","ordering","nconst","category","job","characters"],
        convert_funcs={
            "ordering": int,
            "job": lambda x: None if x=="\\N" else x,
            "characters": lambda x: None if x=="\\N" else x,
        }
    )


# ======================================================
# MAIN
# ======================================================
# ======================================================
# MAIN
# ======================================================
if __name__ == "__main__":
    print("🔌 Connecting to Supabase...")
    connect_db().close()
    print("✅ Connected\n")

    # 1️⃣ Eerst de basis-titels
    import_titles()

    # 2️⃣ Haal de set van toegestane tconsts op uit titles
    conn = connect_db()
    allowed_tconsts = get_allowed_tconsts(conn)
    conn.close()

    # 3️⃣ Daarna alles wat afhankelijk is van titles
    # akas
# akas: map db-kolom tconst -> bestand-kolom titleId
    import_simple_table(
        "akas",
        "title_akas",
        ["tconst","ordering","title","region","language","types","attributes","isOriginalTitle"],
        allowed_tconsts=allowed_tconsts,
        convert_funcs={
            "types": lambda x: None if x=="\\N" else x.split(","),
            "attributes": lambda x: None if x=="\\N" else x.split(","),
            "ordering": int,
            "isOriginalTitle": lambda x: x=="1"
        },
        col_map={
            "tconst": "titleId"   # <-- belangrijke mapping
        }
    )


    # crew
    import_simple_table(
        "crew",
        "title_crew",
        ["tconst","directors","writers"],
        allowed_tconsts=allowed_tconsts,
        convert_funcs={
            "directors": lambda x: None if x=="\\N" else x.split(","),
            "writers": lambda x: None if x=="\\N" else x.split(","),
        }
    )
    # principals
    import_simple_table(
        "principals",
        "title_principals",
        ["tconst","ordering","nconst","category","job","characters"],
        allowed_tconsts=allowed_tconsts,
        convert_funcs={
            "ordering": int,
            "job": lambda x: None if x=="\\N" else x,
            "characters": lambda x: None if x=="\\N" else x,
        }
    )

    # 4️⃣ Ratings
    import_ratings()

    # 5️⃣ Namen (alleen die gekoppeld zijn aan geïmporteerde tconsts)
    import_names()

    print("\n🎉 IMDb FULL IMPORT COMPLETED")
