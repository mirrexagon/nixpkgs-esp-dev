#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl gnused common-updater-scripts jq

set -euo pipefail

rust_version="$(
    curl ${GITHUB_TOKEN:+"-u" ":$GITHUB_TOKEN"} -s \
        https://api.github.com/repos/esp-rs/rust-build/releases |
    jq -r 'first.tag_name | sub("^v"; "")'
 )"

replace_sha() {
    local target_file="$1"
    local attr_name="$2"
    local new_hash="$3"

    sed -i "s#$attr_name ? \"sha256-.\{44\}\"#$attr_name ? \"$new_hash\"#; s#$attr_name = \"sha256-.\{44\}\"#$attr_name = \"$new_hash\"#" "$target_file"
}

replace_version() {
    local file="$1"
    local version="$2"

    sed -i "s#version ? \"[^\"]*\"#version ? \"$version\"#" "$file"
}

rust_build_release_url() {
    local version="$1"
    local platform="$2"

    printf 'https://github.com/esp-rs/rust-build/releases/download/v%s/rust-%s-%s.tar.xz\n' "$version" "$version" "$platform"
}

rust_build_src_url() {
    local version="$1"

    printf 'https://github.com/esp-rs/rust-build/releases/download/v%s/rust-src-%s.tar.xz\n' "$version" "$version"
}

prefetch_hash() {
    local url="$1"

    nix hash to-sri --type sha256 "$(nix-prefetch-url "$url")"
}

replace_version "default.nix" "$rust_version"
replace_version "src.nix" "$rust_version"
replace_sha "default.nix" "x86_64-linux" "$(prefetch_hash "$(rust_build_release_url "$rust_version" "x86_64-unknown-linux-gnu")")"
replace_sha "default.nix" "aarch64-linux" "$(prefetch_hash "$(rust_build_release_url "$rust_version" "aarch64-unknown-linux-gnu")")"
replace_sha "default.nix" "aarch64-darwin" "$(prefetch_hash "$(rust_build_release_url "$rust_version" "aarch64-apple-darwin")")"
replace_sha "src.nix" "hash" "$(prefetch_hash "$(rust_build_src_url "$rust_version")")"
