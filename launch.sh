#! /usr/bin/env bash
#set -e

# Enable local Docker X11 access
xhost +local:docker

# Xauth setup
XAUTH=/tmp/.docker.xauth
touch "$XAUTH"
xauth nlist "$DISPLAY" | sed -e 's/^..../ffff/' | xauth -f "$XAUTH" nmerge -
chmod 644 "$XAUTH"

# Run container
docker run -it --rm \
  --name viber \
  -e DISPLAY="$DISPLAY" \
  -e PULSE_SERVER=unix:/run/user/1000/pulse/native \
  -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
  -v "$XAUTH":"$XAUTH" -e XAUTHORITY="$XAUTH" \
  -v "$HOME/.ViberPC:/home/viberuser/.ViberPC" \
  -v /run/user/"$(id -u)"/pulse:/run/user/1000/pulse \
  --device /dev/snd \
  --group-add "$(getent group audio | cut -d: -f3)" \
  viber-docker

