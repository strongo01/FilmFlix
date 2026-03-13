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

      // Send messages. Newer admin SDKs provide sendAll/sendMulticast; older runtimes may not.
      let successCount = 0;
      let failureCount = 0;
      if (typeof messaging.sendAll === 'function') {
        const resp = await messaging.sendAll(messages);
        successCount = resp.successCount ?? (resp.responses ? resp.responses.filter(r => r.success).length : 0);
        failureCount = resp.failureCount ?? (resp.responses ? resp.responses.filter(r => !r.success).length : messages.length - successCount);
        console.log('userToAdmins: sendAll used');
      } else if (typeof messaging.sendMulticast === 'function') {
        // sendMulticast accepts a multicast message with tokens array
        const multicast = { tokens, notification: { title, body: messageBody }, data: data || {} };
        const resp = await messaging.sendMulticast(multicast);
        successCount = resp.successCount || 0;
        failureCount = resp.failureCount || 0;
        console.log('userToAdmins: sendMulticast used');
      } else {
        // Fallback: send messages individually and aggregate results
        const results = await Promise.allSettled(messages.map(m => messaging.send(m)));
        successCount = results.filter(r => r.status === 'fulfilled').length;
        failureCount = results.length - successCount;
        console.log('userToAdmins: send fallback used');
      }

      console.log('userToAdmins: send result:', { successCount, failureCount });
      return res.status(200).json({ successCount, failureCount });
    }

    if (type === 'adminToUser') {
      console.log('adminToUser branch triggered for userId:', userId);
      const userDoc = await db.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        console.error('adminToUser: User doc not found for userId:', userId);
        return res.status(404).json({ error: 'user-not-found', userId });
      }
      const d = userDoc.data() || {};
      const token = d.fcmToken;
      console.log('adminToUser: userId found, token present:', !!token, 'token length:', token ? token.length : 0);
      if (!token) {
        console.warn('adminToUser: No fcmToken in user doc for userId:', userId);
        return res.status(200).json({ sent: 0, reason: 'user-has-no-token', userId });
      }
      const message = { token, notification: { title, body: messageBody }, data: data || {} };
      console.log('adminToUser: Sending message via messaging.send...');
      try {
        await messaging.send(message);
        console.log('adminToUser: Message sent successfully to userId:', userId);
        return res.status(200).json({ sent: 1, userId });
      } catch (sendError) {
        console.error('adminToUser: Error calling messaging.send:', sendError);
        return res.status(500).json({ error: 'messaging-send-failed', detail: sendError.message });
      }
    }

    return res.status(400).json({ error: 'invalid-type' });
  } catch (err) {
    console.error('notify handler error:', err && err.stack ? err.stack : err);
    const resp = { error: 'internal' };
    if (process.env.NODE_ENV === 'development') resp.detail = err && err.message ? err.message : String(err);
    return res.status(500).json(resp);
  }
};
