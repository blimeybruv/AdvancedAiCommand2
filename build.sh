#!/bin/bash
HEMTT_PATH="./hemtt"

# Check if parameter is missing
if [ -z "$1" ]; then
    echo "Error: Missing parameter. Please specify either 'dev' or 'release'."
    echo "Usage: $0 <dev|release>"
    exit 1
fi

BUILD_TYPE="$1"

# Validate that the parameter is strictly 'dev' or 'release'
if [[ "$BUILD_TYPE" != "dev" && "$BUILD_TYPE" != "release" ]]; then
    echo "Error: Invalid parameter '$BUILD_TYPE'."
    echo "Usage: $0 <dev|release>"
    exit 1
fi

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S.%3N') $1"
}

download_hemtt() {
    if [ ! -f "$HEMTT_PATH" ]; then
        log "Downloading hemtt..."
        wget -O "$HEMTT_PATH" https://github.com/BrettMayson/HEMTT/releases/latest/download/linux-x64
        chmod +x "$HEMTT_PATH"
    fi
}

build_mod() {
    log "------------------Building the mod ($BUILD_TYPE).------------------"
    "$HEMTT_PATH" "$BUILD_TYPE" # For 'dev', this will create a symbolic link at "<arma3 dir>/z/aicommand2" which allows us to load the mod from this directory.
}

move_build_results() {
    rm -rf ./hemttout
    mkdir ./hemttout
    cp -R ./.hemttout/* ./hemttout
    echo "Build results copied to ./hemttout"
}

download_hemtt
build_mod
move_build_results