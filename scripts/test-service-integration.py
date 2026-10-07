"""Build the real service image and test it against PostgreSQL with verified TLS. No AWS."""
from pathlib import Path
import http.client
import json,os,secrets,subprocess,tempfile,time,urllib.request,urllib.error
ROOT=Path(__file__).resolve().parents[1]
suffix=secrets.token_hex(4);network='goldenpath-test-'+suffix;db=network+'-db';app=network+'-app'
def run(*args,**kwargs):return subprocess.run(args,check=True,**kwargs)
def request(url):
 try:
  with urllib.request.urlopen(url,timeout=5) as response:return response.status,json.load(response)
 except urllib.error.HTTPError as e:return e.code,json.load(e)
def await_status(url,expected):
 for _ in range(120):
  try:
   status,body=request(url)
   if status==expected:return body
  except (urllib.error.URLError,TimeoutError,ConnectionError,http.client.HTTPException):pass
  time.sleep(1)
 raise RuntimeError(f'{url} did not reach {expected}')
with tempfile.TemporaryDirectory(prefix='goldenpath-tls-') as tmp:
 p=Path(tmp)
 run('openssl','req','-x509','-newkey','rsa:2048','-nodes','-keyout',str(p/'server.key'),'-out',str(p/'server.crt'),'-days','2','-subj','/CN=postgres','-addext','subjectAltName=DNS:postgres',stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
 (p/'Dockerfile').write_text('FROM postgres:16.15-bookworm\nRUN mkdir -p /certs && chmod 755 /certs\nCOPY --chown=postgres:postgres --chmod=600 server.key /certs/server.key\nCOPY --chown=postgres:postgres server.crt /certs/server.crt\nCMD ["postgres","-c","ssl=on","-c","ssl_cert_file=/certs/server.crt","-c","ssl_key_file=/certs/server.key"]\n')
 password=secrets.token_urlsafe(24)
 (p/'postgres.env').write_text(f'POSTGRES_PASSWORD={password}\nPOSTGRES_USER=app\nPOSTGRES_DB=app\n');(p/'postgres.env').chmod(0o600)
 (p/'service.env').write_text(f'PGHOST=postgres\nPGPORT=5432\nPGDATABASE=app\nPGUSER=app\nPGPASSWORD={password}\nSERVICE_NAME=integration-test\n');(p/'service.env').chmod(0o600)
 run('docker','build','-q','-t',network+'-postgres',str(p))
 run('docker','build','-q','-t','goldenpath-service-v0:validation',str(ROOT/'services/service-v0'))
 try:
  run('docker','network','create',network,stdout=subprocess.DEVNULL)
  run('docker','run','-d','--name',db,'--network',network,'--network-alias','postgres','--env-file',str(p/'postgres.env'),network+'-postgres',stdout=subprocess.DEVNULL)
  run('docker','run','-d','--name',app,'--network',network,'-p','127.0.0.1::8080','--env-file',str(p/'service.env'),'-v',f'{p}/server.crt:/app/certs/global-bundle.pem:ro','goldenpath-service-v0:validation',stdout=subprocess.DEVNULL)
  binding=subprocess.check_output(['docker','port',app,'8080'],text=True).strip();url='http://'+binding
  body=await_status(url+'/readyz',200);assert body['database']=='connected'
  run('docker','stop','--time','2',db,stdout=subprocess.DEVNULL)
  await_status(url+'/readyz',503);assert request(url+'/healthz')[0]==200
  run('docker','start',db,stdout=subprocess.DEVNULL);await_status(url+'/readyz',200)
  print('PASS: real SELECT 1 over verified TLS; readiness 503 during DB outage; liveness 200; recovery 200.')
 except Exception:
  for name in (app,db):
   logs=subprocess.run(['docker','logs','--tail','30',name],capture_output=True,text=True)
   print(name,(logs.stdout+logs.stderr).replace(password,'[REDACTED]'),flush=True)
  probe=subprocess.run(['docker','exec',app,'node','--input-type=module','-e',"import pg from 'pg';import fs from 'node:fs';const c=new pg.Client({ssl:{rejectUnauthorized:true,ca:fs.readFileSync('/app/certs/global-bundle.pem','utf8')}});try{await c.connect();console.log('TLS connection OK')}catch(e){console.log(e.message)}finally{await c.end()}"],capture_output=True,text=True)
  print((probe.stdout+probe.stderr).replace(password,'[REDACTED]'),flush=True)
  raise
 finally:
  for name in (app,db):subprocess.run(['docker','rm','-f',name],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
  subprocess.run(['docker','network','rm',network],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
  subprocess.run(['docker','image','rm',network+'-postgres'],stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL)
