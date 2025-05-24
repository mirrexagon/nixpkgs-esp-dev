# Export the necessary environment variables to use ESP-IDF.

addIdfEnvVars() {
    # Crude way to detect if $1 is the ESP-IDF derivation.
    if [ -e "$1/tools/idf.py" ]; then
        export IDF_PATH="$1"
        export IDF_TOOLS_PATH="$IDF_PATH/tools"
        export IDF_PYTHON_CHECK_CONSTRAINTS=no
        export IDF_PYTHON_ENV_PATH="$IDF_PATH/python-env"
        
        addToSearchPath PATH "$IDF_TOOLS_PATH"

        # Extra paths from `export.sh` in the ESP-IDF repo.
        addToSearchPath PATH "${IDF_PATH}/components/espcoredump"
        addToSearchPath PATH "${IDF_PATH}/components/partition_table"
        addToSearchPath PATH "${IDF_PATH}/components/app_update"

        [ -e "$1/.tool-env" ] && . "$1/.tool-env"
      
        # use a derivation-specific system-level git config if specified
        if [ -e "$1/etc/gitconfig" ]; then
            export GIT_CONFIG_SYSTEM="$1/etc/gitconfig"
        fi

        # Fetch tags if we haven't already (to make git describe work)
        # We have to do this at shell activation time since the existing 
        # fetchers do not properly fetch tags, and at buildtime
        # the shell hook does not have network access.
        if [ -d "$IDF_PATH/.git" ] && [ ! -f "$IDF_PATH/.git/tags_fetched" ]; then
            echo "Fetching ESP-IDF tags for git describe..."
            (
                cd "$IDF_PATH"
                git remote get-url origin >/dev/null 2>&1 || git remote add origin "https://github.com/espressif/esp-idf.git"
                if git fetch origin --tags --quiet 2>/dev/null; then
                    touch "$IDF_PATH/.git/tags_fetched"
                    echo "Tags fetched successfully."
                else
                    echo "Warning: Failed to fetch tags. git describe may not work properly."
                fi
            )
        fi
    fi
}

addEnvHooks "$hostOffset" addIdfEnvVars
