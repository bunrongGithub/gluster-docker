#!/bin/bash

set -e

POSSIBLE_PATHS=(
    "/mnt/gluster-server-1"
    "/mnt/gluster-server-2"
    "/mnt/gluster-server-3"
)

S3_BUCKET=${AWS_S3_BUCKET}
REGION=${AWS_REGION}
SKIP_FOLDER=".glusterfs"

MOUNT_PATH=""
for path in "${POSSIBLE_PATHS[@]}"; do
    if [ -d "$path" ]; then
        echo "[INFO] Using path: $path"
        MOUNT_PATH="$path"
        break
    fi
done

if [ -z "$MOUNT_PATH" ]; then
    echo "[ERROR] No Gluster brick path available"
    exit 1
fi

echo "[INFO] Monitoring $MOUNT_PATH for changes (excluding $SKIP_FOLDER/)"

while true; do
    # Use inotifywait to monitor changes (excluding the SKIP_FOLDER)
    inotifywait -r -e modify,create,delete,move --exclude "${SKIP_FOLDER}/.*" "$MOUNT_PATH"
    
    # Sync only when changes are detected
    echo "[INFO] Changes detected. Syncing to S3..."
    aws s3 sync "$MOUNT_PATH" "s3://${S3_BUCKET}" --exclude "${SKIP_FOLDER}/*"
    
    # Optional: Add a small delay to avoid rapid successive syncs
    sleep 5
done