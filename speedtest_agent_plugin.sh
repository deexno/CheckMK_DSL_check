#!/bin/bash

#This path can be changed as required
data_filepath="/usr/lib/check_mk_agent/plugins/speedtest_data.json"

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

#{
#  "bytes_received": xxxxx,
#  "bytes_sent": xxxxxx,
#  "client": {
#    "country": "xx",
#    "ip": "xx.xx.xx.xx",
#    "isp": "xxxx",
#    "ispdlavg": "x",
#    "isprating": "x.x",
#    "ispulavg": "x",
#    "lat": "xx.xxx",
#    "loggedin": "x",
#    "lon": "x.xxx",
#    "rating": "x"
#  },
#  "download": xxxxxx.xxx,
#  "ping": x.xxx,
#  "server": {
#    "cc": "xx",
#    "country": "xxxxx",
#    "d": xx.xxxxxxx,
#    "host": "url:port",
#    "id": "xxxx",
#    "lat": "xx.xxxx",
#    "latency": x.xxx,
#    "lon": "x.xxx",
#    "name": "xxxxx",
#    "sponsor": "xxxxx",
#    "url": "http://xxxxxx:port/xxxx"
#  },
#  "share": null,
#  "timestamp": "yyyy-mm-ddTHH:MM:SS.SSSSST",
#  "upload": xxxxxx.xxx
#}


# For simplicity, all variables were set in rows as follows
download_mbps=$(calc -d print $(jq -c '.download' $data_filepath) / 1024 / 1024)
upload_mbps=$(calc -d print $(jq -c '.upload' $data_filepath) / 1024 / 1024)

latency_average=$(jq -c '.ping' $data_filepath)
local_public_ip=$(jq -c '.client.ip' $data_filepath)
remote_server_ip=$(jq -c '.server.host' $data_filepath)


# CheckMK uses/reads the following output
echo "<<<ookla_speed_check>>>"
echo "Download_Mbps=${download_mbps} Upload_Mbps=${upload_mbps} "`
    `"Latency_average_ms=${latency_average} "`
    `"Local_public_ip=${local_public_ip} Remote_server_ip=${remote_server_ip} "
