#!/bin/sh
set -e

touch /etc/snort/rules/white_list.rules \
      /etc/snort/rules/black_list.rules \
      /etc/snort/rules/local.rules \
      /usr/local/lib/snort_dynamicrules

if [ -z "$OINKCODE" ]; then
    echo "Warning: OINKCODE not set, skipping rule download"
elif [ -f /etc/snort/rules/.downloaded ]; then
    echo "Rules already present, skipping download"
else
    echo "Downloading Snort rules..."
    wget -q "https://www.snort.org/rules/snortrules-snapshot-29200.tar.gz?oinkcode=${OINKCODE}" \
        -O /tmp/snortrules.tar.gz
    tar -xzf /tmp/snortrules.tar.gz -C /tmp
    cp /tmp/rules/* /etc/snort/rules/
    rm -rf /tmp/snortrules.tar.gz /tmp/rules
    touch /etc/snort/rules/.downloaded
    echo "Rules installed."
fi

exec "$@"
