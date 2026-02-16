import os
import csv
import gzip
import io
import requests
import psycopg2

# ======================================================
# CONFIG
# ======================================================
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

# ======================================================
# DATABASE CONNECTIE
# ======================================================
def connect_db():
    return psycopg2.connect(
        host=os.environ["DB_HOST"],
        dbname=os.environ["DB_NAME"],
        user=os.environ["DB_USER"],
        password=os.environ["DB_PASSWORD"],
        port=os.environ.get("DB_PORT", 5432),
    )

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

def import_titles():
    conn = connect_db()
    staging = "titles_staging"

    with conn.cursor() as cur:
        cur.execute(f"TRUNCATE {staging};")
        conn.commit()

    buffer, count = [], 0
    for r in imdb_reader(URLS["titles"]):
        buffer.append((
            r["tconst"],
            r["titleType"],
            r["primaryTitle"],
            r["originalTitle"],
            r["isAdult"] == "1",
            none(r["startYear"]),
            none(r["endYear"]),
            none(r["runtimeMinutes"]),
            None if r["genres"] == "\\N" else r["genres"].split(",")
        ))
        count += 1

        if len(buffer) >= BATCH_SIZE:
            copy_to_table(conn, staging,
                          ["tconst","title_type","primary_title","original_title",
                           "is_adult","start_year","end_year","runtime_minutes","genres"],
                          buffer)
            print(f"🎬 titles streamed: {count}")
            buffer.clear()

        if TEST_LIMIT and count >= TEST_LIMIT:
            break

    if buffer:
        copy_to_table(conn, staging,
                      ["tconst","title_type","primary_title","original_title",
                       "is_adult","start_year","end_year","runtime_minutes","genres"],
                      buffer)

    with conn.cursor() as cur:
        cur.execute(f"""
        INSERT INTO titles
        SELECT * FROM {staging}
        ON CONFLICT (tconst) DO UPDATE SET
          primary_title = EXCLUDED.primary_title,
          runtime_minutes = EXCLUDED.runtime_minutes,
          genres = EXCLUDED.genres;
        """)
        conn.commit()
    conn.close()

def import_ratings():
    conn = connect_db()
    staging = "title_ratings_staging"
    with conn.cursor() as cur:
        cur.execute(f"TRUNCATE {staging};")
        conn.commit()

    buffer = []
    for r in imdb_reader(URLS["ratings"]):
        buffer.append((
            r["tconst"],
            float(r["averageRating"]),
            int(r["numVotes"]),
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

def import_names():
    conn = connect_db()
    staging = "names_staging"
    with conn.cursor() as cur:
        cur.execute(f"TRUNCATE {staging};")
        conn.commit()

    buffer = []
    for r in imdb_reader(URLS["names"]):
        buffer.append((
            r["nconst"],
            r["primaryName"],
            none(r["birthYear"]),
            none(r["deathYear"]),
            None if r["primaryProfession"] == "\\N" else r["primaryProfession"].split(","),
            None if r["knownForTitles"] == "\\N" else r["knownForTitles"].split(","),
        ))
        if len(buffer) >= BATCH_SIZE:
            copy_to_table(conn, staging,
                          ["nconst","primary_name","birth_year","death_year",
                           "primary_profession","known_for_titles"],
                          buffer)
            buffer.clear()
    if buffer:
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

def import_simple_table(url_key, table, columns, update_columns=None, convert_funcs=None):
    """Generic importer voor akas, crew, episodes, principals"""
    conn = connect_db()
    buffer = []
    count = 0
    for r in imdb_reader(URLS[url_key]):
        row = []
        for i, col in enumerate(columns):
            val = r[col]
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
        ["titleId","ordering","title","region","language","types","attributes","isOriginalTitle"],
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
    # episodes
    import_simple_table(
        "episodes",
        "title_episodes",
        ["tconst","parentTconst","seasonNumber","episodeNumber"],
        convert_funcs={
            "seasonNumber": lambda x: None if x=="\\N" else int(x),
            "episodeNumber": lambda x: None if x=="\\N" else int(x),
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
if __name__ == "__main__":
    print("🔌 Connecting to Supabase...")
    connect_db().close()
    print("✅ Connected\n")

    # Eerst de basis-titels
    import_titles()

    # Daarna alles wat afhankelijk is van titles
    import_ratings()
    import_all_simple()  # akas, crew, episodes, principals

    # En namen los van de titles
    import_names()

    print("\n🎉 IMDb FULL IMPORT COMPLETED")
