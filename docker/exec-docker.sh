#!/bin/bash

ntr_arr=( $(echo $(cat /etc/nv_tegra_release) | tr -s ',' ' ') )
MAJOR_VERSION=${ntr_arr[1]}
MINOR_VERSION=${ntr_arr[4]}

PROG_NAME=$(basename $0)
RUN_DIR=$(dirname $(readlink -f $0))

DOCKER_IMAGE="jetson/ros2:${MAJOR_VERSION,,}.${MINOR_VERSION}-dashing"

function usage_exit {
  cat <<_EOS_ 1>&2
  Usage: $PROG_NAME [OPTIONS...]
  OPTIONS:
    -h, --help              このヘルプを表示
_EOS_
    exit 1
}

CONTAINERS="$(docker ps | grep ${DOCKER_IMAGE})"

if [[ "${CONTAINERS}" == "" ]]; then
    echo 'コンテナが起動していません．'
    usage_exit
elif [[ $(echo "${CONTAINERS}" | wc -l) -eq 1 ]]; then
    echo '起動中のコンテナを１つ検出しました．'
else
    echo '起動中のコンテナを２つ以上検出しました．'
fi

declare -a containers_list=()
while read line ; do
    containers_list+=( "${line}" )
done <<END
${CONTAINERS}
END

if [[ ${#containers_list[@]} -eq 1 ]]; then
    CONTAINER_ID=${containers_list[0]:0:12}
    echo "${containers_list[0]}"
else
    echo -e "番号\tコンテナID\tコンテナ名"
    cnt=0
    for ctn in "${containers_list[@]}"; do
        echo -e "${cnt}:\t${ctn}"
        cnt=$((${cnt}+1))
    done
    isnum=3
    ctn_num=-1
    while [[ ${isnum} -ge 2 ]] || [[ ${ctn_num} -ge ${cnt} ]] || [[ ${ctn_num} -lt 0 ]]; do
        read -p "使用するコンテナの番号を入力してください: " ctn_num
        expr ${ctn_num} + 1 > /dev/null 2>&1
        isnum=$?
    done
    CONTAINER_ID=${containers_list[${ctn_num}]:0:12}
    echo "${containers_list[${ctn_num}]}"
fi

docker exec \
    -it \
    -u ros2 \
    ${CONTAINER_ID} \
    /bin/bash -c "cd ~ && clear && /bin/bash"
    