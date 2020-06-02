#!/bin/bash
BUILD_DIR=$(dirname $(readlink -f $0))

ntr_arr=( $(echo $(cat /etc/nv_tegra_release) | tr -s ',' ' ') )
MAJOR_VERSION=${ntr_arr[1]}
MINOR_VERSION=${ntr_arr[4]}

TF_INSTALL="off"
declare -a TF_VERSION=( "1.13" "1.14" "1.15" "2.0" )
declare -a TF_FILE=( "tensorflow_gpu-1.13.1+nv19.5-cp36-cp36m-linux_aarch64.whl" "tensorflow_gpu-1.14.0+nv19.10-cp36-cp36m-linux_aarch64.whl" "tensorflow_gpu-1.15.0+nv19.11-cp36-cp36m-linux_aarch64.whl" "tensorflow_gpu-2.0.0+nv19.11-cp36-cp36m-linux_aarch64.whl" )

function usage_exit {
  cat <<_EOS_ 1>&2
  Usage: $PROG_NAME [OPTIONS...]
  OPTIONS:
    -h, --help                  このヘルプを表示
    --tensorflow VERSION        TensorFlowのバージョンを指定（既定値：off）
                                ( 1.13 , 1.14 , 1.15 , 2.0 )
_EOS_
    exit 1
}

while (( $# > 0 )); do
    if [[ $1 == "--help" ]] || [[ $1 == "-h" ]]; then
        usage_exit
    elif [[ $1 == "--tensorflow" ]]; then
        if [[ $2 == "off" ]]; then
            TF_INSTALL="off"
        else
            e="false"
            cnt=0
            for v in ${TF_VERSION[@]}; do
                if [[ $2 == ${v} ]]; then
                    e="true"
                fi
                if [[ ${e} == "false" ]]; then
                    cnt=$((${cnt}+1))
                fi
            done
            if [[ ${e} == "true" ]]; then
                TF_INSTALL=${cnt}
            else
                echo "無効なパラメータ： $1 $2"
                usage_exit
            fi
        fi
        shift 2
    else
        echo "無効なパラメータ: $1"
        usage_exit
    fi
done

docker build \
    -t jetson/ros2:${MAJOR_VERSION,,}.${MINOR_VERSION}-dashing \
    --build-arg L4T_VERSION="${MAJOR_VERSION,,}.${MINOR_VERSION}" \
    ${BUILD_DIR}/src

if [[ $? != 0 ]]; then
    echo "エラーにより中断しました．"
    exit 1
fi

if [[ ${TF_INSTALL} != "off" ]]; then
    docker build \
        -f ${BUILD_DIR}/src/Dockerfile.tensorflow \
        -t jetson/ros2:${MAJOR_VERSION,,}.${MINOR_VERSION}-dashing-tf${TF_VERSION[${TF_INSTALL}]} \
        --build-arg L4T_VERSION="${MAJOR_VERSION,,}.${MINOR_VERSION}" \
        --build-arg TENSORFLOW_WHL=${TF_FILE[${TF_INSTALL}]} \
        ${BUILD_DIR}/src
    
    if [[ $? != 0 ]]; then
        echo "エラーにより中断しました．"
        exit 1
    fi
fi
