#!/bin/bash
DATA_PATH="/home/hluser/hl/data"

# Folders to exclude from pruning
# Example: EXCLUDES=("visor_child_stderr" "rate_limited_ips" "node_logs")
EXCLUDES=("visor_child_stderr")

# Log startup for debugging
echo "$(date): Prune script started" >> /proc/1/fd/1

# Check if data directory exists
if [ ! -d "$DATA_PATH" ]; then
    echo "$(date): Error: Data directory $DATA_PATH does not exist." >> /proc/1/fd/1
    exit 1
fi

echo "$(date): Starting pruning process at $(date)" >> /proc/1/fd/1

# Get directory size before pruning
size_before=$(du -sh "$DATA_PATH" | cut -f1)
files_before=$(find "$DATA_PATH" -type f | wc -l)
echo "$(date): Size before pruning: $size_before with $files_before files" >> /proc/1/fd/1

# Build the -prune arguments for excluding directories
PRUNE_ARGS=()
for dir in "${EXCLUDES[@]}"; do
    PRUNE_ARGS+=(-path "*/$dir" -prune -o)
done

HOURS=$((60*24))
find "$DATA_PATH" -mindepth 1 "${PRUNE_ARGS[@]}" -type f -mmin +$HOURS -exec rm {} +

# Get directory size after pruning
size_after=$(du -sh "$DATA_PATH" | cut -f1)
files_after=$(find "$DATA_PATH" -type f | wc -l)
echo "$(date): Size after pruning: $size_after with $files_after files" >> /proc/1/fd/1
echo "$(date): Pruning completed. Reduced from $size_before to $size_after ($(($files_before - $files_after)) files removed)." >> /proc/1/fd/1
