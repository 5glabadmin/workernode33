#!/usr/bin/env bash

LOG_PATH="./log/"
LOG_NAME="free5gc.log"
TODAY=$(date +"%Y%m%d_%H%M%S")
PCAP_MODE=0
N3IWF_ENABLE=0

PID_LIST=()
echo $$ > run.pid

function terminate()
{
    rm run.pid
    echo "Receive SIGINT, terminating..."
    
    for ((i=${#PID_LIST[@]}-1;i>=0;i--)); do
        sudo kill -SIGTERM ${PID_LIST[i]}
    done
    sleep 2
    wait ${PID_LIST}
    exit 0
}

trap terminate SIGINT

LOG_PATH=${LOG_PATH%/}"/"${TODAY}"/"
echo "log path: $LOG_PATH"

if [ ! -d ${LOG_PATH} ]; then
    mkdir -p ${LOG_PATH}
fi

sleep 1

NF_LIST="nrf udr pcf"

export GIN_MODE=release

for NF in ${NF_LIST}; do
    ./bin/${NF} -c ./config/${NF}cfg.yaml -l ${LOG_PATH}${NF}.log -lc ${LOG_PATH}${LOG_NAME} &
    PID_LIST+=($!)
    sleep 0.1
done

wait ${PID_LIST}
exit 0
