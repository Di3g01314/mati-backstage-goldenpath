"""Called only by the guarded bootstrap script. Do not print secret values."""
import base64,json,os,subprocess,sys
import yaml
if os.environ.get('GOLDENPATH_ALLOW_DEPLOY')!='1':raise SystemExit('Deployment disabled')
config=yaml.safe_load(open(sys.argv[1]));kubeconfig=sys.argv[2]
account=subprocess.check_output(['aws','sts','get-caller-identity','--query','Account','--output','text'],text=True).strip()
if account!=os.environ.get('EXPECTED_AWS_ACCOUNT') or account!=config['aws']['accountId']:raise SystemExit('Account mismatch')
raw=subprocess.check_output(['aws','secretsmanager','get-secret-value','--region',config['aws']['region'],'--secret-id',config['githubSecretArn'],'--query','SecretString','--output','text'],text=True)
secret=json.loads(raw)
for key in ['GITHUB_TOKEN','GITHUB_CLIENT_ID','GITHUB_CLIENT_SECRET','AUTH_SESSION_SECRET']:
 if not secret.get(key):raise SystemExit(f'Missing required secret field {key}')
resource={'apiVersion':'v1','kind':'Secret','metadata':{'name':'github-repositories','namespace':'argocd','labels':{'argocd.argoproj.io/secret-type':'repo-creds'}},'type':'Opaque','data':{k:base64.b64encode(v.encode()).decode() for k,v in {'type':'git','url':'https://github.com/'+config['git']['owner'],'username':'x-access-token','password':secret['GITHUB_TOKEN']}.items()}}
subprocess.run(['kubectl','--kubeconfig',kubeconfig,'apply','--server-side','--field-manager=goldenpath-bootstrap','-f','-'],input=json.dumps(resource),text=True,check=True,stdout=subprocess.DEVNULL)
print('Initial Argo CD repository credentials configured.')
