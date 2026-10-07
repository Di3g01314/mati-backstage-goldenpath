"""Validate data from the PR using policy code from the base branch; never execute PR code."""
import argparse,base64,json,re,subprocess
from pathlib import Path
import yaml
ROOT=Path(__file__).resolve().parents[1]
def validate(files,teams):
    if len(files)!=2: raise ValueError('A request must add exactly database.yaml and service.json')
    parent={str(Path(p).parent) for p in files}
    if len(parent)!=1: raise ValueError('One service per request')
    path=next(iter(parent));match=re.fullmatch(r'gitops/tenants/([a-z][a-z0-9-]*)/(gp-piloto-[a-z][a-z0-9-]{2,19})',path)
    if not match: raise ValueError('Invalid request path')
    team,name=match.groups();cfg=teams[team]
    if set(files)!={path+'/database.yaml',path+'/service.json'}: raise ValueError('Unexpected files')
    registry=json.loads(files[path+'/service.json'])
    expected={'name':name,'namespace':cfg['namespace'],'team':team,'repoURL':f"https://github.com/{cfg['githubOwner']}/{name}"}
    if registry!=expected: raise ValueError('Service registry may not change namespace, repository or team')
    database=yaml.safe_load(files[path+'/database.yaml'])
    size=database.get('spec',{}).get('size')
    if size not in ('pequena','mediana'): raise ValueError('Only pequena/mediana are allowed')
    expected_db={'apiVersion':'platform.goldenpath.io/v1alpha1','kind':'PostgreSQLInstance','metadata':{'name':name,'namespace':cfg['namespace'],'labels':{'platform.goldenpath.io/owner':cfg['owner'],'platform.goldenpath.io/cost-center':cfg['costCenter'],'backstage.io/kubernetes-id':name}},'spec':{'size':size}}
    if database!=expected_db: raise ValueError('Database differs from the fixed platform contract')
    return name

def github(path):
    return json.loads(subprocess.check_output(['gh','api',path],text=True))
if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--repo',required=True);parser.add_argument('--pr',required=True,type=int);parser.add_argument('--sha',required=True);args=parser.parse_args()
    if not re.fullmatch(r'[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+',args.repo) or not re.fullmatch('[0-9a-f]{40}',args.sha): raise SystemExit('Invalid repository/SHA')
    pr=github(f'repos/{args.repo}/pulls/{args.pr}')
    if pr['head']['sha']!=args.sha or pr['base']['ref']!='main' or pr['head']['repo']['full_name']!=args.repo: raise SystemExit('Unexpected PR source')
    changed=github(f'repos/{args.repo}/pulls/{args.pr}/files?per_page=100')
    if len(changed)!=2 or any(f['status']!='added' for f in changed): raise SystemExit('Only a new service request can merge automatically')
    files={}
    for f in changed:
        if f.get('changes',0)>150 or not re.fullmatch(r'gitops/tenants/piloto/gp-piloto-[a-z][a-z0-9-]{2,19}/(database.yaml|service.json)',f['filename']): raise SystemExit('Forbidden change')
        content=github(f"repos/{args.repo}/contents/{f['filename']}?ref={args.sha}")
        if content['size']>8192: raise SystemExit('Request too large')
        files[f['filename']]=base64.b64decode(content['content']).decode()
    print('Valid GoldenPath request:',validate(files,json.loads((ROOT/'config/teams.json').read_text())))
