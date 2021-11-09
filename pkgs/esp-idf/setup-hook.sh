# Export the necessary environment variables to use ESP-IDF.

addIdfEnvVars() {
    # Crude way to detect if $1 is the ESP-IDF derivation.
    if [ -e "$1/tools/idf.py" ]; then
        export IDF_PATH="$1"
        addToSearchPath PATH "$IDF_PATH/tools"
    fi
}

addEnvHooks "$hostOffset" addIdfEnvVars
