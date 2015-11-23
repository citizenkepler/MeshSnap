#!/bin/sh

########################################################################
# Mesh-Snap is a very simple system monitoring script based off sys-snap
########################################################################
#    Copyright (C) 2015
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License along
#    with this program; if not, write to the Free Software Foundation, Inc.,
#    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
########################################################################


##############
# Set Options
##############

# Set the time between snapshots for formating see: man sleep
SLEEP_TIME="5m"

# The base directory under which to build the directory where snapshots are stored.
# You *MUST* put a slash at the end.
ROOT_DIR="/tmp/mesh-snap/"

# Retain Logs localy
# If this option is set to true, logs will be retained on the node itself
# Otherwise logs will be purged to reduce memory ussage
RETAIN_LOGS=false

# FTP SETTINGS
FTP_HOST=''
FTP_PORT=''
FTP_BASE_PATH='~/'

# Configuration file for overriding defaults 
CONFIG_FILE='/etc/mesh-snap.config'

################################################################################
#  If you don't know what your doing, don't change anything below this line
################################################################################

##########
# Set Up
##########

# Get some basic infomation from the node itself 
#################################################


# Firmware Version
FW_VER=$(cat /etc/fw_ng_version)

# Node Name
NODE=$(cat /etc/config/system | grep hostname | awk '{{print $3}}'|sed "s/'//g")

# Network Name
NETWORK=$(grep ssid1.gateway_name /tmp/config.txt | cut -d \  -f 2-20)

# The above methiod is bad and does not work correctly. 
# This line despertaly needs updateing and would need to be re-worked before release. 
# However it woreks currrently as a placeholder. 

#UPDATE: I think we grab the Display name of the network with this command


# Check Configuration file
#   We support (kinda) re-asigning values of some things.

if [[ -e $CONFIG_FILE ]] ; then
        echo "Reading Configuration: $CONFIG_FILE"
        source $CONFIG_FILE
        READ_CONFIG_FILE=true
else
        READ_CONFIG_FILE=false
fi


########################
# Script initalization 
########################

# Get the date, hour, and min for various tasks
set_datetime


# Deal with logs stoored on the node itself.  
# We will purge logs if retain logs is not set to true.

if [[ "${RETAIN_LOGS}" ]] ; then
        echo "Detected RETAIN_LOGS is se"
        if [[ -d ${ROOT_DIR} ]]; then
                COMPRESS_TARBALL=${ROOT_DIR}snapshot.${date}.${hour}${min}.tar.gz
                echo "Existing logs found, compressing to ${COMPRESS_TARBALL}"
                tar -czf ${COMPRESS_TARBALL} ${ROOT_DIR}*.log &> /dev/null
                echo "Purging logs from ${ROOT_DIR}"
                rm -fr ${ROOT_DIR}*.log
        fi
else
        echo "Removing ${ROOT_DIR} as RETAIN_LOGS is set to false"
        rm -rf ${ROOT_DIR}
fi


# Verify Root Dir is created, and create it if missing
# Note: RETAIN_LOGS section may remove this directory 
#       and depends on this to recreate that directory
if [[ ! -d ${ROOT_DIR} ]] ; then
        echo $ROOT_DIR is not a directory, creating directory.
        mkdir -p ${ROOT_DIR}
fi


# Verify if the ROOT_DIR is writable.
if [[ ! -w ${ROOT_DIR} ]] ; then
        echo $ROOT_DIR is not writable, script failing.
        exit 1
fi

################
# Main()
################

while true
do
        # update time
        set_datetime

        # Rebuild file structure to Network-Node-YEAR-Month-Day-Hour-Minute.log
        LOG=${ROOT_DIR}/${NETWORK}.${date}-${hour}:${min}-${NODE}

        # clear the log if it already exists
        [ -e $LOG ] && rm $LOG


        # ### start actually logging ### #

        # basic stuff
        load=`cat /proc/loadavg` #least cpu
        echo "$date $hour $min --> load: $load" >> $LOG
        udshape -k >> $LOG
        udshape -l >> $LOG
        cat /proc/meminfo >> $LOG
        ps w >> $LOG
        netstat -anp >> $LOG
	logread | grep -v 'ar9003_hw_set_power_per_rate_table' >> $LOG
	dmesg | grep -v 'ar9003_hw_set_power_per_rate_table' >> $LOG

        # rotate the "current" pointer
        unlink ${ROOT_DIR}current
        ln -s $LOG ${ROOT_DIR}current
	
        #
        # FTP UPLOAD HERE
        #
        #
        #FTP_UPLOAD_FILE=$LOG
        #curl --upload-file $FTP_UPLOAD_FILE ftp://$FTP_HOST:$FTP_PORT/$FTP_UPLOAD_FILE


        #
        #
        # RETENTION ENFORCEMENT TO PERGE OLD LOGS AFTER UPLOAD 
        #
        #

	# Sleep untill next report interval
        sleep $SLEEP_TIME

done

###############
# End of script
###############
exit 0;



###########
# Functions
###########

set_datetime () { 
        date=`date +%Y.%m-%d`
        hour=`date +%H`
        min=`date +%M`
}