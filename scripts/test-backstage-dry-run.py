"""Exercise the real scaffolder's context and fetch:template actions, without publishing."""
from pathlib import Path
import base64,json,urllib.request,urllib.error
import yaml
root=Path(__file__).resolve().parents[1]
base='http://localhost:7007'
req=urllib.request.Request(base+'/api/auth/guest/refresh?env=development',headers={'X-Requested-With':'XMLHttpRequest'})
with urllib.request.urlopen(req) as response:token=json.load(response)['backstageIdentity']['token']
# Production catalog mutations are reserved for the fixed scaffolder action.
request=urllib.request.Request(base+'/api/catalog/locations',data=json.dumps({'type':'url','target':'https://github.com/example/untrusted/blob/main/template.yaml'}).encode(),headers={'Authorization':'Bearer '+token,'Content-Type':'application/json'})
try:
 urllib.request.urlopen(request)
 raise AssertionError('Users must not register arbitrary templates')
except urllib.error.HTTPError as e:
 assert e.code==403,e.code
source=root/'backstage/templates/microservice'
template=yaml.safe_load((source/'template.yaml').read_text())
template['spec']['steps']=[s for s in template['spec']['steps'] if s['id'] in ['context','skeleton','infrastructure']]
template['spec']['output']={}
files=[{'path':str(p.relative_to(source)),'base64Content':base64.b64encode(p.read_bytes()).decode()} for p in source.rglob('*') if p.is_file()]
payload={'template':template,'values':{'name':'demo','team':'piloto','size':'pequena','description':'Prueba real: "comillas" y PostgreSQL'},'directoryContents':files}
request=urllib.request.Request(base+'/api/scaffolder/v2/dry-run',data=json.dumps(payload).encode(),headers={'Authorization':'Bearer '+token,'Content-Type':'application/json'})
try:
 with urllib.request.urlopen(request,timeout=60) as response:result=json.load(response)
except urllib.error.HTTPError as e:
 print(e.read().decode());raise
output=root/'.generated/scaffolder';output.mkdir(parents=True,exist_ok=True)
for file in result['directoryContents']:
 p=output/file['path'];assert p.resolve().is_relative_to(output.resolve());p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(base64.b64decode(file['base64Content']))
registry=json.loads((output/'gitops/service.json').read_text());assert registry['name']=='gp-piloto-demo'
component=yaml.safe_load((output/'service/catalog-info.yaml').read_text());assert component['metadata']['description']==payload['values']['description']
print('Backstage dry-run passed:',len(result['directoryContents']),'rendered files; no GitHub/AWS writes.')
