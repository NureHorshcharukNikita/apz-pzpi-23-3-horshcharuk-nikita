#!/usr/bin/env bash
set -euo pipefail

INGRESS_URL="https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
DOCKERFILE_DIR="${REPO_ROOT}/Server/Elevate"
KIND_CONFIG="${SCRIPT_DIR}/kind-3nodes.yaml"

usage() {
  echo "Usage: $0 up [--cluster NAME] [--skip-ingress]" >&2
  echo "       $0 down [--cluster NAME]" >&2
  echo "Env: CLUSTER_NAME, SKIP_INGRESS=1 (for up)" >&2
  exit 1
}

require_tools() {
  for c in docker kind kubectl; do
    command -v "$c" >/dev/null 2>&1 || { echo "$c not found in PATH" >&2; exit 1; }
  done
}

cluster_exists() {
  kind get clusters 2>/dev/null | grep -qx "$1"
}

cmd_up() {
  local cluster="$1"
  local skip_ingress="$2"
  require_tools

  if ! cluster_exists "$cluster"; then
    kind create cluster --name "$cluster" --config "$KIND_CONFIG"
  fi

  kubectl cluster-info --context "kind-${cluster}"

  if [[ "$skip_ingress" != "1" ]]; then
    kubectl apply -f "$INGRESS_URL"
    kubectl patch deployment ingress-nginx-controller -n ingress-nginx --type strategic --patch '
spec:
  template:
    spec:
      nodeSelector:
        kubernetes.io/os: linux
        ingress-ready: "true"
'
    kubectl wait --namespace ingress-nginx \
      --for=condition=ready pod \
      --selector=app.kubernetes.io/component=controller \
      --timeout=180s
  fi

  docker build -t elevate-api:latest -f "${DOCKERFILE_DIR}/Dockerfile" "$DOCKERFILE_DIR"
  kind load docker-image elevate-api:latest --name "$cluster"

  kubectl apply -f "${SCRIPT_DIR}/00-namespace.yaml"
  kubectl apply -f "${SCRIPT_DIR}/10-sqlserver.yaml"
  kubectl apply -f "${SCRIPT_DIR}/20-elevate-api.yaml"
  if [[ "$skip_ingress" != "1" ]]; then
    kubectl apply -f "${SCRIPT_DIR}/40-ingress-optional.yaml"
  fi

  kubectl wait --namespace elevate --for=condition=ready pod --all --timeout=300s
}

cmd_down() {
  local cluster="$1"
  command -v kind >/dev/null 2>&1 || { echo "kind not found in PATH" >&2; exit 1; }
  if cluster_exists "$cluster"; then
    kind delete cluster --name "$cluster"
  fi
}

main() {
  [[ $# -ge 1 ]] || usage
  local sub="$1"
  shift

  case "$sub" in
    up)
      local cluster="${CLUSTER_NAME:-elevate}"
      local skip="${SKIP_INGRESS:-0}"
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --cluster)
            [[ $# -ge 2 ]] || usage
            cluster="$2"
            shift 2
            ;;
          --skip-ingress)
            skip=1
            shift
            ;;
          *)
            usage
            ;;
        esac
      done
      cmd_up "$cluster" "$skip"
      ;;
    down)
      local cluster="${CLUSTER_NAME:-elevate}"
      while [[ $# -gt 0 ]]; do
        case "$1" in
          --cluster)
            [[ $# -ge 2 ]] || usage
            cluster="$2"
            shift 2
            ;;
          *)
            usage
            ;;
        esac
      done
      cmd_down "$cluster"
      ;;
    *)
      usage
      ;;
  esac
}

main "$@"
