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

# Use 3.3.5a-trinitycore as base for 7.3.5-ashamanecore
mkdir -p "${DIR}/7.3.5-ashamanecore"
rsync -av --delete "${DIR}/3.3.5a-trinitycore/." "${DIR}/7.3.5-ashamanecore/."
find "${DIR}/7.3.5-ashamanecore/." -type f | xargs -n1 sed -i \
	-e 's#git clone --single-branch -b 3.3.5 --depth 1 https://github.com/TrinityCore/TrinityCore.git#git clone --single-branch -b legion --depth 1 https://github.com/AshamaneProject/AshamaneCore.git#g' \
	-e 's#TC_#AC_#g' \
	-e 's#TDB#ADB#g' \
	-e 's#tdb#adb#g' \
	-e 's#/TrinityCore#/AshamaneCore#g' \
	-e 's#trinitycore#ashamanecore#g' \
	-e 's#trinity#ashamane#g' \
	-e 's#3.3.5a#7.3.5#g' \
	-e 's#/tc#/ac#g' \
	-e 's#12340#26972#g'

sed -i "${DIR}/7.3.5-ashamanecore/Dockerfile" \
	-e 's#-f4#-f3 | cut -d"." -f1#g' \
	-e 's#https://github.com/AshamaneCore/AshamaneCore/releases/download/ADB${ADB_RELEASE}/${ADB_FILE%.*}.7z#https://github.com/AshamaneProject/AshamaneCore/releases/download/ADB_${ADB_RELEASE}/ADB_${ADB_RELEASE}.zip#g' \
	-e 's#\.7z#\.zip#g' \
	-e 's#7z e -y /tmp/adb.zip -o/ac/bin/ ${ADB_FILE}#unzip ${ADB_FILE} -d /ac/bin/#g'

for startup in $(find "${DIR}/7.3.5-ashamanecore/s6/etc/cont-init.d" -type f | grep '\-tc-'); do
	mv "${startup}" "${startup/-tc-/-ac-}"
done
