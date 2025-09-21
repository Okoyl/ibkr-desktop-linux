#!/bin/env bash
set -euo pipefail

WINEPREFIX=~/.wine-ibkr

cd "$WINEPREFIX/drive_c/ntws"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR_WIN="$(winepath -w "$SCRIPT_DIR")"
LIB_DIR_WIN="${SCRIPT_DIR_WIN}\\lib"
APP_CONFIG_DIR_WIN="${SCRIPT_DIR_WIN}\\data"
VMOPTS_FILE_WIN="${SCRIPT_DIR_WIN}\\ntws.vmoptions"

build_classpath() {
  local dir="$1" jar jars=()
  shopt -s nullglob
  for jar in "$dir"/*.jar; do
    jars+=("$(winepath -w "$jar")")
  done
  shopt -u nullglob
  local IFS=';'
  echo "${jars[*]-}"
}

CLASSPATH="$(build_classpath "$SCRIPT_DIR/lib")"
if [[ -z "$CLASSPATH" ]]; then
  echo "No jars found in $SCRIPT_DIR/lib" >&2
  exit 1
fi

JAVA_EXE_PATH="${JAVA_EXE_PATH:-}"
if [[ -z "$JAVA_EXE_PATH" ]]; then
  JAVA_EXE_PATH="$(wine cmd.exe /c "where java.exe" 2>/dev/null | tr -d '\r' | head -n 1 || true)"
fi
if [[ -z "$JAVA_EXE_PATH" ]]; then
  echo "Unable to locate java.exe; set JAVA_EXE_PATH." >&2
  exit 1
fi

JAVA_OPTS=(
  --add-opens=java.desktop/javax.swing=ALL-UNNAMED
  --add-opens=jdk.management/com.sun.management.internal=ALL-UNNAMED
)
if [[ -f "$SCRIPT_DIR/ntws.vmoptions" ]]; then
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%$'\r'}"
    [[ -z "${line//[[:space:]]/}" ]] && continue
    [[ "$line" == \#* ]] && continue
    JAVA_OPTS+=("$line")
  done < "$SCRIPT_DIR/ntws.vmoptions"
fi

JAVA_LIB_PATH_WIN="${LIB_DIR_WIN};${SCRIPT_DIR_WIN}\\lib\\qt\\bin;${SCRIPT_DIR_WIN}\\.install4j"
SYS_PROPS=(
  "-Djava.library.path=${JAVA_LIB_PATH_WIN}"
  "-DvmOptionsPath=${VMOPTS_FILE_WIN}"
  "-DinstallDir=${SCRIPT_DIR_WIN}"
  "-DappConfigDir=${APP_CONFIG_DIR_WIN}"
  "-DexeName=ntws"
  "-DbrandingId=ntws"
  "-DproductName=IBKR Desktop"
  "-DcompanyName=Interactive Brokers LLC"
)

MAIN_CLASS="launcher.Main"
LAUNCH_ARGS=("$@")
if [[ ${#LAUNCH_ARGS[@]} -eq 0 ]]; then
  LAUNCH_ARGS=("${SCRIPT_DIR_WIN}")
fi

export WINEPATH="${JAVA_LIB_PATH_WIN}"

exec wine "$JAVA_EXE_PATH" "${JAVA_OPTS[@]}" -cp "$CLASSPATH" "${SYS_PROPS[@]}" "$MAIN_CLASS" "${LAUNCH_ARGS[@]}"
