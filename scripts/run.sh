SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
BASE_PATH="$SCRIPT_DIR/../"
cd ${BASE_PATH} || echo "${BASE_PATH} not found"

go run cmd/api.go "$@"
