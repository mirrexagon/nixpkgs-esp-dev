#!/usr/bin/env nix-shell
#!nix-shell -i bash -p python3Packages.python python3Packages.pip jq ripgrep

# This script uses pip to do dependency resolution and prints versions of
# Python packages as per the specified version of ESP-IDF's requirements and
# constraints files.

set -euo pipefail

ESP_IDF_VERSION=$1 # Something like 'v5.4.1'

# If ESP_IDF_VERSION is 'v5.4.1', CONSTRAINTS_VERSION should be `v5.4'
if [[ $ESP_IDF_VERSION =~ ^(v[0-9]+\.[0-9]+).* ]]; then
    CONSTRAINTS_VERSION="${BASH_REMATCH[1]}"
else
    echo "Couldn't extract just major and minor ESP-IDF version."
    exit 1
fi

REQUIREMENTS_FILE_URL="https://raw.githubusercontent.com/espressif/esp-idf/refs/tags/${ESP_IDF_VERSION}/tools/requirements/requirements.core.txt"
CONSTRAINTS_FILE_URL="https://dl.espressif.com/dl/esp-idf/espidf.constraints.${CONSTRAINTS_VERSION}.txt"

PIP_INSTALL_REPORT_FILE=deps-report.json

WORKING_DIR=$(mktemp -d)
pushd $WORKING_DIR >/dev/null

curl -Lo requirements.core.txt $REQUIREMENTS_FILE_URL
curl -Lo espidf.constraints.txt $CONSTRAINTS_FILE_URL

python -m venv venv
source venv/bin/activate

# Dry run pip to resolve dependencies and output a report of what would've been
# installed as a JSON file.
pip install -r requirements.core.txt --constraint=espidf.constraints.txt --dry-run --ignore-installed --report $PIP_INSTALL_REPORT_FILE

# Now we want to go through each package in the requirements file and find out
# what version would've been installed, and report that to the user.

PACKAGES="$(rg '^([a-z_-]+)' -or '$1' requirements.core.txt | tr '_' '-')"
# At least freertos_gdb shows up as freertos-gdb in the report, so we substitute '_' with '-'.

for package in $PACKAGES; do
    echo -n "$package: "
    jq -r ".install[] | select(.metadata.name == \"$package\") | .metadata.version" $PIP_INSTALL_REPORT_FILE
done

echo "---"

jq -r '.install[] | "\(.metadata.name): \(.metadata.version)"' $PIP_INSTALL_REPORT_FILE

popd >/dev/null

rm -rf $WORKING_DIR
