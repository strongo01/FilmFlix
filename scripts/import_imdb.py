import os
import csv
import gzip
import io
import requests
import psycopg2
import sys
from psycopg2.extras import execute_values

csv.field_size_limit(sys.maxsize)
# ======================================================
# CONFIG
# =======================================================
BATCH_SIZE = 10_000  # copy in grote chunks
TEST_LIMIT = None     # zet bv 10_000 voor testen
ROLE_ACTOR = 1
ROLE_DIRECTOR = 2

IMDB = "https://datasets.imdbws.com"
URLS = {
    "titles": f"{IMDB}/title.basics.tsv.gz",
    #"akas": f"{IMDB}/title.akas.tsv.gz",
    "crew": f"{IMDB}/title.crew.tsv.gz",
    "episodes": f"{IMDB}/title.episode.tsv.gz",
    "principals": f"{IMDB}/title.principals.tsv.gz",
    "ratings": f"{IMDB}/title.ratings.tsv.gz",
    "names": f"{IMDB}/name.basics.tsv.gz",
}

# ======================================================
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

    def _escape_text(s: str) -> str:
        # Escape backslashes first, then newlines and carriage returns.
        return s.replace("\\", "\\\\").replace("\n", "\\n").replace("\r", "\\r").replace("\t", " ")

    for row in rows:
        out_fields = []
        for v in row:
            if v is None:
                out_fields.append("")
            elif isinstance(v, list):
                # Array strings in COPY need double escaping:
                # 1. Backslash/Quote must be escaped for the Array parser (e.g. " -> \")
                # 2. THEN that whole thing must be escaped for the COPY parser (e.g. \ -> \\)
                escaped_items = []
                for item in v:
                    s = str(item)
                    # Escape for array parser
                    s = s.replace('\\', '\\\\').replace('"', '\\"')
                    # Wrap in quotes for array parser
                    s = f'"{s}"'
                    # Escape the result for COPY parser
                    s = s.replace('\\', '\\\\')
                    escaped_items.append(s)
                out_fields.append("{" + ",".join(escaped_items) + "}")
            else:
                out_fields.append(_escape_text(str(v)))

        buffer.write("\t".join(out_fields) + "\n")

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
    cols = ("tconst","title_type","primary_title", "start_year","end_year","runtime_minutes","genres")
    q = f"INSERT INTO titles ({', '.join(cols)}) VALUES %s ON CONFLICT DO NOTHING"
    with conn.cursor() as cur:
        execute_values(cur, q, rows, page_size=1000)

def get_needed_nconsts(conn):
    """Return set van nconsts die in title_crew óf title_principals voorkomen."""
    with conn.cursor() as cur:
        cur.execute("""
            SELECT DISTINCT unnest(directors) AS nconst FROM title_crew WHERE directors IS NOT NULL
            UNION
            SELECT DISTINCT unnest(writers) AS nconst FROM title_crew WHERE writers IS NOT NULL
            UNION
            SELECT DISTINCT nconst FROM title_principals;
        """)
        return {row[0] for row in cur.fetchall()}

def import_names(allowed_tconsts):
    conn = connect_db()
    staging = f"names_staging_{os.getpid()}"

    with conn.cursor() as cur:
        cur.execute(f"CREATE TEMP TABLE IF NOT EXISTS {staging} (nconst text, primary_name text, known_for_titles text[]);")
        cur.execute("""
        CREATE TABLE IF NOT EXISTS names (
            nconst char(9) PRIMARY KEY,
            primary_name text,
            known_for_title text
        );
        """)


        conn.commit()

    # bepaal welke nconsts we willen (uit crew en principals)
    with conn.cursor() as cur:
        cur.execute("""
            SELECT DISTINCT unnest(directors) AS nconst FROM title_crew WHERE directors IS NOT NULL
            UNION
            SELECT DISTINCT unnest(writers)   AS nconst FROM title_crew WHERE writers IS NOT NULL
            UNION
            SELECT DISTINCT nconst FROM title_principals;
        """)
        needed = {row[0] for row in cur.fetchall()}

    if not needed:
        print("📛 Geen relevante nconsts gevonden.")
        conn.close()
        return

    buffer = []
    count = 0
    allowed = set(allowed_tconsts) if allowed_tconsts is not None else None

    for r in imdb_reader(URLS["names"]):
        nconst = r["nconst"]
        if nconst not in needed:
            continue

        kft_raw = r.get("knownForTitles")
        if kft_raw == "\\N" or not kft_raw:
            kft = None
        else:
            kft_list = kft_raw.split(",")
            if allowed is not None:
                # only keep up to 2 allowed tconsts
                kft_filtered = [t for t in kft_list if t in allowed][:2]
                kft = kft_filtered if kft_filtered else None
            else:
                kft = kft_list[:2]  # keep at most 2

        buffer.append((nconst, clean_text(r["primaryName"]), kft))
        count += 1

        if len(buffer) >= BATCH_SIZE:
            copy_to_table(conn, staging, ["nconst","primary_name","known_for_titles"], buffer)
            buffer.clear()

        if TEST_LIMIT and count >= TEST_LIMIT:
            break

    if buffer:
        copy_to_table(conn, staging, ["nconst","primary_name","known_for_titles"], buffer)

    # upsert to final names table; keep previous known_for_titles if new is NULL
    with conn.cursor() as cur:
        cur.execute("""
            INSERT INTO names (nconst, primary_name, known_for_titles)
            SELECT nconst, primary_name, known_for_titles FROM {stg}
            ON CONFLICT (nconst) DO UPDATE SET
              primary_name = EXCLUDED.primary_name,
              known_for_titles = COALESCE(EXCLUDED.known_for_titles, names.known_for_titles);
        """.replace("{stg}", staging))
        conn.commit()

    conn.close()
    print(f"✅ names import klaar — {count} records verwerkt.")

ALLOWED_PRINCIPAL_CATEGORIES = {"actor", "actress", "director"}  # pas aan naar wens

def import_principals(allowed_tconsts):
    conn = connect_db()
    staging = f"principals_staging_{os.getpid()}"

    with conn.cursor() as cur:
        cur.execute(f"""
            CREATE TEMP TABLE {staging} (
                tconst text,
                nconst text,
                role smallint
            );
        """)
        conn.commit()

    buffer = []
    count = 0

    for r in imdb_reader(URLS["principals"]):
        tconst = r["tconst"]
        if tconst not in allowed_tconsts:
            continue

        cat = r["category"]
        if cat not in ALLOWED_PRINCIPAL_CATEGORIES:
            continue

        # 🎭 role mapping
        if cat in ("actor", "actress"):
            role = ROLE_ACTOR
        elif cat == "director":
            role = ROLE_DIRECTOR
        else:
            continue

        buffer.append((tconst, r["nconst"], role))


        count += 1

        if len(buffer) >= BATCH_SIZE:
            copy_to_table(conn, staging, ["tconst","nconst","role"], buffer)
            print(f"🎭 principals staged: {count}")
            buffer.clear()

        if TEST_LIMIT and count >= TEST_LIMIT:
            break

    if buffer:
        copy_to_table(conn, staging, ["tconst","nconst","role"], buffer)

    with conn.cursor() as cur:
        cur.execute("""
            CREATE TABLE IF NOT EXISTS title_principals (
                tconst text,
                nconst text,
                role smallint
            );

        """)
        cur.execute("TRUNCATE title_principals;")
        cur.execute(f"""
            INSERT INTO title_principals (tconst, nconst, role)
            SELECT tconst, nconst, role FROM {staging};
        """)
        conn.commit()

    conn.close()
    print(f"✅ principals import klaar — {count} records verwerkt.")


def import_titles():
    conn = connect_db()

    # Zorg dat de tabel bestaat
    with conn.cursor() as cur:
        cur.execute("""
            CREATE TABLE IF NOT EXISTS titles (
                tconst text PRIMARY KEY,
                title_type text,
                primary_title text,
                start_year integer,
                end_year integer,
                runtime_minutes integer,
                genres text[]
            );
        """)
        conn.commit()

    buffer, count, kept = [], 0, 0
    for r in imdb_reader(URLS["titles"]):
        title_type = r["titleType"]
        start_year = safe_int(r.get("startYear"))
        runtime = safe_int(r.get("runtimeMinutes"))
        is_adult = r.get("isAdult") == "1"

        # ❌ Filters
        if title_type not in ("movie", "tvSeries", "tvMiniSeries"):
            continue
        if start_year is None or start_year < 2000:
            continue
        if runtime is None:
            continue
        if is_adult:  # optioneel
            continue

        buffer.append((
            r["tconst"],
            title_type,
            clean_text(r.get("primaryTitle")),
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
    staging = f"title_ratings_staging_{os.getpid()}"
    # Gebruik een tijdelijke staging-tabel voor snelle COPY en veilige upsert
    with conn.cursor() as cur:
        cur.execute(f"""
            CREATE TEMP TABLE IF NOT EXISTS {staging} (
                tconst text PRIMARY KEY,
                average_rating numeric,
                num_votes integer
            );
        """)
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
        cur.execute("""
            CREATE TABLE IF NOT EXISTS title_ratings (
                tconst text PRIMARY KEY,
                average_rating numeric,
                num_votes integer
            );
        """)
        cur.execute(f"""
        INSERT INTO title_ratings (tconst, average_rating, num_votes)
        SELECT tconst, average_rating, num_votes
        FROM {staging}
        ON CONFLICT (tconst) DO UPDATE
        SET
        average_rating = EXCLUDED.average_rating,
        num_votes = EXCLUDED.num_votes;
        """)
        conn.commit()

    conn.close()

def get_allowed_tconsts(conn):
    with conn.cursor() as cur:
        cur.execute("SELECT tconst FROM titles;")
        return {row[0] for row in cur.fetchall()}



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

    conn = connect_db()
    with conn.cursor() as cur:
        cur.execute("""
            CREATE TABLE IF NOT EXISTS title_crew (
                tconst text,
                directors text[],
                writers text[]
            );
        """)
        cur.execute("TRUNCATE title_crew;")
        conn.commit()
    conn.close()


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
    import_principals(allowed_tconsts)

    # names (after principals so we catch those nconsts too)
    import_names(allowed_tconsts)
    # 4️⃣ Ratings
    import_ratings()


    print("\n🎉 IMDb FULL IMPORT COMPLETED")
