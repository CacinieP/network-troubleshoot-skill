#!/usr/bin/env bash
#
# Adapter <-> installer parity check.
#
# Guards against the "documented but not installable" bug class: an adapter
# exists in adapters/ and in the README, but neither install.sh nor
# install.ps1 can install it (see the hermes incident in v0.2.0).
#
# Fails when:
#   1. no installer case branch dispatches to an adapter (checked via the
#      branch label, so removing the dispatch fails even if a leftover
#      install_*() function still references the file)
#   2. an installer references a source file that does not exist
#   3. an adapter directory is not documented in README.md / README_CN.md
#
# Usage: bash scripts/check-adapters.sh   (also runs in CI)

set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

errors=0
fail() { echo "check-adapters: FAIL: $*"; errors=1; }

# Adapter directory -> case label in the installers. Directories whose label
# differs from the directory name must be listed here; an unmapped directory
# fails the check, which forces a conscious update when adding an adapter.
label_for_dir() {
  case "$1" in
    github-copilot) echo "copilot" ;;
    *)              echo "$1" ;;
  esac
}

# --- collect installer dispatch labels ---------------------------------------
# install.sh:    "  hermes)               install_hermes ;;"
# install.ps1:   '    "hermes" {'
sh_labels="$(grep -oE '^  [a-z0-9|_-]+\)' install.sh | tr -d ' )' | tr '|' '\n' | sort -u)"
ps_labels="$(grep -oE '^    "[a-z0-9_-]+"' install.ps1 | tr -d '" ' | sort -u)"

# --- collect installer source references --------------------------------------
sh_refs="$(grep -oE 'download "[^"]+"' install.sh | cut -d'"' -f2 | sort -u)"
ps_refs="$(grep -oE 'Download "[^"]+"' install.ps1 | cut -d'"' -f2 | sort -u)"

# --- 1. every adapter directory has a dispatch branch in both installers -----

while IFS= read -r dir; do
  name="$(basename "$dir")"
  label="$(label_for_dir "$name")"
  grep -qxF "$label" <<<"$sh_labels" \
    || fail "adapter '$name' has no case branch ('$label') in install.sh"
  grep -qxF "$label" <<<"$ps_labels" \
    || fail "adapter '$name' has no switch branch ('$label') in install.ps1"
done < <(find adapters -mindepth 1 -maxdepth 1 -type d | sort)

# --- 2. every installer reference points at an existing file ------------------

while IFS= read -r file; do
  [ -n "$file" ] || continue
  [ -f "$file" ] || fail "installer references missing file: $file"
done < <(printf '%s\n%s\n' "$sh_refs" "$ps_refs" | sort -u)

# --- 3. every adapter file is actually downloaded by its installer ------------

while IFS= read -r file; do
  [ -n "$file" ] || continue
  grep -qxF "$file" <<<"$sh_refs" \
    || fail "$file is never downloaded by install.sh"
  grep -qxF "$file" <<<"$ps_refs" \
    || fail "$file is never downloaded by install.ps1"
done < <(find adapters -type f | sort)

# --- 4. every adapter directory is documented in both READMEs -----------------

while IFS= read -r dir; do
  name="$(basename "$dir")"
  for readme in README.md README_CN.md; do
    grep -q "$name" "$readme" \
      || fail "adapter '$name' is not documented in $readme"
  done
done < <(find adapters -mindepth 1 -maxdepth 1 -type d | sort)

# --- verdict ------------------------------------------------------------------

if [ "$errors" -ne 0 ]; then
  echo "check-adapters: parity check FAILED"
  exit 1
fi

adapter_count="$(find adapters -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
echo "check-adapters: OK — $adapter_count adapters dispatched by both installers, all references valid, all documented"
