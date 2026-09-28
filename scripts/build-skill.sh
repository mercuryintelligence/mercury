#!/usr/bin/env bash
set -euo pipefail
# Deterministic build of skills/using-mercury.skill from plugins/mercury/skills/using-mercury/.
# Uses python3 stdlib (zipfile) for portability: fixed epoch mtime, sorted filelist,
# no extra attributes, so successive builds are bit-identical.
cd "$(dirname "$0")/.."
SRC=plugins/mercury/skills/using-mercury
OUT=skills/using-mercury.skill
[ -d "$SRC" ] || { echo "missing source $SRC" >&2; exit 1; }

python3 - "$SRC" "$OUT" <<'PY'
import hashlib, os, sys, zipfile
src, out = sys.argv[1], sys.argv[2]
files = []
for root, dirs, names in os.walk(src):
    dirs.sort()
    for n in sorted(names):
        files.append(os.path.join(root, n))
files.sort()

# Deterministic zip: fixed epoch date, sorted entries, DEFLATE, no external attrs, no extras.
with zipfile.ZipFile(out, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=6) as z:
    for f in files:
        # arcname strips the "skills/" prefix, keeping "using-mercury/..." as the top-level dir.
        arcname = os.path.relpath(f, os.path.dirname(src))
        info = zipfile.ZipInfo(filename=arcname, date_time=(1980, 1, 1, 0, 0, 0))
        info.compress_type = zipfile.ZIP_DEFLATED
        info.external_attr = 0o644 << 16
        with open(f, "rb") as fh:
            z.writestr(info, fh.read(), compress_type=zipfile.ZIP_DEFLATED)

size = os.path.getsize(out)
sha = hashlib.sha256(open(out, "rb").read()).hexdigest()
print(f"built {out} ({size} bytes)")
print(f"sha256: {sha}")
PY
