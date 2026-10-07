import importlib.util,json,unittest,copy
from pathlib import Path
import yaml
ROOT=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('policy',ROOT/'scripts/validate-request.py');policy=importlib.util.module_from_spec(spec);spec.loader.exec_module(policy)
class RequestTests(unittest.TestCase):
 def setUp(self):
  self.teams=json.loads((ROOT/'config/teams.json').read_text());self.path='gitops/tenants/piloto/gp-piloto-demo';self.registry={'name':'gp-piloto-demo','namespace':'equipo-piloto','team':'piloto','repoURL':'https://github.com/Di3g01314/gp-piloto-demo'}
  self.db={'apiVersion':'platform.goldenpath.io/v1alpha1','kind':'PostgreSQLInstance','metadata':{'name':'gp-piloto-demo','namespace':'equipo-piloto','labels':{'platform.goldenpath.io/owner':'piloto','platform.goldenpath.io/cost-center':'mati-platform','backstage.io/kubernetes-id':'gp-piloto-demo'}},'spec':{'size':'pequena'}}
 def files(self):return {self.path+'/database.yaml':yaml.safe_dump(self.db),self.path+'/service.json':json.dumps(self.registry)}
 def test_valid(self):self.assertEqual(policy.validate(self.files(),self.teams),'gp-piloto-demo')
 def test_missing_cost(self):
  del self.db['metadata']['labels']['platform.goldenpath.io/cost-center']
  with self.assertRaises(ValueError):policy.validate(self.files(),self.teams)
 def test_large_size(self):
  self.db['spec']['size']='grande'
  with self.assertRaises(ValueError):policy.validate(self.files(),self.teams)
 def test_override_composition(self):
  self.db['spec']['crossplane']={'compositionRef':{'name':'evil'}}
  with self.assertRaises(ValueError):policy.validate(self.files(),self.teams)
 def test_other_namespace(self):
  self.registry['namespace']='argocd'
  with self.assertRaises(ValueError):policy.validate(self.files(),self.teams)
 def test_extra_file(self):
  files=self.files();files['.github/workflows/evil.yml']='test'
  with self.assertRaises(ValueError):policy.validate(files,self.teams)
 def test_other_repo(self):
  self.registry['repoURL']='https://github.com/Di3g01314/mati-backstage-goldenpath'
  with self.assertRaises(ValueError):policy.validate(self.files(),self.teams)
if __name__=='__main__':unittest.main()
