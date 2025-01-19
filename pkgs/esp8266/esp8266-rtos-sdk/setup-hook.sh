# Export the necessary environment variables to use ESP8266_RTOS_SDK.

addIdfEnvVars() {
    # Crude way to detect if $1 is the ESP8266_RTOS_SDK derivation.
    if [ -e "$1/tools/idf.py" ]; then
        export IDF_PATH="$1"
        addToSearchPath PATH "$IDF_PATH/tools"
    fi
}

addEnvHooks "$hostOffset" addIdfEnvVars
