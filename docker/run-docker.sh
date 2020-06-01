#!/bin/bash

CONTAINER_NAME=""
DOCKER_NET="host"

PROG_NAME=$(basename $0)
RUN_DIR=$(dirname $(readlink -f $0))

function usage_exit {
  cat <<_EOS_ 1>&2
  Usage: $PROG_NAME [OPTIONS...]
  OPTIONS:
    -h, --help              このヘルプを表示
    -c, --container         コンテナの名前を設定します．
_EOS_
    exit 1
}

while (( $# > 0 )); do
    if [[ $1 == "--help" ]] || [[ $1 == "-h" ]]; then
        usage_exit
    elif [[ $1 == "--container" ]] || [[ $1 == "-c" ]]; then
        containers="$(docker ps | grep $2)"
        if [[ ${containers} != "" ]]; then
            echo 'コンテナ名が重複します．'
            usage_exit
        fi
        CONTAINER_NAME=$2
        shift 2
    else
        echo "無効なパラメータ: $1"
        usage_exit
    fi
done

images="$(docker image ls jetson/ros2 | grep jetson/ros2)"

if [[ "${images}" == "" ]]; then
    echo 'jetson/ros2 のDockerイメージが見つかりませんでした．'
    echo 'docker/build-docker.sh でイメージを作成するか，イメージをpullしてください．'
    usage_exit
fi

declare -a images_list=()
while read repo tag id created size ; do
    images_list+=( "${repo}:${tag}" )
done <<END
${images}
END

if [[ ${#images_list[@]} -eq 1 ]]; then
    DOCKER_IMAGE="${images_list[0]}"
else
    echo -e "番号\tイメージ:タグ"
    cnt=0
    for img in "${images_list[@]}"; do
        echo -e "${cnt}:\t${img}"
        cnt=$((${cnt}+1))
    done
    isnum=3
    img_num=-1
    while [[ ${isnum} -ge 2 ]] || [[ ${img_num} -ge ${cnt} ]] || [[ ${img_num} -lt 0 ]]; do
        read -p "使用するコンテナの番号を入力してください: " img_num
        expr ${img_num} + 1 > /dev/null 2>&1
        isnum=$?
    done
    DOCKER_IMAGE="${images_list[${img_num}]}"
fi
echo ${DOCKER_IMAGE}

if [[ ${CONTAINER_NAME} != "" ]]; then
    CONTAINER_NAME="--name ${CONTAINER_NAME}"
fi

XSOCK="/tmp/.X11-unix"
XAUTH="/tmp/.docker.xauth"

HOST_WS=$(dirname $(dirname $(readlink -f $0)))/colcon_ws

DOCKER_VOLUME="-v ${XSOCK}:${XSOCK}:rw"
DOCKER_VOLUME="${DOCKER_VOLUME} -v ${XAUTH}:${XAUTH}:rw"
DOCKER_VOLUME="${DOCKER_VOLUME} -v ${HOST_WS}:/home/ros2/colcon_ws:rw"

DOCKER_ENV="-e XAUTHORITY=${XAUTH}"
DOCKER_ENV="${DOCKER_ENV} -e DISPLAY=$DISPLAY"
DOCKER_ENV="${DOCKER_ENV} -e USER_ID=$(id -u)"
DOCKER_ENV="${DOCKER_ENV} -e TERM=xterm-256color"

touch ${XAUTH}
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f ${XAUTH} nmerge -


docker run \
    -it \
    --rm \
    --gpus all \
    --privileged \
    ${CONTAINER_NAME} \
    --net ${DOCKER_NET} \
    ${DOCKER_VOLUME} \
    ${DOCKER_ENV} \
    ${DOCKER_IMAGE}
    