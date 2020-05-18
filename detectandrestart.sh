#!/bin/bash
#__author__ = "Ka Hache a.k.a. The One & Only Javi. This one is influenced by dvb's one from koppi/omagrane"
#__version__ = "1.0.0"
#__start_date__ = "April 2015"
#__end_date__ = "08/06/2015"
#__maintainer__ = "me"
#__email__ = "little_kh@hotmail.com.com"
#__requirements__ = "Blackmagic's SDK drivers installed"
#__status__ = "In production"
#__description__ = "This is the cron-ned script that will check the service and restart it if necessary"

#GLOBAL variables
RECORD_PATH=/home/user/record
DB_DIR=/var/tmp/detectandrestart
#inputs in this file will be ignored
IGNORE_FILE=/home/user/config/recscheck_ignore.txt
#configure bandwidth for some input
INPUT_CONFIG=/home/user/config/detectandrestart-input.cfg
#Reboot configuration
REBOOT_FILE="/home/user/config/allowedreboot" #put 1 in this file if this server should be rebooted
MIN_UPTIME=3600                               #time to wait between reboots


#Lock system for this detect & restart script
check_lock(){
        if [ -e "/home/user/config/userdetect.lock" ]; then
        	OLD_PID=$(cat /home/user/config/userdetect.lock)
        	if kill -0 "$OLD_PID" &>/dev/null
        		then
            			echo "Detect and restart service already running, exiting!!"
            		exit 1
        	else
            		echo "PID $OLD_PID is not running, deleting lock file"
            		rm -f "/home/user/config/userdetect.lock"
        	fi
        fi
        make_lock
}

make_lock(){
        echo $$ > /home/user/config/userdetect.lock
}

#list recording files and check their size
list_recordings(){
        LIST_RECORDINGS=`find $RECORD_PATH -type f -mmin -2 -size +52c | cut -d/ -f 5  | cut -d_ -f 1 | sort -u`

}

#reset the counter to restart services if needed
reset_counter(){
        INPUT=$1
        # check if counter != 0
        if [ -f $DB_DIR/$INPUT ]; then
                ATTEMPT=`cat $DB_DIR/$INPUT`
                if [ $ATTEMPT -ne 0 ]; then
                        # reset counter
                        echo "Resetting counter of input $INPUT"
                        echo 0 > $DB_DIR/$INPUT
                fi
        fi
}

#check if there are recordings in the /record/ folder
check_HDMI(){
	RESTART_HDMI_RECD=0
	for INPUT in $HDMI_INPUT_LIST; do
		if [ `echo "$LIST_RECORDINGS" | grep -c $INPUT` == 0 ]; then
			echo "No recording detected for $INPUT"
			if [ ! -f $DB_DIR/$INPUT ] ; then 
				echo 0 > $DB_DIR/$INPUT 
			fi
			ATTEMPT=`cat $DB_DIR/$INPUT`
			if [ $ATTEMPT -lt 2 ]; then
                                resetHDMIinput $INPUT #we restart the recording service for the input without recordings
				elif [ $ATTEMPT -lt 4 ]; then
					echo "More than 2 ATTEMPTs for input $INPUT, restarting HDMIrecd"
                                	RESTART_HDMI_RECD=1
					echo "More than 2 ATTEMPTs for input $INPUT, restarting HDMIrecd"
                                	RESTART_HDMI_RECD=1
			else
				DO_REBOOT=1
			fi
			let I=$ATTEMPT+1
			echo $I > $DB_DIR/$INPUT
                else
                        reset_counter $INPUT
		fi
	done

	if [ $RESTART_HDMI_RECD == 1 ]; then
                HDMI_restart
        fi
}

resetHDMIinput(){ #Searches the current Card number in order to kill the BMDCapture process, so the input will restart
	INPUT=$1
        echo "Resetting HDMI input $INPUT"
        VIDEO_CARD_NUMBER=`cat /home/user/config/HDMIinputs.txt | grep -e $INPUT | cut -d: -f 1`
        BMD_CAPTURE_PID=`ps ax | grep "bmdcapture -C $VIDEO_CARD_NUMBER" | grep -v grep | awk '{print $1}'` #extracts PID with info from before
        	if [ -n $BMD_CAPTURE_PID ]; then
                        for LINE in $BMD_CAPTURE_PID; do
                                echo "Killing BMDcapture with PID $BMD_CAPTURE_PID"
                                kill -9 $BMD_CAPTURE_PID #kills the PID
                        done
                else
                        echo "No BMDrecord process found with card $VIDEO_CARD_NUMBER" 

                fi
}

HDMI_restart(){ #restarts the service
	echo "Stopping HDMI recd ..."
	service HDMIrecd stop
	echo "DONE"
	modprobe blackmagic #sometimes fails to load the drivers, so this 2 lines are a MUST
	modprobe blackmagic-io
	echo "Starting HDMI recd ..."
	( service HDMIrecd start >/dev/null 2>&1 & )
	echo "DONE"
}

reboot_server(){ #reboot function
        UPTIME_SECS=`awk -F'.' '{print $1}' /proc/uptime`
        if [ $UPTIME_SECS -ge $MIN_UPTIME ] ; then
                if [ ! -f $REBOOT_FILE ] ; then echo "0" > $REBOOT_FILE ; fi
                if [ `cat $REBOOT_FILE` -eq 1 ] ; then
                        # reset counter
                        rm -f $DB_DIR/*
                        reboot
                else
                        echo "Reboot of this machine not allowed ($REBOOT_FILE returns 0), not rebooting!"
                        echo "Reseting all counters to start over again ..."
                        rm -f $DB_DIR/*
                fi
        else
                echo "Server uptime ($UPTIME_SECS) less than minimum uptime ($MIN_UPTIME), not rebooting!"
        fi
}

check_lock #we call the lock and create the default files if they aren't avalaible

mkdir -p $DB_DIR &> /dev/null
if [ ! -e $IGNORE_FILE ] ; then
        touch $IGNORE_FILE
fi

# variable to show if a reboot is mandatory 
DO_REBOOT=0

#check launcher of each input
list_recordings
if [ -f /home/user/config/HDMIinputs.txt ] ; then
        HDMI_INPUT_LIST=`cut -d: -f 5 /home/user/config/HDMIinputs.txt | grep -v -f $IGNORE_FILE`
        check_HDMI
else
	echo "ERROR? - no inputs to check"
fi

#lock restarter
rm /home/user/config/userdetect.lock

#reboot
if [ $DO_REBOOT == 1 ]; then
        reboot_server
fi

exit 0

#TO_DOs
#Create logfile of the detect&restart system?
