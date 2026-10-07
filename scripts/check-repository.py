"""Repository checks without AWS credentials or network calls."""
from pathlib import Path
import re
root = Path(__file__).resolve().parents[1]
errors = []
for p in root.rglob("*"):
    if not p.is_file() or any(x in p.parts for x in (".git", ".terraform", "__pycache__")):
        continue
    text = p.read_text(errors="replace")
    rel = p.relative_to(root)
    if re.search(r"(?:AKIA|ASIA)[A-Z0-9]{16}|-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----", text):
        errors.append(f"Credential-like content: {rel}")
    if p.suffix == ".tf" and re.search(r"507982838700|soportedalc|ds[.]abril", text, re.I):
        errors.append(f"Inherited reference resource dependency: {rel}")
for p in (root / ".github/workflows").glob("*.yml"):
    if re.search(r"configure-aws-credentials|id-token:|terraform (?:apply|destroy)|kubectl apply|helm (?:upgrade|install)", p.read_text()):
        errors.append(f"Deployment capability is not allowed in preparation CI: {p.name}")
for p in (root / "terraform/tests").glob("*.tftest.hcl"):
    text = p.read_text()
    if 'mock_provider "aws"' not in text or re.search(r"command\s*=\s*apply", text):
        errors.append(f"Test must use a mocked AWS provider and plan only: {p.name}")
if errors:
    raise SystemExit("\n".join(errors))
print("Repository checks passed: no inherited resource references, obvious keys or deployment workflows.")
