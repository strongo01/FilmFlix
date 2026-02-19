import postgres from 'postgres';

const connectionString = process.env.DATABASE_URL;

// Shared / transaction pooler → perfect voor serverless
const sql = postgres(connectionString, {
  ssl: 'require',
});


export default async function handler(req, res) {
  const {
    type,

    // ======================
    // RAPIDAPI (existing)
    // ======================
    country = 'nl',
    series_granularity = 'show',
    output_language = 'en',

    title,
    show_type = 'movie',
    id,

    rating_min = 0,
    rating_max = 100,
    catalogs,
    genres,
    genres_relation = 'and',
    keyword,
    show_original_language,
    year_min,
    year_max,
    order_by,
    order_direction = 'asc',

    // ======================
    // OMDB
    // ======================
    i,        // IMDb ID
    t,        // title
    s,        // search title
    y,        // year
    plot = 'short',
    omdb_type,
    r = 'json',
    page = 1,
  } = req.query;

  const RAPIDAPI_KEY = process.env.RAPIDAPI_KEY;
  const OMDB_API_KEY = process.env.OMDB_API_KEY;

  let url;
  let headers = {};

  // ======================
  // RAPIDAPI
  // ======================
  const RAPID_HOST = 'streaming-availability.p.rapidapi.com';

  if (type === 'search') {
    url = `https://${RAPID_HOST}/shows/search/title?` +
      new URLSearchParams({
        country,
        title,
        series_granularity,
        show_type,
        output_language,
      });

    headers = {
      'x-rapidapi-key': RAPIDAPI_KEY,
      'x-rapidapi-host': RAPID_HOST,
    };
  }

  else if (type === 'get') {
    url = `https://${RAPID_HOST}/shows/${id}?` +
      new URLSearchParams({
        series_granularity,
        output_language,
      });

    headers = {
      'x-rapidapi-key': RAPIDAPI_KEY,
      'x-rapidapi-host': RAPID_HOST,
    };
  }

  else if (type === 'filter') {
    url = `https://${RAPID_HOST}/shows/search/filters?` +
      new URLSearchParams({
        country,
        series_granularity,
        output_language,
        show_type,
        rating_min,
        rating_max,
        catalogs,
        genres,
        genres_relation,
        keyword,
        show_original_language,
        year_min,
        year_max,
        order_by,
        order_direction,
      });

    headers = {
      'x-rapidapi-key': RAPIDAPI_KEY,
      'x-rapidapi-host': RAPID_HOST,
    };
  }

  // ======================
  // OMDB — GET BY ID OR TITLE
  // ======================
  else if (type === 'omdb-get') {
    if (!i && !t) {
      return res.status(400).json({
        error: 'OMDb requires i (IMDb ID) or t (title)',
      });
    }

    url = `https://www.omdbapi.com/?` +
      new URLSearchParams({
        apikey: OMDB_API_KEY,
        i,
        t,
        y,
        plot,
        r,
        type: omdb_type,
      });
  }

  // ======================
  // OMDB — SEARCH
  // ======================
  else if (type === 'omdb-search') {
    if (!s) {
      return res.status(400).json({
        error: 'OMDb search requires s (search title)',
      });
    }

    url = `https://www.omdbapi.com/?` +
      new URLSearchParams({
        apikey: OMDB_API_KEY,
        s,
        y,
        page,
        type: omdb_type,
        r,
      });
  }

  else {
    return res.status(400).json({
      error: 'Invalid type',
    });
  }

  try {
    const response = await fetch(url, { headers });
    const data = await response.json();
    res.status(200).json(data);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'External API request failed' });
  }
}
