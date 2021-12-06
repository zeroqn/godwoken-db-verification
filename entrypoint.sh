#!/bin/bash

set -u

readonly GODWOKEN_BIN=${GODWOKEN_BIN:="/bin/godwoken"}
readonly GODWOKEN_CWD=${GODWOKEN_CWD:="/opt/godwoken"}
readonly GODWOKEN_LOGS=${GODWOKEN_CWD}/logs
readonly CONFIG_TOML=$GODWOKEN_CWD/config.toml

readonly SYNC=$GODWOKEN_CWD/sync
# Do db block verification
readonly REPLAY=$GODWOKEN_CWD/replay
readonly OVERRIDDEN=$GODWOKEN_CWD/entrypoint.sh

sync() {
    $GODWOKEN_BIN run -c ${CONFIG_TOML} 2>${GODWOKEN_LOGS}/sync.log
}

replay_block() {
    local replay_blocks=($(cat ${REPLAY} | tr ',' "\n"))
    local from_block=""
    local to_block=""

    if [[ -v "replay_blocks[0]" ]] ; then
        from_block="-b ${replay_blocks[0]}"
    fi

    if [[ -v "replay_blocks[1]" ]] ; then
        to_block="-t ${replay_blocks[1]}"
    fi

    echo ${from_block} > ${GODWOKEN_LOGS}/replay.log
    echo ${to_block} >> ${GODWOKEN_LOGS}/replay.log

    $GODWOKEN_BIN replay-block -c ${CONFIG_TOML} ${from_block} 2>>${GODWOKEN_LOGS}/replay.log
}

echo "GODWOKEN_BIN: ${GODWOKEN_BIN}"
echo "GODWOKEN_CWD: ${GODWOKEN_CWD}"
echo "GODWOKEN_LOGS: ${GODWOKEN_LOGS}"

mkdir -p ${GODWOKEN_LOGS}

if test -f "$OVERRIDDEN"; then
    ${OVERRIDDEN}
elif test -f "$SYNC"; then
    sync
elif test -f "$REPLAY"; then
    replay_block
fi
