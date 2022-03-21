#!/usr/bin/env bash

APP_VERSION=$(curl -s https://api.github.com/repos/invoiceninja/invoiceninja/releases \
    | jq -r 'first(.[] | select( .target_commitish | match("v5-stable"))) .tag_name')

printf "%s" "${APP_VERSION}"
