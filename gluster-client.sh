#!/bin/bash
set -e

sleep 10

mkdir -p mnt/gv0 # Prepare the mount point from client to server

FROM_HOST_MACHINE="/data-from-host/"
DETECT_CHANGE_AT_FOLDER="/data-from-host"


TO_MOUNT_PATH="/mnt/gv0/"
MOUNT_POINT="/mnt/gv0"


if mountpoint -q $MOUNT_POINT;then
    echo "/mnt/gv0 is already a mountpoint. Verifying GlusterFS functionality..."

    ls -la $MOUNT_POINT || echo "Warning: mount appears broken or empty."

else
    echo "Attempting to mount GlusterFS volume..."
    until mount -t glusterfs 10.10.10.11:/gv0 $MOUNT_POINT; do
        echo "$(date) Mount failed. Retrying in 5 seconds..."
        sleep 5
    done

fi

if ! mountpoint -q $MOUNT_POINT;then
    echo "Error: /mnt/gv0 is not a valid mountpoint after mount attempt."
    exit 1
fi

rsync -av $FROM_HOST_MACHINE $TO_MOUNT_PATH #Cp from the /data-from-host to /mnt/gv0 

echo "Mounted GlusterFS volume successfully."

# Run a background inotify sync loop (or use lsyncd)
inotifywait -m -r -e modify,create,delete,move $DETECT_CHANGE_AT_FOLDER |
while read -r path _ file; do
    rsync -av --delete $FROM_HOST_MACHINE $TO_MOUNT_PATH
done &

tail -f /dev/null