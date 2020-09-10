#!/bin/bash
export PAM_PASSWORD=$(cat - | cut -d '' -f1)
if [[ -z "${PAM_PASSWORD}" ]]; then
	exit 1
fi

source /gowowcore/_sql.sh

export DATABASE_URL=$(/usr/bin/with-contenv printenv | grep '^DATABASE_URL=' | cut -d'=' -f2-)
SQLparseUrl "${DATABASE_URL}"

USER_ID=$(SQLuser "PREPARE gowowcore_login FROM 'SELECT id FROM account WHERE \`username\`=? AND \`sha_pass_hash\`=SHA1( CONCAT( UPPER(?), \':\', UPPER(?) ) )';
SET @u = '${PAM_USER}';
SET @p = '${PAM_PASSWORD}';
EXECUTE gowowcore_login USING @u,@u,@p;
DEALLOCATE PREPARE gowowcore_login;")

if [[ -z "${USER_ID}" || ${USER_ID} -lt 1 ]]; then
	exit 1
fi
