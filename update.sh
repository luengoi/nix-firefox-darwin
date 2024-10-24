#!/usr/bin/env nix-shell
#!nix-shell -i bash -p jq
# shellcheck shell=bash

base_url="https://download-installer.cdn.mozilla.net/pub"

function get_version() {
  local edition="$1"
  curl -s "https://product-details.mozilla.org/1.0/firefox_versions.json" |
    case "$edition" in
    firefox)
      jq -r '.LATEST_FIREFOX_VERSION'
      ;;
    esac
}

function get_path() {
  local edition="$1" version="$2"
  case "$edition" in
  firefox)
    echo "firefox/releases/${version}"
    ;;
  esac
}

function get_url() {
  local edition="$1" version="$2" language="${3:"en-US"}"
  local path="$(get_path "${edition}" "${version}")"
  echo "${base_url}/${path}/mac/${language}/Firefox%20${version}.dmg"
}

function get_sha256() {
  local edition="$1" version="$2" language="${3:"en-US"}"
  local path="$(get_path "${edition}" "${version}")"
  curl -s "${base_url}/${path}/SHA256SUMS" |
    grep "mac/${language}/Firefox ${version}.dmg" |
    awk '{print $1}'
}

function gen_json() {
  local edition="$1" version="$2" language="${3:"en-US"}"
  jq -n \
    --arg version "$version" \
    --arg url "$(get_url "$edition" "$version" "$language")" \
    --arg sha256 "$(get_sha256 "$edition" "$version" "$language")" \
    '{version: $version, url: $url, sha256: $sha256}'
}

json_body=$(
  cat <<EOF
    {
      "firefox": $(gen_json "firefox" "$(get_version "firefox")" "en-US")
    }
EOF
)

echo "$json_body" | jq . >sources.json
