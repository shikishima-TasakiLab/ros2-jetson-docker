#!/bin/bash
BUILD_DIR=$(dirname $(readlink -f $0))

ntr_arr=( $(echo $(cat /etc/nv_tegra_release) | tr -s ',' ' ') )
MAJOR_VERSION=${ntr_arr[1]}
MINOR_VERSION=${ntr_arr[4]}

docker build \
    -t jetson/ros2:${MAJOR_VERSION,,}.${MINOR_VERSION}-dashing \
    --build-arg L4T_VERSION="${MAJOR_VERSION,,}.${MINOR_VERSION}" \
    ${BUILD_DIR}/src

if [[ $? != 0 ]]; then
    echo "エラーにより中断しました．"
    exit 1
fi