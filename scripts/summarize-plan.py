import json,sys
from collections import Counter
plan=json.load(open(sys.argv[1]))
counts=Counter('/'.join(x['change']['actions']) for x in plan.get('resource_changes',[]) if x['mode']=='managed')
print(json.dumps({'actions':dict(counts),'complete':plan.get('complete'),'applyable':plan.get('applyable'),'note':'Plan only; provisioning permissions and runtime integrations are not proven.'},indent=2))
if any('delete' in k or 'update' in k for k in counts):
    raise SystemExit('Unexpected existing-resource changes. Review before proceeding.')
