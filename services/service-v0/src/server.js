import http from 'node:http';
import fs from 'node:fs';
import pg from 'pg';
import { pathToFileURL } from 'node:url';
export function createServer({query, service = 'goldenpath-service', version = '1.0.0'}) {
  return http.createServer(async (req, res) => {
    const path = new URL(req.url, 'http://localhost').pathname;
    res.setHeader('Content-Type', 'application/json; charset=utf-8');
    res.setHeader('Cache-Control', 'no-store');
    if (req.method !== 'GET') { res.writeHead(405); return res.end(JSON.stringify({error: 'method_not_allowed'})); }
    if (path === '/healthz') return res.end(JSON.stringify({status: 'alive', service, version}));
    if (!['/', '/readyz'].includes(path)) {res.writeHead(404); return res.end(JSON.stringify({error: 'not_found'}));}
    try {
      await query('SELECT 1');
      res.end(JSON.stringify({service, version, database: 'connected', message: 'Conectado a PostgreSQL. Tu servicio está listo.'}));
    } catch {
      res.writeHead(503);
      res.end(JSON.stringify({service, version, database: 'unavailable', message: 'Esperando conexión con la base de datos.'}));
    }
  });
}
if (import.meta.url === pathToFileURL(process.argv[1]).href) {
  if (process.env.PGSSLMODE === 'disable' && process.env.NODE_ENV === 'production') throw new Error('TLS must be enabled in production');
  const ssl = process.env.PGSSLMODE === 'disable' ? false : {rejectUnauthorized: true, ca: fs.readFileSync(process.env.PGSSLROOTCERT || '/app/certs/global-bundle.pem', 'utf8')};
  const pool = new pg.Pool({ssl, max: 5, connectionTimeoutMillis: 2000, query_timeout: 2000, statement_timeout: 2000, idleTimeoutMillis: 10000});
  pool.on('error', () => console.error('Database connection interrupted'));
  const server = createServer({query: sql => pool.query(sql), service: process.env.SERVICE_NAME, version: process.env.SERVICE_VERSION});
  server.listen(Number(process.env.PORT || 8080), '0.0.0.0', () => console.log('GoldenPath service listening'));
  for (const signal of ['SIGTERM','SIGINT']) process.on(signal, () => {server.close(async () => {await pool.end(); process.exit(0);}); setTimeout(() => process.exit(1), 5000).unref();});
}
