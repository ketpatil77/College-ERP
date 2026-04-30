#!/usr/bin/env bash
set -u

MAIN_FILE=app.py
VENV_NAME=.venv
FALLBACK_VENV_NAME=.venv-start
PYTHON_VERSION=3.11.9
PYTHON_VERSION_SHORT=3.11

PYTHON_CMD=python3

fail() {
  printf '\033[31m%s\033[0m\n' "$1"
  read -r -p "Press Enter to exit..."
  exit 1
}

check_python() {
  for candidate in python3 "python${PYTHON_VERSION_SHORT}"; do
    if command -v "$candidate" >/dev/null 2>&1; then
      current="$("$candidate" -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")' 2>/dev/null || true)"
      if [ "$current" = "$PYTHON_VERSION_SHORT" ]; then
        PYTHON_CMD="$candidate"
        return 0
      fi
    fi
  done
  return 1
}

install_python() {
  echo "Python $PYTHON_VERSION not found. Downloading and installing automatically..."
  os_name="$(uname -s)"

  if [ "$os_name" = "Darwin" ]; then
    installer="/tmp/python-${PYTHON_VERSION}.pkg"
    url="https://www.python.org/ftp/python/${PYTHON_VERSION}/python-${PYTHON_VERSION}-macos11.pkg"
    if command -v curl >/dev/null 2>&1; then
      curl -L "$url" -o "$installer" || fail "Python download failed: $url"
    elif command -v wget >/dev/null 2>&1; then
      wget "$url" -O "$installer" || fail "Python download failed: $url"
    else
      fail "Python download failed: curl or wget not found"
    fi
    sudo installer -pkg "$installer" -target / || fail "Python pkg installer failed"
    rm -f "$installer"
    PYTHON_CMD="python${PYTHON_VERSION_SHORT}"
  elif [ "$os_name" = "Linux" ]; then
    if ! command -v apt-get >/dev/null 2>&1; then
      fail "Python auto-install failed: apt-get not found"
    fi
    sudo apt-get update || fail "apt-get update failed"
    sudo apt-get install -y "python${PYTHON_VERSION_SHORT}" "python${PYTHON_VERSION_SHORT}-venv" || fail "apt-get install python${PYTHON_VERSION_SHORT} failed"
    PYTHON_CMD="python${PYTHON_VERSION_SHORT}"
  else
    fail "Python auto-install failed: unsupported OS $os_name"
  fi

  check_python || fail "Python installed but verification failed. Expected $PYTHON_VERSION_SHORT"
}

check_python || install_python

if [ ! -x "$VENV_NAME/bin/python" ]; then
  echo "Creating virtual environment $VENV_NAME..."
  "$PYTHON_CMD" -m venv "$VENV_NAME" || fail "Virtual environment creation failed"
fi

venv_python_short="$("$VENV_NAME/bin/python" -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")' 2>/dev/null || true)"
if [ "$venv_python_short" != "$PYTHON_VERSION_SHORT" ]; then
  echo "Existing $VENV_NAME is locked, broken, or not Python $PYTHON_VERSION_SHORT."
  echo "Using fallback virtual environment $FALLBACK_VENV_NAME..."
  VENV_NAME="$FALLBACK_VENV_NAME"
  if [ ! -x "$VENV_NAME/bin/python" ]; then
    "$PYTHON_CMD" -m venv "$VENV_NAME" || fail "Fallback virtual environment creation failed"
  fi
fi

# shellcheck disable=SC1091
source "$VENV_NAME/bin/activate" || fail "Virtual environment activation failed"

[ -f requirements.txt ] || fail "requirements.txt not found"

dep_report="$(python - <<'PY'
import importlib.metadata as md
import re
from pathlib import Path

for raw in Path("requirements.txt").read_text().splitlines():
    req = raw.split("#", 1)[0].strip()
    if not req:
        continue
    pkg = re.split(r"[<>=!~;\[]", req, 1)[0].strip()
    if not pkg:
        continue
    try:
        md.version(pkg)
        print(f"OK|{pkg}")
    except md.PackageNotFoundError:
        print(f"MISS|{req}")
PY
)" || fail "Dependency check failed"

missing_deps=0
while IFS='|' read -r status value; do
  [ -n "${status:-}" ] || continue
  if [ "$status" = "OK" ]; then
    echo "✓ $value already installed"
  elif [ "$status" = "MISS" ]; then
    missing_deps=1
    echo "↓ Installing $value..."
    pip install "$value" || fail "Package install failed: $value"
  fi
done <<< "$dep_report"

if [ "$missing_deps" -eq 0 ]; then
  echo "Dependencies ready. Nothing to install."
fi

echo "All ready! Launching $MAIN_FILE..."
python "$MAIN_FILE" || fail "Launch failed: $MAIN_FILE"
