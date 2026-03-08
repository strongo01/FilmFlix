const admin = require('firebase-admin');

function initAdmin() {
  if (admin.apps && admin.apps.length) return admin.app();

  let cred;
  if (process.env.FIREBASE_SERVICE_ACCOUNT) {
   try {
      const obj = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
      cred = admin.credential.cert(obj);
    } catch (e) {
      try {
        const decoded = Buffer.from(process.env.FIREBASE_SERVICE_ACCOUNT, 'base64').toString('utf8');
        const obj = JSON.parse(decoded);
        cred = admin.credential.cert(obj);
      } catch (e2) {
        console.error('Failed to parse FIREBASE_SERVICE_ACCOUNT (as JSON or base64):', e2);
      }
    }
  }

  if (!cred && process.env.FIREBASE_SERVICE_ACCOUNT_B64) {
    try {
      const json = Buffer.from(process.env.FIREBASE_SERVICE_ACCOUNT_B64, 'base64').toString('utf8');
      const obj = JSON.parse(json);
      cred = admin.credential.cert(obj);
    } catch (e) {
      console.error('Failed to parse FIREBASE_SERVICE_ACCOUNT_B64:', e);
    }
  }

  if (!cred) {
    try {
      const sa = require('../service-account.json');
      cred = admin.credential.cert(sa);
    } catch (e) {
      console.warn('No service account found locally and FIREBASE_SERVICE_ACCOUNT not set');
    }
  }

  if (cred) {
    console.log('initAdmin: service account credential loaded');
    return admin.initializeApp({ credential: cred });
  }
  console.log('initAdmin: no explicit service account, initializing default app');
  return admin.initializeApp();
}

initAdmin();


module.exports = async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST,OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') return res.status(200).end();

  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });

  const { type, userId, title, body: messageBody, data } = req.body || {};
  console.log('notify handler called, body=', JSON.stringify(req.body || {}));
  if (!type || !userId || !title || !messageBody) {
    return res.status(400).json({ error: 'Missing parameters' });
  }

  try {
    const db = admin.firestore();
    const messaging = admin.messaging();

    if (type === 'userToAdmins') {
     const q = await db.collection('users').where('role', '==', 'admin').get();
      const tokens = [];
      q.forEach(doc => {
        const d = doc.data();
        if (d && d.fcmToken) tokens.push(d.fcmToken);
      });

      console.log('userToAdmins: found admin tokens count=', tokens.length);

      if (!tokens.length) return res.status(200).json({ sent: 0, reason: 'no-admin-tokens' });

      const messages = tokens.map(t => ({ token: t, notification: { title, body: messageBody }, data: data || {} }));
      const resp = await messaging.sendAll(messages);
      console.log('userToAdmins: sendAll result:', { successCount: resp.successCount, failureCount: resp.failureCount });
      return res.status(200).json({ successCount: resp.successCount, failureCount: resp.failureCount });
    }

    if (type === 'adminToUser') {
      const userDoc = await db.collection('users').doc(userId).get();
      if (!userDoc.exists) return res.status(404).json({ error: 'user-not-found' });
      const d = userDoc.data() || {};
      const token = d.fcmToken;
      console.log('adminToUser: userId=', userId, 'tokenPresent=', !!token);
      if (!token) return res.status(200).json({ sent: 0, reason: 'user-has-no-token' });
      const message = { token, notification: { title, body: messageBody }, data: data || {} };
      await messaging.send(message);
      return res.status(200).json({ sent: 1 });
    }

    return res.status(400).json({ error: 'invalid-type' });
  } catch (err) {
    console.error('notify handler error:', err && err.stack ? err.stack : err);
    const resp = { error: 'internal' };
    if (process.env.NODE_ENV === 'development') resp.detail = err && err.message ? err.message : String(err);
    return res.status(500).json(resp);
  }
};
