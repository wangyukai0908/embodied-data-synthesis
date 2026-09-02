START=0
END=10

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
LIBERO_ROOT="${LIBERO_ROOT:?Set LIBERO_ROOT to your LIBERO checkout}"
LIBERO_CONFIG_PATH="${LIBERO_CONFIG_PATH:?Set LIBERO_CONFIG_PATH to your LIBERO config}"

export PYTHONPATH="${PROJECT_ROOT}:${LIBERO_ROOT}${PYTHONPATH:+:${PYTHONPATH}}"
export MUJOCO_GL="${MUJOCO_GL:-egl}"
export LIBERO_CONFIG_PATH
cd "$PROJECT_ROOT"

python evaluation/libero/client.py \
    --libero-benchmark libero_10 \
    --port 29056 \
    --test-num 50 \
    --task-range $START $END \
    --out-dir outputs/libero
