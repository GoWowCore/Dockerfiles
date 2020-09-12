#!/bin/bash
function CONFsetRaw {
	CFG_FILE="${1}"
	PARAM="${2}"
	VALUE="${3}"

	sed -i "s^${PARAM} .*${PARAM} = ${VALUE}g" "${CFG_FILE}"
}

function CONFsetQuoted {
	CONFsetRaw "${1}" "${2}" "\"${3}\""
}
