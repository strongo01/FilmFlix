import postgres from 'postgres';

let sql;
if (!global.sql) {
  if (!process.env.DATABASE_URL) throw new Error('DATABASE_URL is not defined');
  global.sql = postgres(process.env.DATABASE_URL, { ssl: 'require' });
}
sql = global.sql;

export default async function handler(req, res) {
  const {
    type,

    // RAPIDAPI 
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

    // OMDB
    i,        // IMDb ID
    t,        // title
    s,        // search title
    y,        // year
    plot = 'short',
    omdb_type,
    r = 'json',
    page = 1,

    // Supabase
    tconst, 
  } = req.query;

  const RAPIDAPI_KEY = process.env.RAPIDAPI_KEY;
  const OMDB_API_KEY = process.env.OMDB_API_KEY;

  let url;
  let headers = {};

  // RAPIDAPI
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
  const queryParams = {
    country: country || 'nl',
    series_granularity: series_granularity || 'show',
    output_language: output_language || 'en',
    show_type: show_type || 'movie',
    rating_min: rating_min || 0,
    rating_max: rating_max || 100,
    catalogs: catalogs || '',
    genres: genres || '',
    genres_relation: genres_relation || 'and',
    keyword: keyword || '',
    show_original_language: show_original_language || '',
    year_min: year_min || '',
    year_max: year_max || '',
    order_by: order_by || 'original_title',
    order_direction: order_direction || 'asc',
  };

  url = `https://${RAPID_HOST}/shows/search/filters?` +
    new URLSearchParams(queryParams);

  headers = {
    'x-rapidapi-key': RAPIDAPI_KEY,
    'x-rapidapi-host': RAPID_HOST,
  };
}


  // OMDB — GET BY ID OR TITLE
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

  // OMDB — SEARCH
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

  // SUPABASE — FETCH TITLES + RATINGS
  else if (type === 'supabase-titles') {
    try {
      const titlesQuery = tconst
        ? sql`SELECT * FROM titles WHERE tconst = ${tconst}`
        : sql`SELECT * FROM titles`;

      const ratingsQuery = tconst
        ? sql`SELECT * FROM title_ratings WHERE tconst = ${tconst}`
        : sql`SELECT * FROM title_ratings`;

      const titles = await titlesQuery;
      const ratings = await ratingsQuery;

      return res.status(200).json({ titles, ratings });
    } catch (err) {
      console.error(err);
      return res.status(500).json({ error: 'Supabase query failed' });
    }
  }

  else {
    return res.status(400).json({
      error: 'Invalid type',
    });
  }

  // FETCH EXTERNAL API (RapidAPI / OMDb)
  if (url) {
    try {
      const response = await fetch(url, { headers });
      const data = await response.json();
      res.status(200).json(data);
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: 'External API request failed' });
    }
  }
}
