import { put, list } from "@vercel/blob";
const https = require('https');

// In-process coalescing map to dedupe concurrent upstream requests per instance
const _inFlight = new Map();
function fetchWithCoalesce(key, fetcher) {
    if (_inFlight.has(key)) {
        return { promise: _inFlight.get(key), coalesced: true };
    }
    const p = (async () => {
        try {
            return await fetcher();
        } finally {
            _inFlight.delete(key);
        }
    })();
    _inFlight.set(key, p);
    return { promise: p, coalesced: false };
}

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
    let isEpisodeRequest = false;
    let blobKey;
    // RAPIDAPI
    const RAPID_HOST = 'streaming-availability.p.rapidapi.com';

    function addParam(params, key, value) {
        if (value !== undefined && value !== null && value !== '') {
            params[key] = value;
        }
    }

    function filterStreamingOptions(obj) {
        if (Array.isArray(obj)) {
            return obj.map(filterStreamingOptions);
        } else if (obj && typeof obj === 'object') {
            const result = {};
            for (const key in obj) {
                if (key === 'streamingOptions' && typeof obj[key] === 'object') {
                    // filter alleen nl & us
                    const filtered = {};
                    if (obj[key].nl) filtered.nl = obj[key].nl;
                    if (obj[key].us) filtered.us = obj[key].us;
                    result[key] = filtered;
                } else {
                    result[key] = filterStreamingOptions(obj[key]);
                }
            }
            return result;
        } else {
            return obj;
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
        isEpisodeRequest = series_granularity === "episode";
        blobKey = `episodes-${id}-${output_language}.json`;
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
            // Normalize URL query params for stable cache keys (sort params)
            const _u = new URL(url);
            const _params = Array.from(_u.searchParams.entries()).sort((a, b) => {
                if (a[0] === b[0]) return a[1] < b[1] ? -1 : (a[1] > b[1] ? 1 : 0);
                return a[0] < b[0] ? -1 : 1;
            }).map(p => `${p[0]}=${p[1]}`).join('&');
            const normalizedUrl = _params.length ? `${_u.origin}${_u.pathname}?${_params}` : `${_u.origin}${_u.pathname}`;
            const cacheKey = `${type}|${normalizedUrl}`;
            console.log('movies: cacheKey=', cacheKey);
            const BLOB_TTL_DAYS = 7; // houd blobs maximaal 7 dagen
            const BLOB_TTL_MS = BLOB_TTL_DAYS * 24 * 60 * 60 * 1000;

            //let blobKey;
            if (isEpisodeRequest) {
                blobKey = `episodes-${id}-${output_language}.json`;
                try {
                    const existing = await list({ prefix: blobKey });

                    for (const blob of existing.blobs) {
                        const blobDate = new Date(blob.created_at).getTime();
                        if (Date.now() - blobDate > BLOB_TTL_MS) {
                            console.log("Deleting old blob", blob.name);
                            await blob.delete();
                        }
                    }

                    const freshBlobs = existing.blobs.filter(blob => Date.now() - new Date(blob.created_at).getTime() <= BLOB_TTL_MS);
                    if (freshBlobs.length > 0) {
                        console.log("BLOB CACHE HIT", blobKey);
                        const cached = await fetch(freshBlobs[0].url);
                        const json = await cached.json();
                        res.setHeader("Cache-Control", "public, max-age=60, s-maxage=604800, stale-while-revalidate=300");
                        return res.status(200).json(json);
                    } else {
                        console.log("BLOB CACHE MISS", blobKey);
                    }
                } catch (e) {
                    console.log("Blob read failed, continuing...", e);
                }
            }
            const { promise, coalesced } = fetchWithCoalesce(cacheKey, async () => {
                const resp = await fetch(url, { headers });
                if (!resp.ok) {
                    // propagate upstream status to handler
                    const status = resp.status || 502;
                    throw { upstreamStatus: status };
                }
                return await resp.json();
            });

            const data = await promise;
            const filteredData = filterStreamingOptions(data);

            if (isEpisodeRequest) {
                try {
                    await put(blobKey, JSON.stringify(filteredData), {
                        access: "public",
                        contentType: "application/json",
                        token: process.env.BLOB_READ_WRITE_TOKEN,
                    });

                    console.log("BLOB CACHE SAVED");
                } catch (e) {
                    console.log("Blob save failed", e);
                }
            }
            const CACHE_TTLS = { search: 86400, get: 604800, filter: 86400 };
            function setCacheForType(t) {
                const s = CACHE_TTLS[t] || 60; // default short s-maxage
                res.setHeader('Cache-Control', `public, max-age=60, s-maxage=${s}, stale-while-revalidate=300`);
            }

            // indicate whether response was coalesced or required a fresh upstream fetch
            res.setHeader('X-Cache', coalesced ? 'COALESCED' : 'MISS');

            if (type !== 'search') {
                if (type === 'get' || type === 'filter') setCacheForType(type);
                return res.status(200).json(filteredData);
            }

            if (!title) {
                return res.status(400).json({ error: 'Search requires title parameter' });
            }

            function normalize(str) {
                if (!str) return '';
                return str
                    .normalize('NFD')
                    .replace(/\p{Diacritic}/gu, '')
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

            // mark search responses with cache header (1 day)
            setCacheForType('search');
            // X-Cache already set above based on coalescing

            res.status(200).json({
                original_count: hits.length,
                filtered_count: filtered.length,
                results: filtered
            });
        } catch (err) {
            if (err && err.upstreamStatus) {
                return res.status(err.upstreamStatus).json({ error: 'Upstream API failed' });
            }
            console.error(err);
            res.status(500).json({ error: 'External API request failed' });
        }
    }
}