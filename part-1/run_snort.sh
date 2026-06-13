#!/bin/bash

PCAP_FILE="$(pwd)/dvwa-attacks.pcap"

docker run --rm \
        --env-file .env \
        -v "$(pwd)/snort.conf:/etc/snort/snort.conf" \
        -v "$(pwd)/data/rules:/etc/snort/rules" \
        -v "$(pwd)/data/logs/test:/var/log/snort" \
        -v "${PCAP_FILE}:/pcap/dvwa-attacks.pcap:ro" \
        part-1-snort \
        snort -A console -k none -c /etc/snort/snort.conf -r /pcap/dvwa-attacks.pcap -l /var/log/snort