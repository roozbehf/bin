#!/bin/bash
#
# Runs a JSON schema validation tool using the remote docker image 
# Docker image repository: https://github.com/roozbehf/docker-jsonschema-tools
#
# To validate a JSON Schema file in YAML:
# `./validate-json.sh examples/schema.yml`
# 
# To validate a JSON object against a schema:
# `./validate-json.sh examples/schema.yml examples/valid-object.json`
#
# Copyright (c) 2020-2023, Roozbeh Farahbod, roozbeh.ca
#

# DOCKER_IMAGE=jsonschema-tools:local
DOCKER_IMAGE=theroozbeh/jsonschema-tools:latest
SCRIPT_NAME=`basename $0`

# show usage 
function showUsage() {
    echo "Usage: ${SCRIPT_NAME} [--help] <json-schema.yaml> [json-file.json]"
}

# show a simple help message
function showHelp() {
    echo "Validates a JSON schema file in YAML and, if provided, a JSON file against that schema."
    echo 
    showUsage
}

# show error message, then the usage, and exit with 1 
function exitOnError() {
    echo "ERROR: $1" >&2
    showUsage
    exit 1
}

# there must be at least one arg
if [ -z "$1" ] 
then 
    exitOnError "schema file is missing."
fi

# if the first arg is asking for help, show help message and exit
if [ "$1" == "--help" ]
then
    showHelp
    exit 0
fi

# pass the args to the docker image
docker run \
    --rm -it \
    --net="none" \
    -v `pwd`:/pg \
    -u `id -u` \
    ${DOCKER_IMAGE} "$@"
