#!/bin/bash

#This path can be changed as required
data_filepath="/var/lib/check_mk_agent/cache/speedtest_data.json"

start_speedtest=true
speedtest_every_min=30

if [ -f "$data_filepath" ]; then
    time_diff=$(expr $(date +%s) - $(stat -c %Y $data_filepath))
    file_age_in_min=$(expr $time_diff / 60)

    if (( file_age_in_min < speedtest_every_min )); then
        start_speedtest=false
    fi
fi

if [ "$start_speedtest" = true ]; then
    speedtest --json > $data_filepath
fi

###Json Example:{
## DATE: 2025-01-04
#  "type": "result",
#  "timestamp": "2025-01-04T09:13:13Z",
#  "ping": {
#    "jitter": 0.094,
#    "latency": 9.048,
#    "low": 8.971,
#    "high": 9.188
#  },
#  "download": {
#    "bandwidth": 8411838,
#    "bytes": 89986848,
#    "elapsed": 10710,
#    "latency": {
#      "iqm": 9.675,
#      "low": 9.026,
#      "high": 259.704,
#      "jitter": 15.531
#    }
#  },
#  "upload": {
#    "bandwidth": 2521174,
#    "bytes": 22452444,
#    "elapsed": 8811,
#    "latency": {
#      "iqm": 59.42,
#      "low": 8.958,
#      "high": 450.399,
#      "jitter": 47.062
#    }
#  },
#  "packetLoss": 0.9345794392523364,
#  "isp": "Mitteldeutsche Gesellschaft fuer Kommunikation mbH",
#  "interface": {
#    "internalIp": "XXX.XXX.XXX.XXX",
#    "name": "eth0",
#    "macAddr": "00:00:00:00:00:00",
#    "isVpn": false,
#    "externalIp": "XXX.XXX.XXX.XXX"
#  },
#  "server": {
#    "id": 36011,
#    "host": "speedtest2.mdcc.de",
#    "port": 8080,
#    "name": "MDCC Magdeburg-City-Com GmbH",
#    "location": "Magdeburg",
#    "country": "Germany",
#    "ip": "213.211.193.38"
#  },
#  "result": {
#    "id": "3e21a165-521c-13394-a24d-a15e33a3f643",
#    "url": "https://www.speedtest.net/result/c/3e21a165-521c-13394-a24d-a15e33a3f643",
#    "persisted": true
#  }
#}

# For simplicity, all variables were set in rows as follows
download_mbps=$(calc -d print $(jq -c '.download.bytes' $data_filepath) / 1024 / 1024)
upload_mbps=$(calc -d print $(jq -c '.upload.bytes' $data_filepath) / 1024 / 1024)

latency_average=$(jq -c '.ping.latency' $data_filepath)
local_public_ip=$(jq -c '.interface.externapIp' $data_filepath)
remote_server_ip=$(jq -c '.server.host' $data_filepath)


# CheckMK uses/reads the following output
echo "<<<ookla_speed_check>>>"
echo "Download_Mbps=${download_mbps} Upload_Mbps=${upload_mbps} "`
    `"Latency_average_ms=${latency_average} "`
    `"Local_public_ip=${local_public_ip} Remote_server_ip=${remote_server_ip} "
