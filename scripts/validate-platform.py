"""Render Helm, execute Crossplane's function pipeline and validate real provider schemas."""
from pathlib import Path
import hashlib,json,os,subprocess,urllib.request
import yaml,jsonschema
ROOT=Path(__file__).resolve().parents[1];OUT=ROOT/'.generated/platform';OUT.mkdir(parents=True,exist_ok=True)
CLI=os.environ.get('CROSSPLANE_BIN','crossplane')
def run(*args):return subprocess.check_output(args,text=True,cwd=ROOT)
for chart in ['bootstrap','config']:
 print(run('helm','lint',f'platform/charts/{chart}').strip())
 text=run('helm','template','goldenpath',f'platform/charts/{chart}','-f','tests/fixtures/platform.yaml');(OUT/f'{chart}.yaml').write_text(text)
 manifests=[r for r in yaml.safe_load_all(text) if r]
 assert all(r.get('apiVersion') and r.get('kind') and r.get('metadata',{}).get('name') for r in manifests)
 assert len({(r['apiVersion'],r['kind'],r['metadata'].get('namespace'),r['metadata']['name']) for r in manifests})==len(manifests)
 if chart=='config':resources=manifests
composition=next(x for x in resources if x['kind']=='Composition');(OUT/'composition.yaml').write_text(yaml.safe_dump(composition))
function=next(x for x in resources if x['kind']=='Function');(OUT/'functions.yaml').write_text(yaml.safe_dump(function))
xrd=next(x for x in resources if x['kind']=='CompositeResourceDefinition');(OUT/'xrd.yaml').write_text(yaml.safe_dump(xrd))
for item in json.loads((ROOT/'platform/schemas.lock.json').read_text()):
 data=urllib.request.urlopen(item['url'],timeout=30).read();assert hashlib.sha256(data).hexdigest()==item['sha256'];(OUT/item['name']).write_bytes(data)
crd=yaml.safe_load((OUT/'rds-crd.yaml').read_text());schema=next(v for v in crd['spec']['versions'] if v['name']=='v1beta1')['schema']['openAPIV3Schema']
pc=yaml.safe_load((OUT/'providerconfig-crd.yaml').read_text());pcschema=pc['spec']['versions'][0]['schema']['openAPIV3Schema'];jsonschema.validate(next(x for x in resources if x['kind']=='ClusterProviderConfig'),pcschema)
for size,instance in [('pequena','db.t4g.micro'),('mediana','db.t4g.small')]:
 xr={'apiVersion':'platform.goldenpath.io/v1alpha1','kind':'PostgreSQLInstance','metadata':{'name':'gp-piloto-demo','namespace':'equipo-piloto','labels':{'platform.goldenpath.io/owner':'piloto','platform.goldenpath.io/cost-center':'mati-platform','backstage.io/kubernetes-id':'gp-piloto-demo'}},'spec':{'size':size}}
 (OUT/'xr.yaml').write_text(yaml.safe_dump(xr))
 rendered=run(CLI,'render',str(OUT/'xr.yaml'),str(OUT/'composition.yaml'),str(OUT/'functions.yaml'),'--crossplane-version=v2.4.2','--include-full-xr','--timeout=90s')
 (OUT/f'rendered-{size}.yaml').write_text(rendered)
 mr=next(x for x in yaml.safe_load_all(rendered) if x['kind']=='Instance');jsonschema.validate(mr,schema)
 assert mr['spec']['forProvider']['instanceClass']==instance
 assert mr['spec']['writeConnectionSecretToRef']['name']=='gp-piloto-demo-connection'
 assert mr['spec']['forProvider']['passwordSecretRef']['name']=='gp-piloto-demo-password'
 assert not mr['spec']['forProvider']['publiclyAccessible']
 assert mr['spec']['providerConfigRef']=={'name':'goldenpath','kind':'ClusterProviderConfig'}
 assert mr['metadata']['namespace']=='equipo-piloto'
 print(f'PASS: composition {size}, connection Secret contract and provider v2.8.1 schema')
print('PASS: Helm charts and provider configuration')
