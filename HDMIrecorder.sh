#!/bin/bash
#__author__ = "Ka Hache a.k.a. The One & Only Javi"
#__version__ = "1.0.0"
#__start_date__ = "10/05/2015"
#__end_date__ = "14/05/2015"
#__maintainer__ = "me"
#__email__ = "little_kh@hotmail.com.com"
#__requirements__ = "bmdcapture (included in Decklink SDK), ffmpeg"
#__status__ = "In production"
#__description__ = "This one is the daemon that will launch several recording instances"

##########################################################
# $1 = device number
# $2 = Video mode:
#    0: NTSC 720 x 486 29.97 FPS
#    1: NTSC 23.98 720 x 486 23.976 FPS
#    2: PAL 720 x 576 25 FPS
#    3: NTSC Progressive 720 x 486 59.9401 FPS
#    4: PAL Progressive 720 x 576 50 FPS
#    5: HD 1080p 23.98 1920 x 1080 23.976 FPS
#    6: HD 1080p 24 1920 x 1080 24 FPS
#    7: HD 1080p 25 1920 x 1080 25 FPS
#    8: HD 1080p 29.97 1920 x 1080 29.97 FPS
#    9: HD 1080p 30 1920 x 1080 30 FPS
#    10: HD 1080i 50 1920 x 1080 25 FPS
#    11: HD 1080i 59.94 1920 x 1080 29.97 FPS
#    12: HD 1080i 60 1920 x 1080 30 FPS
#    13: HD 720p 50 1280 x 720 50 FPS
#    14: HD 720p 59.94 1280 x 720 59.9401 FPS
#    15: HD 720p 60 1280 x 720 60 FPS
# $3 = Audio Input:
#    1: Analog (RCA)
#    2: Embedded audio (HDMI/SDI) -> this should be default
# $4 = Video Input:
#    1: Composite
#    2: Component
#    3: HDMI -> this should be default
#    4: SDI
# $5 = input keyname / name of the files
# $6 = ftp user
# $7 = format type:
#    aac
#    mp4
#    etc...
##########################################################


#define INPUTS file
INPUTS="/home/user/config/HDMIinputs.txt"
#define Paths
RECORD_PATH="/home/user/record"

cd /
while true ; do

	#recording function with variables given
	#this is the key to make work DeckLink with FFMpeg through command line
	record(){
		timeout 3600 bmdcapture -C $1 -m $2 -A $3 -V $4 -F nut -f pipe:1 | ffmpeg -re -i - -filter:v yadif -vcodec libx264 -acodec aac -strict -2 -s 360x240 $RECORD_PATH/$5_$6_`date +%Y%m%d_%H%M%S`.$7  &
        sleep 1
	}

#Extract variables from input file
	for LINE in `cat $INPUTS` ; do
		p1=`echo $LINE | cut -d: -f 1`
		p2=`echo $LINE | cut -d: -f 2`
		p3=`echo $LINE | cut -d: -f 3`
		p4=`echo $LINE | cut -d: -f 4`
		p5=`echo $LINE | cut -d: -f 5`
		p6=`echo $LINE | cut -d: -f 6`
		p7=`echo $LINE | cut -d: -f 7`
		#start the record loop
		record $p1 $p2 $p3 $p4 $p5 $p6 $p7
	done

done

exit 0

#TO_DOs
#Consider the option of adding variable on the duration of the files for the future
