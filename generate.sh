#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cfg_regex="^([^,]*),([^,]*),([^,]*),([^,]*),([^,]*)$"

# Sync build scripts from template to base
if [[ ! -d "${DIR}/base/build" ]]; then
	mkdir "${DIR}/base/build"
fi
rsync -av --delete "${DIR}/template/build/." "${DIR}/base/build/."

# 4.3.4,15595,trinitycore,cata - TODO: handle bnetserver instead of authserver
# 7.3.5,26972,ashamane - TODO: Building fails, haven't prepared startup logic either.
targets=(
        '3.3.5a,12340,trinitycore,,0'
        '3.3.5a,12340,trinitycore,spp,0'

	'4.3.4,15595,trinitycore,cata,0'

	'7.3.5,26972,ashamane,,0'

	'3.3.5a,12340,azerothcore,,0'

        '1.12.1,5875,mangos,zero,0'
        '2.4.3,8606,mangos,one,0'
        '3.3.5a,12340,mangos,two,0'
        '4.3.4,15595,mangos,three,0'
        '5.4.8,18414,mangos,four,0'

        '1.12.1,5875,mangos,zero,1'
        '2.4.3,8606,mangos,one,1'
        '3.3.5a,12340,mangos,two,1'
        '4.3.4,15595,mangos,three,1'
        '5.4.8,18414,mangos,four,1'
)

for entry in ${targets[@]}; do
	if [[ $entry =~ $cfg_regex ]]; then
		VER=${BASH_REMATCH[1]}
		GAMEBUILD=${BASH_REMATCH[2]}
		CORE=${BASH_REMATCH[3]}
		FAMILY=${BASH_REMATCH[4]}
		PLAYERBOTS=${BASH_REMATCH[5]}

		FOLDER="${DIR}/${VER}-${CORE}"
		if [[ -n "${FAMILY}" ]]; then
			FOLDER+="-${FAMILY}"
		fi
		if [[ "${PLAYERBOTS}" == "1" ]]; then
			FOLDER+="-playerbots"
		fi
		if [[ ! -d "${FOLDER}" ]]; then
			mkdir "${FOLDER}"
		fi
#		rsync -av --delete "${DIR}/template/." "${FOLDER}/."
		for x in $(ls -1 ${DIR}/template/*.yml); do
			filename=$(basename ${x})
#			rsync -av --delete "${DIR}/template/${filename}" "${FOLDER}/${filename}"
			ln -s ../template/${filename} "${FOLDER}/${filename}"
		done

		cat << EOF > "${FOLDER}/.env"
CORE=${CORE}
GAMEBUILD=${GAMEBUILD}
EOF
		if [[ -n "${FAMILY}" ]]; then
			echo "FAMILY=${FAMILY}" >> "${FOLDER}/.env"
		fi
		if [[ "${PLAYERBOTS}" == "1" ]]; then
			echo "PLAYERBOTS=${PLAYERBOTS}" >> "${FOLDER}/.env"
		fi


	fi
done
