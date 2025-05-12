```markdown
# Project Folder Structure

```
gluster-docker/
├── readme.md
├── docker-compose.yml
├── Dockerfile.gluster-server
|── Dockerfile.s3sync
|── storages/
    |── brick1/*    #local data from host machine
    |── brick2/*    #local data from host machine
    |── brick3/*    #local data from host machine
├── entrypoint.sh
├── s3sync-entrypoint.sh


# Create brick directoroty
    gluster-server-1) BRICK_PATH="/data/storages/gluster1/brick";;
    gluster-server-2) BRICK_PATH="/data/storages/gluster2/brick";;
    gluster-server-3) BRICK_PATH="/data/storages/gluster3/brick";;

# Create gluster volume
            gluster volume create gv0 replica 3\
            10.10.10.11:/data/storages/gluster1 \
            10.10.10.12:/data/storages/gluster2 \
            10.10.10.13:/data/storages/gluster3 force