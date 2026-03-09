/**
 * Local development proxy — menggantikan Netlify CLI.
 * Jalankan dengan: node scripts/proxy.js
 *
 * Tidak butuh npm install apapun, hanya Node.js bawaan.
 * API key dibaca dari file .env di root project.
 */

const http = require('http');
const https = require('https');
const fs = require('fs');
const path = require('path');

// ── Load .env ────────────────────────────────────────────
function loadEnv() {
  const envPath = path.resolve(__dirname, '../.env');
  if (!fs.existsSync(envPath)) {
    console.error('❌  File .env tidak ditemukan di root project.');
    console.error('   Buat file .env dengan isi: OPENAI_API_KEY=sk-...');
    process.exit(1);
  }
  const lines = fs.readFileSync(envPath, 'utf-8').split('\n');
  for (const line of lines) {
    const [key, ...rest] = line.split('=');
    if (key && rest.length) {
      process.env[key.trim()] = rest.join('=').trim();
    }
  }
}

loadEnv();

const PORT = 8080;
const OPENAI_API_KEY = process.env.OPENAI_API_KEY;

if (!OPENAI_API_KEY || OPENAI_API_KEY.startsWith('sk-paste')) {
  console.error('❌  OPENAI_API_KEY belum diisi di file .env');
  process.exit(1);
}

// ── Proxy server ──────────────────────────────────────────
const server = http.createServer((req, res) => {
  // CORS
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    res.end();
    return;
  }

  if (req.method !== 'POST' || req.url !== '/proxy') {
    res.writeHead(404, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: 'Not found. Use POST /proxy' }));
    return;
  }

  let body = '';
  req.on('data', (chunk) => (body += chunk));
  req.on('end', () => {
    const options = {
      hostname: 'api.openai.com',
      path: '/v1/chat/completions',
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${OPENAI_API_KEY}`,
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(body),
      },
    };

    const upstream = https.request(options, (upRes) => {
      res.writeHead(upRes.statusCode, { 'Content-Type': 'application/json' });
      upRes.pipe(res);
    });

    upstream.on('error', (err) => {
      res.writeHead(502, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: err.message }));
    });

    upstream.write(body);
    upstream.end();
  });
});

server.listen(PORT, () => {
  console.log(`✅  Local proxy berjalan di http://localhost:${PORT}/proxy`);
  console.log(`   API Key: ${OPENAI_API_KEY.substring(0, 8)}...`);
  console.log(`   Sekarang jalankan: flutter run -d chrome`);
});
