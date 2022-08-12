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
    speedtest --accept-license --accept-gdpr -f json > $data_filepath
fi

# For simplicity, all variables were set in rows as follows
download_mbps=$(calc print $(jq -c '.download.bandwidth' $data_filepath) / 125 / 1000)
upload_mbps=$(calc print $(jq -c '.upload.bandwidth' $data_filepath) / 125 / 1000)

latency_average=$(jq -c '.ping.latency' $data_filepath)
latency_lowest=$(jq -c '.ping.low' $data_filepath)
latency_highest=$(jq -c '.ping.high' $data_filepath)
packet_loss=$(jq -c '.packetLoss' $data_filepath)
local_public_ip=$(jq -c '.interface.externalIp' $data_filepath)
remote_server_ip=$(jq -c '.server.ip' $data_filepath)
result_url=$(jq -c '.result.url' $data_filepath)

# CheckMK uses/reads the following output
echo "<<<ookla_dsl_check>>>"
echo "Download_Mbps=${download_mbps} Upload_Mbps=${upload_mbps} "`
    `"Latency_average_ms=${latency_average} Latency_lowest_ms=${latency_lowest} "`
    `"Latency_highest_ms=${latency_highest} Packet_loss=${packet_loss} "`
    `"Local_public_ip=${local_public_ip} Remote_server_ip=${remote_server_ip} "`
    `"Result_url=${result_url}"
