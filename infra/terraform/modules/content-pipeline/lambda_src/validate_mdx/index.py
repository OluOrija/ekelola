import json, os, re, boto3, urllib.parse

s3 = boto3.client("s3")
MAX = int(os.environ.get("MAX_MDX_SIZE_BYTES", "2000000"))
LIVE_BUCKET = os.environ["LIVE_BUCKET"]
REJECTED_BUCKET = os.environ["REJECTED_BUCKET"]

REQUIRED = {"title","date","slug"}
SLUG_RE = re.compile(r"^[a-z0-9-]+$")

def parse_frontmatter(text: str) -> dict:
    # very light YAML-ish parser for simple key: value lines between --- blocks
    m = re.match(r"^---\s*([\s\S]*?)\s*---", text)
    if not m: return {}
    out = {}
    for line in m.group(1).splitlines():
        mm = re.match(r"\s*([A-Za-z0-9_-]+)\s*:\s*(.+)\s*$", line)
        if mm:
            k, v = mm.group(1), mm.group(2).strip().strip('"')
            out[k] = v
    return out

def copy_to(bucket: str, src_bucket: str, key: str):
    dst_key = f"validated/{key}" if not key.startswith("validated/") else key
    s3.copy_object(Bucket=bucket, CopySource={"Bucket": src_bucket, "Key": key}, Key=dst_key, MetadataDirective="COPY")


def delete_from(bucket: str, key: str):
    s3.delete_object(Bucket=bucket, Key=key)

def handler(event, context):
    record = (event.get("Records") or [None])[0]
    if not record:
        return {"ok": True, "msg": "no record"}

    src_bucket = record["s3"]["bucket"]["name"]
    key = urllib.parse.unquote_plus(record["s3"]["object"]["key"])
    size = int(record["s3"]["object"].get("size") or 0)

    if not key.endswith(".mdx") or size > MAX:
        copy_to(REJECTED_BUCKET, src_bucket, key)
        delete_from(src_bucket, key)
        return {"ok": False, "reason": "bad_ext_or_size"}

    obj = s3.get_object(Bucket=src_bucket, Key=key)
    text = obj["Body"].read().decode("utf-8", errors="replace")

    fm = parse_frontmatter(text)
    missing = [k for k in REQUIRED if not fm.get(k)]
    slug_ok = bool(SLUG_RE.match(fm.get("slug","")))

    if missing or not slug_ok:
        copy_to(REJECTED_BUCKET, src_bucket, key)
        delete_from(src_bucket, key)
        return {"ok": False, "reason": f"frontmatter_invalid missing={missing} slug_ok={slug_ok}"}

    copy_to(LIVE_BUCKET, src_bucket, key)
    delete_from(src_bucket, key)
    return {"ok": True, "key": key}
