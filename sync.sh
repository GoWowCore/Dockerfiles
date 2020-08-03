#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
repack_regex="^([^-]+)-(.*)"

# Bases come from:
## common - generic common scripts
## 1.12.1-mangoszero - mangos family scripts
## 3.3.5a-trinitycore - trinitycore/3.3.5 family scripts

# Sync base utility functions
for repack_dir in $(find "${DIR}" -mindepth 1 -maxdepth 1 -type d); do
	repack=$(basename "${repack_dir}")
	if [[ ${repack} =~ $repack_regex ]]; then
		mkdir -p "${repack_dir}/s6/gowowcore"
		rsync -av --delete "${DIR}/common/s6/gowowcore/." "${repack_dir}/s6/gowowcore/."
	fi
done

# Sync mangoszero through mangosfour
for mangos in '2.4.3-mangosone' '3.3.5a-mangostwo' '4.3.4-mangosthree' '5.4.8-mangosfour'; do
	if [[ $mangos =~ $repack_regex ]]; then
		VERSION=${BASH_REMATCH[1]}
		FAMILY=${BASH_REMATCH[2]}
		FAMILY=${FAMILY/mangos}
		mkdir -p "${DIR}/${mangos}"
		rsync -av --delete "${DIR}/1.12.1-mangoszero/." "${DIR}/${mangos}/."
		sed -i "s#1\.12\.1#${VERSION}#g" "${DIR}/${mangos}/"*.*
		sed -i "s#zero#${FAMILY}#g" "${DIR}/${mangos}/"*.*
	fi
done

# Sync playerbots versions of all mangos
for mangos in '1.12.1-mangoszero' '2.4.3-mangosone' '3.3.5a-mangostwo' '4.3.4-mangosthree' '5.4.8-mangosfour'; do
	mkdir -p "${DIR}/${mangos}-playerbots"
	rsync -av --delete "${DIR}/${mangos}/." "${DIR}/${mangos}-playerbots/."
	sed -i 's#MANGOS_PLAYERBOTS: "0"#MANGOS_PLAYERBOTS: "1"#g' "${DIR}/${mangos}-playerbots/docker-compose.yml"
done

# Sync 3.3.5a-trinitycore to 3.3.5a-spp
rsync -av --delete "${DIR}/3.3.5a-trinitycore/s6/." "${DIR}/3.3.5a-trinitycore-spp-npcbots/s6/."
