#!/bin/bash
set -e
mkdir /src
mkdir /src/build

function gclone {
	REPO=""
	DEST=""
	BRANCH=""
	COMMIT=""
	while [ -n "${1}" ]; do
		case "${1}" in
			"--repo")
				REPO="${2}"
				shift
				;;
			"--dest")
				DEST="${2}"
				shift
				;;
			"--branch")
				BRANCH="${2}"
				shift
				;;
			"--commit")
				COMMIT="${2}"
				;;
		esac
		shift
	done
	if [[ -z "${BRANCH}" && -z "${COMMIT}" ]]; then
		git clone --single-branch --recursive --depth 1 "${REPO}" "${DEST}"
	elif [[ -n "${BRANCH}" && -z "${COMMIT}" ]]; then
		git clone --single-branch -b "${BRANCH}" --recursive --depth 1 "${REPO}" "${DEST}"
	elif [[ -n "${COMMIT}" ]]; then
		mkdir "${DEST}"
		OPWD=${PWD}
		cd "${DEST}"
		git init
		git remote add origin "${REPO}"
		git fetch origin "${COMMIT}"
		git reset --hard FETCH_HEAD
		git submodule update --init --recursive
		cd ${OPWD}
	fi
}

case "${CORE}" in
	"mangos")
		# Clone
		SERVER_ARGS=("--repo" "https://github.com/mangos${FAMILY}/server.git" "--dest" "/src/server")
		if [[ -n "${GIT_COMMIT}" ]]; then
			SERVER_ARGS+=("--commit" "${GIT_COMMIT}")
		fi
		gclone ${SERVER_ARGS[@]}
		gclone --repo "https://github.com/mangos${FAMILY}/database.git" --dest "/src/db"
		cd /src/server/dep && git pull origin master && git checkout master

		# Build
		cd /src/build
		cmake ../server/ \
			-DCMAKE_INSTALL_PREFIX=/app \
			-DCONF_INSTALL_DIR=/app/etc \
			-DBUILD_MANGOSD=1 \
			-DBUILD_REALMD=1 \
			-DSOAP=1 \
			-DBUILD_TOOLS=1 \
			-DPLAYERBOTS=${PLAYERBOTS}
		make -j $(nproc)
		make install
		;;

	"trinitycore")
		SERVER_ARGS=("--dest" "/src/server")
		case "${FAMILY}" in
			"spp")
				SERVER_ARGS+=("--repo" "https://github.com/conan513/SingleCore_TC.git" "--branch" "3.3.5-npcbots")
				;;
			"cata")
				SERVER_ARGS+=("--repo" "https://github.com/The-Cataclysm-Preservation-Project/TrinityCore.git" "--branch" "master")
				;;
			*)
				SERVER_ARGS+=("--repo" "https://github.com/TrinityCore/TrinityCore.git" "--branch" "3.3.5")
				;;
		esac
		if [[ -n "${GIT_COMMIT}" ]]; then
			SERVER_ARGS+=("--commit" "${GIT_COMMIT}")
		fi
		gclone ${SERVER_ARGS[@]}

		# Build
		cd /src/build
		cmake ../server/ \
			-DCMAKE_INSTALL_PREFIX=/app \
			-DSERVERS=1 \
			-DTOOLS=1
		make -j $(nproc)
		make install

		# Grab matching TDB release
		echo "[***] Downloading appropriate TDB file"
		case "${FAMILY}" in
			"cata")
				export TDB_FILE=$(awk '/_FULL_DATABASE/{print $NF}' /src/server/revision_data.h.in.cmake | tr -d '"')
				export TDB_RELEASE=$(echo "${TDB_FILE}" | cut -d'_' -f4)
				export TDB_ZIP=${TDB_FILE/full_world/full}
				# https://github.com/The-Cataclysm-Preservation-Project/TrinityCore/releases/download/TDB434.20051/TDB_full_434.20051_2020_05_19.7z
				wget -q https://github.com/The-Cataclysm-Preservation-Project/TrinityCore/releases/download/TDB${TDB_RELEASE}/${TDB_ZIP%.*}.7z \
					-O /tmp/tdb.7z
				7z e -y /tmp/tdb.7z -o/app/bin/ ${TDB_FILE}
				;;
			*)
				export TDB_FILE=$(awk '/_FULL_DATABASE/{print $NF}' /src/server/revision_data.h.in.cmake | tr -d '"')
				export TDB_RELEASE=$(echo "${TDB_FILE}" | cut -d'_' -f4)
				wget -q https://github.com/TrinityCore/TrinityCore/releases/download/TDB${TDB_RELEASE}/${TDB_FILE%.*}.7z \
					-O /tmp/tdb.7z
				7z e -y /tmp/tdb.7z -o/app/bin/ ${TDB_FILE}
			;;
		esac
		;;

	"ashamane")
		# Clone
		SERVER_ARGS=("--repo" "https://github.com/AshamaneProject/AshamaneCore.git" "--dest" "/src/server" "--branch" "legion")
		if [[ -n "${GIT_COMMIT}" ]]; then
			SERVER_ARGS+=("--commit" "${GIT_COMMIT}")
		fi
		gclone ${SERVER_ARGS[@]}

		# Build
		cd /src/build
		cmake ../server/ \
			-DCMAKE_INSTALL_PREFIX=/app \
			-DSERVERS=1 \
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
		SERVER_ARGS=("--repo" "https://github.com/azerothcore/azerothcore-wotlk.git" "--dest" "/src/server" "--branch" "master")
		if [[ -n "${GIT_COMMIT}" ]]; then
			SERVER_ARGS+=("--commit" "${GIT_COMMIT}")
		fi
		gclone ${SERVER_ARGS[@]}

		# Build
		cd /src/build
		cmake ../server/ \
			-DCMAKE_INSTALL_PREFIX=/app \
			-DSERVERS=1 \
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
