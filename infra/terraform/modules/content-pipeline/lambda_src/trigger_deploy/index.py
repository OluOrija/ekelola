import os, json, urllib.request

import boto3
sm = boto3.client("secretsmanager")

OWNER  = os.environ["GITHUB_OWNER"]
REPO   = os.environ["GITHUB_REPO"]
WFNAME = os.environ["WORKFLOW_NAME"]
SECRET = os.environ["GITHUB_PAT_SEC"]

def handler(event, context):
    # Read PAT
    sec = sm.get_secret_value(SecretId=SECRET)
    token = sec.get("SecretString") or ""
    if not token:
        raise RuntimeError("Missing GitHub PAT secret string")

    url = f"https://api.github.com/repos/{OWNER}/{REPO}/actions/workflows/{WFNAME}/dispatches"
    payload = json.dumps({"ref": "main", "inputs": {"reason": "content-update"}}).encode("utf-8")
    req = urllib.request.Request(url, data=payload, method="POST", headers={
        "Authorization": f"token {token}",
        "Accept": "application/vnd.github+json",
        "User-Agent": "ekelola-content-trigger"
    })

    try:
        with urllib.request.urlopen(req) as resp:
            if resp.status not in (200, 204):
                body = resp.read().decode("utf-8", errors="replace")
                raise RuntimeError(f"GitHub dispatch failed: {resp.status} {body}")
    except Exception as e:
        raise

    return {"ok": True}
