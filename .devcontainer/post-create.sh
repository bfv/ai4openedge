#!/bin/bash

set -euo pipefail

uv_bin="$HOME/.local/bin/uv"

if [[ ! -x "$uv_bin" ]]; then
  curl -LsSf https://astral.sh/uv/install.sh -o /tmp/uv-install.sh
  sh /tmp/uv-install.sh
fi
