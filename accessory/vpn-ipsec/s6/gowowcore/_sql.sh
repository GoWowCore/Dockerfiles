#!/bin/bash
function SQLroot {
	QUERY="${@}"
	if [[ -n "${GOWOWCORE_DEBUG}" ]]; then
		(>&2 echo "SQLroot: ${QUERY}")
	fi
	mysql -h "${SQL_HOSTNAME}" -P "${SQL_PORT}" -u "root" "-p${MYSQL_ROOT_PASSWORD}" -BNe "${QUERY}"
}

function SQLuser {
	QUERY="${@}"
	if [[ -n "${GOWOWCORE_DEBUG}" ]]; then
		(>&2 echo "SQLuser: ${QUERY}")
	fi
	mysql -h "${SQL_HOSTNAME}" -P "${SQL_PORT}" -u "${SQL_USER}" "-p${SQL_PASSWORD}" "${SQL_DB}" -BNe "${QUERY}"
}

function SQLuserFile {
	FILEPATH="${@}"
	mysql -h "${SQL_HOSTNAME}" -P "${SQL_PORT}" -u "${SQL_USER}" "-p${SQL_PASSWORD}" -q -s "${SQL_DB}" < "${FILEPATH}"
}

function SQLwaitPort {
	# Wait for port to be open
	echo "[***] Checking if SQL is reachable at ${SQL_HOSTNAME}:${SQL_PORT}"
	timeout 600 sh -c 'until nc -z $0 $1; do sleep 1; done' "${SQL_HOSTNAME}" "${SQL_PORT}"
	if [[ $? -ne 0 ]]; then
		echo "[***] ERROR: SQL port did not respond within 10 minutes."
		echo "$0"
		exit 1
	fi
	echo "[***] Port ${SQL_PORT} on ${SQL_HOSTNAME} was responsive."
}

function SQLtestCreds {
	SQLuser "SELECT version();" | wc -l
}

function SQLwaitUser {
	count=0
	until [[ ${count} -gt 60 || $(SQLuser "SELECT version();" | wc -l) -ne 0 ]]; do
		sleep 1s
		count=$(( ${count} + 1 ))
	done
	if [[ ${count} -gt 60 ]]; then
		echo "[***] Testing user SQL credentials with 'SELECT version();' is failing."
		echo "$0"
		exit 1
	fi
	echo "[***] SQL is up"
}

function SQLwaitTable {
	TABLE="${1}"
	while [[ $(SQLuser "SHOW TABLES LIKE '${TABLE}';" | wc -l) -eq 0 ]]; do
		sleep 1s
	done
}

function SQLextractCreds {
	ATTR="${1}"
	FILEPATH="${2}"
	SQL_CONFIG=$(awk "/^${ATTR}/{print \$NF}" "${FILEPATH}")
	regex="^\"([^;]+);([^;]+);([^;]+);([^;]+);([^;]+)\""
	if [[ ${SQL_CONFIG} =~ $regex ]]; then
		SQL_HOSTNAME=${BASH_REMATCH[1]}
		SQL_PORT=${BASH_REMATCH[2]}
		SQL_USER=${BASH_REMATCH[3]}
		SQL_PASSWORD=${BASH_REMATCH[4]}
		SQL_DB=${BASH_REMATCH[5]}
	else
		echo "[***] ERROR: Couldn't extract '${ATTR}' SQL credentials from ${FILEPATH}"
		echo "$0"
		exit 1
	fi
}

function SQLexistTable {
	TABLE="${1}"
	[ $(SQLuser "SHOW TABLES LIKE '${TABLE}';" | wc -l) -eq 1 ]
}

function SQLparseUrl {
	DATA="${1}"
	sql_regex="^mysql://([^:]+):([^@]+)@([^:]+):([^/]+)/(.*)$"
        if [[ ${DATA} =~ $sql_regex ]]; then
                SQL_HOSTNAME=${BASH_REMATCH[3]}
                SQL_PORT=${BASH_REMATCH[4]}
                SQL_USER=${BASH_REMATCH[1]}
                SQL_PASSWORD=${BASH_REMATCH[2]}
                SQL_DB=${BASH_REMATCH[5]}
	fi
}
