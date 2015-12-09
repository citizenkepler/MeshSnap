MeshSnap
=======

A helpful utility for system performance monitoring and troubleshooting server load issues for mesh networks based off SysSnap.


Intent of Script
=======
System Snapshot is a handy script that logs data from mesh networking nodes and uploades it to a centeral ftp server for remote review. 

Usage
=======

To be determined. (custom.sh)

TODO: convert to custom.sh with lock file. 



### Useing process substitution to call Mesh-Snap
sh <(curl -sLk https://raw.githubusercontent.com/citizenkepler/MeshSnap/Initial-Conversion-for-Mesh/mesh-snap.sh)

### Useing mesh-snap with named fifo pipes
curl -sLk https://raw.githubusercontent.com/citizenkepler/MeshSnap/Initial-Conversion-for-Mesh/mesh-snap.sh > /dev/fifo & source /dev/fifo 

### Saving mesh-snap to a file 
curl -k -o /tmp/mesh-snap.sh https://raw.githubusercontent.com/citizenkepler/MeshSnap/Initial-Conversion-for-Mesh/mesh-snap.sh

To stop sys-snap.pl, kill the process:
    ps aux | awk '/[s]ys-snap/ {print$2}' | xargs kill

Configuration File
=======
The Mesh-Snap script supports a local configuration file to override any of the scripts default values set in the script.  This is usefull if you need a differnt configuration for a single node, or are delpying the script in a complex envirment. The configuration is a flat text file with values assigned in the  following format:

KEY='VALUE'

Below are the folling configuration keys:
 * SLEEP_TIME
 * ROOT_DIR
 * RETAIN_LOGS
 * FTP_HOST
 * FTP_PORT
 * FTP_BASE_PATH
 * FW_VER (Not Recomended to set, unsuported)
 * NODE (Not Recomended to set, unsuported)
 * NETWORK (Not Recomended to set, unsuported)
