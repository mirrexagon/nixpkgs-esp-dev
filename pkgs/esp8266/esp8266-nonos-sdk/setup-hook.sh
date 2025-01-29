# Export the necessary environment variables to use ESP8266_NONOS_SDK.

addEnvVars() {
    # Crude way to detect if $1 is the ESP8266_NONOS_SDK derivation.
    if [ -e "$1/tools/make_cacert.py" ]; then
        export SDK_PATH="$1"
        addToSearchPath PATH "$SDK_PATH/tools"
    fi
}

addEnvHooks "$hostOffset" addEnvVars
