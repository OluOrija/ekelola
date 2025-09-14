#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

rm -f validate_mdx.zip trigger_deploy.zip

( cd validate_mdx
  zip -q -r ../validate_mdx.zip index.py
)

( cd trigger_deploy
  zip -q -r ../trigger_deploy.zip index.py
)

echo "Lambda zips created at:"
ls -lh *.zip
