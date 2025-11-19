#!/bin/bash
set -e

# PBTS Startup Script
# Runs experiments on first startup, then starts the tracker

RESULTS_DIR="/app/results"
EXPERIMENTS_DONE_FLAG="$RESULTS_DIR/.experiments_done"

# Create results directory if it doesn't exist
mkdir -p "$RESULTS_DIR"

# Check if experiments have already been run
if [ ! -f "$EXPERIMENTS_DONE_FLAG" ]; then
    echo "============================================================"
    echo "Running PBTS experiments for the first time..."
    echo "Results will be saved to $RESULTS_DIR"
    echo "============================================================"

    # Run experiments with default settings (can be overridden via env vars)
    python experiments/run_all_experiments.py \
        --output-dir "$RESULTS_DIR" \
        --receipt-iterations "${RECEIPT_ITERATIONS:-100}" \
        --receipt-batch-sizes ${RECEIPT_BATCH_SIZES:-10 25 50 100} \
        --tee-iterations "${TEE_ITERATIONS:-50}" \
        --tee-verify-iterations "${TEE_VERIFY_ITERATIONS:-3}" \
        || true  # Don't fail startup if experiments fail

    # Create flag file to indicate experiments are done
    echo "$(date)" > "$EXPERIMENTS_DONE_FLAG"

    echo ""
    echo "============================================================"
    echo "Experiments completed! Results saved to $RESULTS_DIR"
    echo "Access results via: http://localhost:8000/experiments/results"
    echo "============================================================"
    echo ""
else
    echo "============================================================"
    echo "Experiments already run on: $(cat $EXPERIMENTS_DONE_FLAG)"
    echo "To re-run experiments, delete: $EXPERIMENTS_DONE_FLAG"
    echo "Or access results via: http://localhost:8000/experiments/results"
    echo "============================================================"
    echo ""
fi

# Start the tracker
echo "Starting PBTS tracker..."
exec python tracker.py
