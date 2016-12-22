#!/bin/bash

# newrelic license key
LICENSE_KEY={{new_relic_license_key}}
# host from which the metric is reported
HOST=`hostname -s`
# set to a unique guid
GUID=com.indigobio.thinpools

LVS="/sbin/lvs --noheadings -o lv_name,data_percent,metadata_percent"

while read -r line; do
  read -a arr <<< $line
  if [[ ! -z "${arr[1]}" && ! -z "${arr[2]}" ]]; then
    curl -s "https://platform-api.newrelic.com/platform/v1/metrics" \
    -H "X-License-Key: ${LICENSE_KEY}" \
    -H "Content-Type: application/json" \
    -H "Accept: application/json" \
    -o /dev/null \
    -X POST -d '{
      "agent": {
        "host" : "'$HOST'",
        "pid" : '$$',
        "version" : "1.0.0"
      },
      "components": [
        {
          "name": "'$HOST'",
          "guid": "'$GUID'",
          "duration" : 60,
          "metrics" : {
            "Component/Thin-Pool/'${arr[0]}'/Data/Used[percent]": '${arr[1]}',
            "Component/Thin-Pool/'${arr[0]}'/Metadata/Used[percent]": '${arr[2]}'
          }
        }
      ]
    }'
  fi

done < <($LVS)