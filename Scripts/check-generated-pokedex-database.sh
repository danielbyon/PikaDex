#!/bin/sh

set -eu

DATABASE_PATH="${SRCROOT}/Modules/PokedexCore/Resources/Database/Pokedex.sqlite"
RESOURCE_DIRECTORY="${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
RESOURCE_PATH="${RESOURCE_DIRECTORY}/Pokedex.sqlite"

if [ ! -s "${DATABASE_PATH}" ]; then
    if [ "${PIKADEX_SKIP_GENERATED_DATABASE_CHECK:-NO}" = "YES" ]; then
        rm -f "${RESOURCE_PATH}"
        exit 0
    fi

    echo "error: Generated Pokedex.sqlite is missing or empty at ${DATABASE_PATH}." >&2
    echo "Run Scripts/pokedex-data-pipeline generate, then build again." >&2
    exit 1
fi

mkdir -p "${RESOURCE_DIRECTORY}"

if [ ! -s "${RESOURCE_PATH}" ] || [ "${DATABASE_PATH}" -nt "${RESOURCE_PATH}" ]; then
    /bin/cp "${DATABASE_PATH}" "${RESOURCE_PATH}"
fi
