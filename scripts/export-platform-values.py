"""Export only non-secret Terraform outputs into local Helm values."""
from pathlib import Path
import json,os,subprocess,urllib.parse
import yaml
root=Path(__file__).resolve().parents[1]
tf=os.environ.get('TERRAFORM_BIN','terraform')
config=json.loads(subprocess.check_output([tf,f'-chdir={root}/terraform','output','-json','platform_configuration'],text=True))
if not config['portalUrl'].startswith('https://') or not config['backstage']['image'].endswith(':v1'):raise SystemExit('Enable and apply the HTTPS portal edge and review image versions first.')
config.update({'stage':'all','awsResources':True})
path=root/'.generated/platform-values.yaml';path.parent.mkdir(parents=True,exist_ok=True);path.write_text(yaml.safe_dump(config,sort_keys=False));path.chmod(0o600)
print(path)
