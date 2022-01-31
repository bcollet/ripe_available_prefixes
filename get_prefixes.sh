#!/usr/bin/env bash

curl -s https://ftp.ripe.net/ripe/stats/delegated-ripencc-extended-latest | awk -F "|" '
$3 == "ipv4" && $7 ~ /(reserved|available)/ && $5 >= 256 {
  printf "%-15s\t%i\t%s\n", $4, $5, $7
}' > $(dirname -- "${BASH_SOURCE[0]}")/ipv4_available_reserved.txt
