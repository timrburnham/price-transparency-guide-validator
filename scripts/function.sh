#!/bin/bash
set -euo pipefail
IFS=$'\n\t'
PATH=$PATH:/cms-mrf-validator

function toc () {
    directory="${URL_TCR_DIR:-https://idd-tcr-prod-s3b-2.s3.amazonaws.com/aso_directory.json}"
    schemas="/cms-mrf-validator/price-transparency-guide/schemas"

    shopt -s lastpipe
    curl -L $directory \
    | jq -r '.TOC_Files[0]' \
    | read url

    curl -L $url \
    | validator $schemas/table-of-contents/table-of-contents.json -
}
