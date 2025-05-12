#!/bin/bash

set -e

HOSTNAME=$(hostname)
BRICK_PATH=""
case "$HOSTNAME" in
    gluster-server-1) BRICK_PATH="/data/brick1";;
    gluster-server-2) BRICK_PATH="/data/brick2";;
    gluster-server-3) BRICK_PATH="/data/brick3";;
    *) echo "[ERROR] Unknown host: $HOSTNAME" && exit 1;;
esac

# Prepare brick directory
mkdir -p "$BRICK_PATH"
chown -R nobody:nogroup "$BRICK_PATH"

# Start Gluster daemon
/usr/sbin/glusterd --log-level=DEBUG &
sleep 5  # Give it time to start

# Gluster peer probe and volume creation (only on server 1)
if [ "$HOSTNAME" = "gluster-server-1" ]; then
    echo "[INFO] Probing peers..."
    gluster peer probe gluster-server-2 || echo "[WARN] Already probed gluster-server-2"
    gluster peer probe gluster-server-3 || echo "[WARN] Already probed gluster-server-3"
    sleep 10  # Allow peer connection to stabilize

    # Check and create volume
    if ! gluster volume info gv0 > /dev/null 2>&1; then
        echo "[INFO] Creating Gluster volume gv0..."
        gluster volume create gv0 replica 3 \
            gluster-server-1:/data/brick1 \
            gluster-server-2:/data/brick2 \
            gluster-server-3:/data/brick3 force

        gluster volume set gv0 storage.owner-uid "$(id -u nobody)"
        gluster volume set gv0 storage.owner-gid "$(id -g nobody)"
        gluster volume start gv0
    else
        echo "[INFO] Volume gv0 already exists."
    fi
fi

# Keep the container running
tail -f /dev/null
