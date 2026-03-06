const https = require('https');
export default async function handler(req, res) {

    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Access-Control-Allow-Methods', 'GET,OPTIONS');
    res.setHeader(
        'Access-Control-Allow-Headers',
        'Content-Type, Authorization, x-app-api-key, x-app-key, Accept'
    );

    if (req.method === 'OPTIONS') {
        return res.status(200).end();
    }

    // Vereiste API-key: x-app-api-key
    const APP_API_KEY = process.env.X_APP_API_KEY;
    const providedKey = req.headers['x-app-api-key'] || req.headers['x-app-key'];

    if (!providedKey || providedKey !== APP_API_KEY) {
        return res.status(401).json({ error: 'Missing or invalid x-app-api-key' });
    }

    const {
        type,

        // RAPIDAPI 
        country = 'nl',
        series_granularity = 'show',
        output_language = 'en',

        title,
        show_type,
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
        cursor,

        // OMDB
        i,        // IMDb ID
        t,        // title
        s,        // search title
        y,        // year
        plot = 'short',
        omdb_type,
        r = 'json',
        page = 1,

        // (no database params)

        // TMDB
        movie_id,
    } = req.query;

    const RAPIDAPI_KEY = process.env.RAPIDAPI_KEY;
    const OMDB_API_KEY = process.env.OMDB_API_KEY;
    const TMDB_API_KEY = process.env.TMDB_API_KEY;

    let url;
    let headers = {};

    // RAPIDAPI
    const RAPID_HOST = 'streaming-availability.p.rapidapi.com';

    function addParam(params, key, value) {
        if (value !== undefined && value !== null && value !== '') {
            params[key] = value;
        }
    }

    if (type === 'search') {
        const params = {};
        addParam(params, 'country', country);
        addParam(params, 'title', title);
        addParam(params, 'series_granularity', series_granularity);
        addParam(params, 'output_language', output_language);
        addParam(params, 'show_type', show_type);

        url = `https://${RAPID_HOST}/shows/search/title?` + new URLSearchParams(params);

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
        const params = {};
        addParam(params, 'country', country);
        addParam(params, 'series_granularity', series_granularity);
        addParam(params, 'output_language', output_language);
        addParam(params, 'show_type', show_type);
        addParam(params, 'rating_min', rating_min);
        addParam(params, 'rating_max', rating_max);
        addParam(params, 'catalogs', catalogs);
        addParam(params, 'genres', genres);
        addParam(params, 'genres_relation', genres_relation);
        addParam(params, 'keyword', keyword);
        addParam(params, 'show_original_language', show_original_language);
        addParam(params, 'year_min', year_min);
        addParam(params, 'year_max', year_max);
        addParam(params, 'order_by', order_by);
        addParam(params, 'order_direction', order_direction);
        addParam(params, 'cursor', cursor);
        url = `https://${RAPID_HOST}/shows/search/filters?` + new URLSearchParams(params);

        headers = {
            'x-rapidapi-key': RAPIDAPI_KEY,
            'x-rapidapi-host': RAPID_HOST,
        };
    }

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

    else if (type === 'tmdb-images') {
        if (!movie_id) {
            return res.status(400).json({
                error: 'TMDB requires movie_id',
            });
        }

        url = `https://api.themoviedb.org/3/movie/${movie_id}/images`;
        headers = {
            'accept': 'application/json',
            'Authorization': `Bearer ${TMDB_API_KEY}`,
        };
    }

    else if (type === 'image-proxy') {
        const { imageUrl } = req.query;

        if (!imageUrl) {
            return res.status(400).json({ error: 'Missing imageUrl' });
        }

        try {
            const parsed = new URL(imageUrl);

            if (parsed.protocol !== 'https:') {
                return res.status(400).json({ error: 'Only HTTPS allowed' });
            }

            const allowedHosts = [
                'cdn.movieofthenight.com',
                'image.tmdb.org',
                'm.media-amazon.com'
            ];

            if (!allowedHosts.includes(parsed.hostname)) {
                return res.status(403).json({ error: 'Host not allowed' });
            }

            const response = await fetch(imageUrl);

            if (!response.ok) {
                return res.status(response.status).end();
            }

            const buffer = await response.arrayBuffer();

            res.setHeader(
                'Content-Type',
                response.headers.get('content-type') || 'image/jpeg'
            );

            res.setHeader('Cache-Control', 'public, max-age=86400');

            return res.status(200).send(Buffer.from(buffer));
        } catch (err) {
            return res.status(500).json({ error: 'Image fetch failed' });
        }
    }

    else if (type === 'actualfilms') {
        const { page = 1, language = 'nl-NL', region = 'NL' } = req.query;

        url = `https://api.themoviedb.org/3/movie/now_playing?` +
            new URLSearchParams({
                language,
                page,
                region,
            });

        headers = {
            'accept': 'application/json',
            'Authorization': `Bearer ${TMDB_API_KEY}`,
        };
    }

    else if (type === 'tmdbmovieinfo') {
        const { movie_id, language = 'nl-NL' } = req.query;

        if (!movie_id) {
            return res.status(400).json({
                error: 'TMDB requires movie_id',
            });
        }

        url = `https://api.themoviedb.org/3/movie/${movie_id}?` +
            new URLSearchParams({
                language,
            });

        headers = {
            'accept': 'application/json',
            'Authorization': `Bearer ${TMDB_API_KEY}`,
        };
    }

    else if (type === 'top_rated') {
        const { page = 1, language = 'nl-NL', region = 'NL' } = req.query;

        url = `https://api.themoviedb.org/3/movie/top_rated?` +
            new URLSearchParams({
                language,
                page,
                region,
            });

        headers = {
            'accept': 'application/json',
            'Authorization': `Bearer ${TMDB_API_KEY}`,
        };
    }

    else if (type === 'popular') {
        const { page = 1, language = 'nl-NL', region = 'NL' } = req.query;

        url = `https://api.themoviedb.org/3/movie/popular?` +
            new URLSearchParams({
                language,
                page,
                region,
            });

        headers = {
            'accept': 'application/json',
            'Authorization': `Bearer ${TMDB_API_KEY}`,
        };
    }

    else if (type === 'translate') {
        const { text, target = 'nl', source = 'auto' } = req.query;

        if (!text) {
            return res.status(400).json({ error: 'Missing text parameter' });
        }

        const options = {
            method: 'POST',
            hostname: 'free-google-translator.p.rapidapi.com',
            path: `/external-api/free-google-translator?from=${encodeURIComponent(source)}&to=${encodeURIComponent(target)}&query=${encodeURIComponent(text)}`,
            headers: {
                'x-rapidapi-key': RAPIDAPI_KEY,
                'x-rapidapi-host': 'free-google-translator.p.rapidapi.com',
                'Content-Type': 'application/json',
            },
        };

        try {
            const translated = await new Promise((resolve, reject) => {
                const req = https.request(options, (res2) => {
                    const chunks = [];
                    res2.on('data', (chunk) => chunks.push(chunk));
                    res2.on('end', () => {
                        const body = Buffer.concat(chunks).toString();
                        try {
                            const json = JSON.parse(body);
                            resolve(json);
                        } catch (e) {
                            reject(e);
                        }
                    });
                });

                req.on('error', (err) => reject(err));
                req.write(JSON.stringify({ translate: 'rapidapi' }));
                req.end();
            });

            return res.status(200).json(translated);
        } catch (err) {
            console.error(err);
            return res.status(500).json({ error: 'Translation failed' });
        }
    }

    else {
        return res.status(400).json({
            error: 'Invalid type',
        });
    }

    if (url) {
        try {
            const response = await fetch(url, { headers });
            if (!response.ok) {
                return res.status(response.status).json({ error: 'Upstream API failed' });
            }
            const data = await response.json();

            const CACHE_TTLS = { search: 86400, get: 604800, filter: 86400 };
            function setCacheForType(t) {
                const s = CACHE_TTLS[t] || 60; // default short s-maxage
                res.setHeader('Cache-Control', `public, max-age=60, s-maxage=${s}, stale-while-revalidate=300`);
            }

            if (type !== 'search') {
                if (type === 'get' || type === 'filter' || type === 'search') setCacheForType(type);
                return res.status(200).json(data);
            }

            if (!title) {
                return res.status(400).json({ error: 'Search requires title parameter' });
            }

            function normalize(str) {
                if (!str) return '';
                return str
                    .normalize('NFD')
                    .replace(/[\u0300-\u036f]/g, '')
                    .toLowerCase()
                    .replace(/[^a-z0-9\s]/g, ' ')
                    .replace(/\s+/g, ' ')
                    .trim();
            }

            function levenshtein(a, b) {
                const m = a.length, n = b.length;
                if (!m) return n;
                if (!n) return m;
                const v0 = new Array(n + 1);
                const v1 = new Array(n + 1);
                for (let j = 0; j <= n; j++) v0[j] = j;
                for (let i = 0; i < m; i++) {
                    v1[0] = i + 1;
                    for (let j = 0; j < n; j++) {
                        const cost = a[i] === b[j] ? 0 : 1;
                        v1[j + 1] = Math.min(v1[j] + 1, v0[j + 1] + 1, v0[j] + cost);
                    }
                    for (let j = 0; j <= n; j++) v0[j] = v1[j];
                }
                return v1[n];
            }

            function similarityScore(a, b) {
                const dist = levenshtein(a, b);
                return 1 - dist / Math.max(a.length, b.length);
            }

            let hits = [];
            if (Array.isArray(data)) hits = data;
            else if (Array.isArray(data?.results)) hits = data.results;
            else if (Array.isArray(data?.titles)) hits = data.titles;

            const queryNorm = normalize(title);
            const queryTokens = queryNorm.split(' ');

            function titleOf(item) {
                return item.title || item.name || item.show_title || item.original_title || '';
            }

            function hasExact(itemNorm) {
                return itemNorm === queryNorm;
            }
            function hasPhrase(itemNorm) {
                return itemNorm.includes(queryNorm);
            }
            function hasAllWords(itemNorm) {
                return queryTokens.every(tok => itemNorm.includes(tok));
            }
            function hasFuzzy(itemNorm) {
                return similarityScore(itemNorm, queryNorm) >= 0.6;
            }

            const scored = hits.map(hit => {
                const rawTitle = titleOf(hit);
                const itemNorm = normalize(rawTitle);

                let score = 0;

                if (hasExact(itemNorm)) {
                    score = 100;
                }
                else if (hasPhrase(itemNorm)) {
                    score = 80;
                }
                else if (hasAllWords(itemNorm)) {
                    score = 60;
                }
                else {
                    const similarity = similarityScore(itemNorm, queryNorm);
                    if (similarity >= 0.6) {
                        score = similarity * 50;
                    }
                }

                return {
                    ...hit,
                    _score: score
                };
            });

            const filtered = scored
                .filter(item => item._score > 0)
                .sort((a, b) => b._score - a._score);

            setCacheForType('search');

            res.status(200).json({
                original_count: hits.length,
                filtered_count: filtered.length,
                results: filtered
            });
        } catch (err) {
            console.error(err);
            res.status(500).json({ error: 'External API request failed' });
        }
    }
}