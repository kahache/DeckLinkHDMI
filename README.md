# DeckLinkHDMI
Create your own encoder with an Ubuntu Server + DeckLink HDMI Mini Recorder!<br />

This is an old project I did in 2015 and finally didn't came into production, but was fully tested with +3month uptime.
With all these scripts, you can have an encoder working 24/7 and recording video files.
You can change the folder variables and customize it.<br />


**Requirements: <br />
Hardware**<br />
·Blackmagic Design's DeckLink Mini Recorder (https://www.blackmagicdesign.com/products/decklink/techspecs/W-DLK-06)<br />
With these scripts you can work with several cards in parallel as long as you have PCIe inputs.
It was tested with 4 at the same time, but I guess you can add more if your Motherboard has more inputs.<br />
·OS: Ubuntu Desktop/Server 14.04. Should work with more Debian distros<br />
·It was an Intel i7 with 8GB RAM, It was an ASUS Motherboard but should work on any with PCIe which recognizes DeckLink. 
Should be working on any brand/model<br />
·SSD is recommended in order to work better with video. XFS better than ext4.
However, it was working with HDD in ext3<br />
**Software**<br />
·Download DeckLink's Linux SDK (https://www.blackmagicdesign.com/developer/product/capture-and-playback)<br />
When you download it, there are some Linux examples and one is an executable file called "bmdcapture".<br />
You can put it in the same folder or move it to /usr/bin (then change script)
·Compile last FFMpeg version (https://ffmpeg.org). You can use avconv from Ubuntu but in that case you should change script too

Here you'll find some files:<br />

**HDMIinputs.txt**
Here you add the configuration for each video card. It should be something like:<br />
"0:7:2:3:example-channel-01:testHDMI:mp4"<br />
And here it's what each field stands for:<br />
```
$1 = device number
$2 = Video mode:
    0: NTSC 720 x 486 29.97 FPS
    1: NTSC 23.98 720 x 486 23.976 FPS
    2: PAL 720 x 576 25 FPS
    3: NTSC Progressive 720 x 486 59.9401 FPS
    4: PAL Progressive 720 x 576 50 FPS
    5: HD 1080p 23.98 1920 x 1080 23.976 FPS
    6: HD 1080p 24 1920 x 1080 24 FPS
    7: HD 1080p 25 1920 x 1080 25 FPS
    8: HD 1080p 29.97 1920 x 1080 29.97 FPS
    9: HD 1080p 30 1920 x 1080 30 FPS
    10: HD 1080i 50 1920 x 1080 25 FPS
    11: HD 1080i 59.94 1920 x 1080 29.97 FPS
    12: HD 1080i 60 1920 x 1080 30 FPS
    13: HD 720p 50 1280 x 720 50 FPS
    14: HD 720p 59.94 1280 x 720 59.9401 FPS
    15: HD 720p 60 1280 x 720 60 FPS
$3 = Audio Input:
    1: Analog (RCA)
    2: Embedded audio (HDMI/SDI) (this should be default)
$4 = Video Input:
    1: Composite
    2: Component
    3: HDMI (this should be default)
    4: SDI
$5 = input keyname / name of the files
$6 = ftp user
$7 = format type (output): aac, mp4, etc...
```
**HDMIrecd**<br />
This is the Recording daemon. It should be inside /etc/init.d/ with the correct permissions.<br />
**HDMIrecorder.sh** <br />
This is the recording bucle which will be launched in several instances (one for each card).
You can modify the trailing options from FFMpeg as you want.
Just keep in mind the basic idea that the higher quality you record, it's gonna take more resources from server<br />
**detectandrestart.sh**<br />
This file should be inside cron. 
You can customize how much often do you want it to be launched, 
I recommend each 5 minutes if you don't want to lose video recordings<br />
**recscheck_ignore.txt**<br />
Simple file to add the inputs you don't want to check on detectandrestart.sh
<br /><br />
Special s/out to my team mates at that era, without them all this shouldn't be possible
