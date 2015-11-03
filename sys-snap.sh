#!/bin/bash
########################################################################
# MeshSnap is a very simple system monitoring script.
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
ROOT_DIR="/tmp/"

################################################################################
#  If you don't know what your doing, don't change anything below this line
################################################################################

##########
# Set Up
##########

# Get the date, hour, and min for various tasks
date=`date +%Y%m%d`
hour=`date +%H`
min=`date +%M`

# Verify Root Dir
if [ ! -d ${ROOT_DIR} ] ; then
        echo $ROOT_DIR is not a directory
        exit 1
fi

if [ ! -w ${ROOT_DIR} ] ; then
        echo $ROOT_DIR is not writable
        exit 1
fi

# if a system-snapshot directory exists, save the data and empty it.
# if it does't, create it.  
if [ -d ${ROOT_DIR}system-snapshot ]; then
        tar -czf ${ROOT_DIR}system-snapshot.${date}.${hour}${min}.tar.gz ${ROOT_DIR}system-snapshot
        rm -fr ${ROOT_DIR}system-snapshot/*
else
	mkdir ${ROOT_DIR}system-snapshot
fi

################
# Main()
################

while true
do
        # update time
        date=`date`
        hour=`date +%H`
        min=`date +%M`

        # go to the next log file
        mkdir -p ${ROOT_DIR}system-snapshot/$hour
        current_interval=$hour/$min
        
        # Set the next logging file.
	LOG=${ROOT_DIR}system-snapshot/$current_interval.log
	
        # clear the log if it already exists
        [ -e $LOG ] && rm $LOG

        # ### start actually logging ### #

        # basic stuff
        load=`cat /proc/loadavg` #least cpu
        echo "$date $hour $min --> load: $load" >> $LOG
        cat /proc/meminfo >> $LOG
        ps w >> $LOG
        netstat -anp >> $LOG
	logread >> $LOG
	dmesg >> $LOG

        # rotate the "current" pointer
        rm -rf ${ROOT_DIR}system-snapshot/current
        ln -s $LOG ${ROOT_DIR}system-snapshot/current
	
	# Sleep untill next report interval
        sleep $SLEEP_TIME

done
#EOF
