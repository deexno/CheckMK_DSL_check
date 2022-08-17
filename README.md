![image speedtest](https://upload.wikimedia.org/wikipedia/commons/thumb/0/09/Speedtest.net_logo.svg/2560px-Speedtest.net_logo.svg.png)

# Check_MK DSL Check

This Check_MK plugin allows you to retrieve various information about your DSL. This includes the following:
- Download/Mbps
- Upload/Mbps
- Average latency
- Max latency
- Min latency
- Packet loss
- Your public IP
- The remote Server IP
- The Speedtest result as HTML

If required, this tool can also be extended with some additional information. For the speed tests, the service of ookla (https://www.speedtest.net/) is used.

The plug-in is divided into a client and a server plug-in. You can install the client plugin on the Check_MK server or on any other device with a Check_MK agent.

## Installation - STEP 1 - Installing the Client Plugin
1. Install the Ookla Speedtest CLI - https://www.speedtest.net/de/apps/cli
2. Install the JSON Processor - For Debian: `apt install jq -y`
3. Install apcalc - For Debian: `apt install apcalc -y`
4. Save the `speedtest_agent_plugin.sh` on the client under the folder: `/usr/lib/check_mk_agent/plugins/`
5. Make the script executable - `chmod 755 /usr/lib/check_mk_agent/plugins/speedtest_server_plugin.py`
6. Check on the client with the command: `check_mk_agent` if the script can be executed successfully. 

## Installation - STEP 2 - Installing the Server Plugin
1. Switch to your CheckMK installation on your CheckMK server. `su - <mycheckmk>`
2. Navigate to the Plugin folder Folder `cd local/lib/check_mk/base/plugins/agent_based`
3. Make the script executable - `chmod 755 speedtest_server_plugin.py`

## Installation - STEP 3 - Adding the service in CheckMK
Now, after a service scan, a new service with the name: `Ookla DSL check` should appear in CheckMK under the respective client. Add this.

## Increasing the check interval
By default, the speed test is performed every 30 minutes. If you want to change this, you can do so in the client/agent plugin (`speedtest_agent_plugin.sh`). To do this, simply change the variable content of `speedtest_every_min` in the script. 
