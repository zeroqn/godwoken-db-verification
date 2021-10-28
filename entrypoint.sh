#!/bin/bash

set -u

readonly GODWOKEN_BIN=${GODWOKEN_BIN:="/bin/godwoken"}
readonly GODWOKEN_CWD=${GODWOKEN_CWD:="/opt/godwoken"}
readonly GODWOKEN_LOGS=${GODWOKEN_CWD}/logs
readonly CONFIG_TOML=$GODWOKEN_CWD/config.toml

readonly SYNC=$GODWOKEN_CWD/sync
# Do db block verification
readonly VERIFY=$GODWOKEN_CWD/verify
readonly OVERRIDDEN=$GODWOKEN_CWD/entrypoint.sh

sync() {
    $GODWOKEN_BIN run -c ${CONFIG_TOML} 2>${GODWOKEN_LOGS}/sync.log
}

verify_db() {
    local verify_blocks=($(cat verify | tr ',' "\n"))
    local from_block=""
    local to_block=""

    if [[ -v "verify_blocks[0]" ]] ; then
        from_block="-f ${verify_blocks[0]}"
    fi

    if [[ -v "verify_blocks[1]" ]] ; then
        to_block="-t ${verify_blocks[1]}"
    fi

    echo ${from_block}
    echo ${to_block}
    $GODWOKEN_BIN verify-db-block -c ${CONFIG_TOML} ${from_block} ${to_block} 2>${GODWOKEN_LOGS}/verify.log
}

echo "GODWOKEN_BIN: ${GODWOKEN_BIN}"
echo "GODWOKEN_CWD: ${GODWOKEN_CWD}"
echo "GODWOKEN_LOGS: ${GODWOKEN_LOGS}"

mkdir -p ${GODWOKEN_LOGS}

if test -f "$OVERRIDDEN"; then
    ${OVERRIDDEN}
elif test -f "$SYNC"; then
    sync
elif test -f "$VERIFY"; then
    verify_db
fi
