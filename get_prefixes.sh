#!/usr/bin/env bash

curl -s https://ftp.ripe.net/ripe/stats/delegated-ripencc-extended-latest | awk -f $(dirname -- "${BASH_SOURCE[0]}")/get_prefixes.awk > $(dirname -- "${BASH_SOURCE[0]}")/ipv4_available_reserved.txt
