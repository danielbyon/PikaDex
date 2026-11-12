#!/bin/sh

set -eu

if [ "${PIKADEX_GENERATED_DATABASE_PATH+x}" = x ]; then
    DATABASE_PATH="${PIKADEX_GENERATED_DATABASE_PATH}"
    if [ -z "${DATABASE_PATH}" ]; then
        echo "error: PIKADEX_GENERATED_DATABASE_PATH is set but empty." >&2
        exit 2
    fi
    case "${DATABASE_PATH}" in
        /*) ;;
        *)
            echo "error: PIKADEX_GENERATED_DATABASE_PATH must be an absolute path." >&2
            exit 2
            ;;
    esac
else
    DATABASE_PATH="${SRCROOT}/Modules/PokedexCore/Resources/Database/Pokedex.sqlite"
fi
RESOURCE_DIRECTORY="${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
RESOURCE_PATH="${RESOURCE_DIRECTORY}/Pokedex.sqlite"

fail_build_phase() {
    exit_status="$1"
    shift
    if [ -f "${RESOURCE_PATH}" ] || [ -L "${RESOURCE_PATH}" ]; then
        rm -f "${RESOURCE_PATH}" || true
    fi
    echo "error: $*" >&2
    exit "${exit_status}"
}

if [ ! -f "${DATABASE_PATH}" ] || [ -L "${DATABASE_PATH}" ] || [ ! -s "${DATABASE_PATH}" ]; then
    if [ "${PIKADEX_GENERATED_DATABASE_PATH+x}" != x ] && [ "${PIKADEX_SKIP_GENERATED_DATABASE_CHECK:-NO}" = "YES" ]; then
        rm -f "${RESOURCE_PATH}"
        exit 0
    fi

    fail_build_phase 1 "Generated Pokedex.sqlite is missing, empty, or not a regular file at ${DATABASE_PATH}. Run Scripts/pokedex-data-pipeline generate, then build again."
fi

# Xcode marks this phase always out of date. Copying every time keeps the
# packaged catalog bound to the selected source even when a build directory is reused.
if mkdir -p "${RESOURCE_DIRECTORY}"; then
    :
else
    command_status=$?
    fail_build_phase "${command_status}" "Could not create resource directory at ${RESOURCE_DIRECTORY}."
fi

# Compare bytes rather than timestamps so reused build products cannot retain a
# catalog from a different candidate, while unchanged resources avoid a rewrite.
if [ -L "${RESOURCE_PATH}" ]; then
    if ! /bin/rm -f "${RESOURCE_PATH}"; then
        fail_build_phase 1 "Could not remove symbolic link at ${RESOURCE_PATH}."
    fi
fi
if [ -e "${RESOURCE_PATH}" ] && [ ! -f "${RESOURCE_PATH}" ]; then
    fail_build_phase 1 "Packaged Pokedex.sqlite path is not a regular file: ${RESOURCE_PATH}."
fi
if [ -f "${RESOURCE_PATH}" ] && /usr/bin/cmp -s "${DATABASE_PATH}" "${RESOURCE_PATH}"; then
    exit 0
fi

if /bin/cp "${DATABASE_PATH}" "${RESOURCE_PATH}"; then
    :
else
    command_status=$?
    fail_build_phase "${command_status}" "Could not copy generated Pokedex.sqlite into ${RESOURCE_PATH}."
fi

if ! /usr/bin/cmp -s "${DATABASE_PATH}" "${RESOURCE_PATH}"; then
    fail_build_phase 1 "Packaged Pokedex.sqlite does not match ${DATABASE_PATH}."
fi
