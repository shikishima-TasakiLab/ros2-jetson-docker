#!/bin/bash

set -e

DEFAULT_USER_ID=0

if [ -v USER_ID ] && [ "$USER_ID" != "$DEFAULT_USER_ID" ]; then
    usermod --uid $USER_ID ros2
    find /home/ros2 -user $DEFAULT_USER_ID -exec chown -h $USER_ID {} \;
fi

cd /home/ros2
source /opt/ros/dashing/setup.bash

if [ -z "$1" ]; then
    su ros2 -c "/bin/bash"
else
    su ros2 -c "exec \"$@\""
fi
