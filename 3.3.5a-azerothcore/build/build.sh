#!/bin/bash
set -e
mkdir /src
mkdir /src/build

case "${CORE}" in
	"mangos")
		# Clone
		git clone --single-branch --recursive --depth 1 https://github.com/mangos${FAMILY}/server.git /src/server
		git clone --single-branch --recursive --depth 1 https://github.com/mangos${FAMILY}/database.git /src/db
		cd /src/server/deb && git pull origin master && git checkout master

		# Build
		cd /src/build
		cmake ../server/ \
			-DCMAKE_INSTALL_PREFIX=/app \
			-DCONF_INSTALL_DIR=/app/etc \
			-DPLAYERBOTS=${PLAYERBOTS} \
			-DSOAP=1 \
			-DTOOLS=1
		make -j $(nproc)
		make install
		;;

	"trinitycore")
		case "${FAMILY}" in
			"spp")
				# Clone
				git clone --single-branch -b 3.3.5-npcbots --depth 1 https://github.com/conan513/SingleCore_TC.git /src/server
				;;
			*)
				# Clone
				git clone --single-branch -b 3.3.5 --depth 1 https://github.com/TrinityCore/TrinityCore.git /src/server
				;;
		esac

		# Build
		cd /src/build
		cmake ../server/ \
			-DCMAKE_INSTALL_PREFIX=/app \
			-DTOOLS=1
		make -j $(nproc)
		make install

		# Grab matching TDB release
		export TDB_FILE=$(awk '/_FULL_DATABASE/{print $NF}' /src/server/revision_data.h.in.cmake | tr -d '"')
		export TDB_RELEASE=$(echo "${TDB_FILE}" | cut -d'_' -f4)
		wget -q https://github.com/TrinityCore/TrinityCore/releases/download/TDB${TDB_RELEASE}/${TDB_FILE%.*}.7z \
			-O /tmp/tdb.7z
		7z e -y /tmp/tdb.7z -o/app/bin/ ${TDB_FILE}
		;;

	"ashamane")
		# Clone
		git clone --single-branch -b legion --depth 1 https://github.com/AshamaneProject/AshamaneCore.git /src/server

		# Build
		cd /src/build
		cmake ../server/ \
			-DCMAKE_INSTALL_PREFIX=/app \
			-DTOOLS=1
		make -j $(nproc)
		make install

		# Grab matching ADB release
		export ADB_FILE=$(awk '/_FULL_DATABASE/{print $NF}' /src/server/revision_data.h.in.cmake | tr -d '"')
		export ADB_RELEASE=$(echo "${ADB_FILE}" | cut -d'_' -f3)
		# https://github.com/AshamaneProject/AshamaneCore/releases/download/ADB_735.00/ADB_735.00.zip
		wget -q https://github.com/AshamaneProject/AshamaneCore/releases/download/ADB_${ADB_RELEASE}/ADB_${ADB_RELEASE}.zip \
			-O /tmp/adb.zip
		unzip /tmp/adb.zip -d /app/bin/
		;;

	"azerothcore")
		# Clone
		git clone --single-branch -b master https://github.com/azerothcore/azerothcore-wotlk.git /src/server

		# Build
		cd /src/build
		cmake ../server/ \
			-DCMAKE_INSTALL_PREFIX=/app \
			-DTOOLS=1
		make -j $(nproc)
		make install
		;;
	*)
		echo "[***] I don't know how to build ${CORE}(CORE)."
		exit 1
		;;
esac

# Log commit
cd /src/server
git rev-parse --short HEAD > /app/.commit

# Cleanup
for x in '/src/build' '/src/server/.git' '/src/db/.git'; do
	if [[ -d "${x}" ]]; then
		rm -R "${x}"
	fi
done
