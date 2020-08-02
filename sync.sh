#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
repack_regex="^([^-]+)-(.*)"

for repack_dir in $(find "${DIR}" -mindepth 1 -maxdepth 1 -type d); do
	repack=$(basename "${repack_dir}")
	if [[ ${repack} =~ $repack_regex ]]; then
		echo ${DIR}
		echo ${repack_dir}
		echo ${repack}
		echo ${BASH_REMATCH[1]} ${BASH_REMATCH[2]}
		mkdir "${repack_dir}/s6/gowowcore"
		rsync -av --delete "${DIR}/common/s6/gowowcore/." "${repack_dir}/s6/gowowcore/."
	fi
done
