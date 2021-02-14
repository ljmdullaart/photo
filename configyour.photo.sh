#!/bin/bash
#INSTALL@ /usr/local/bin/configyour.photo

THUMB=300x200
MEDIUM=1000x1000
WD=`pwd`
BASE=`basename $WD`
NOW=`date`
LOG=configyour.log
echo "$0 starting" >>$LOG
if [ -x /usr/local/bin/my_banner ] ; then
    banner=/usr/local/bin/my_banner
else
    banner=banner
fi



not_applicable(){
		echo "Not appliable" >> $LOG
		echo "tag/photo: |tag" >> Makefile
		echo "	touch tag/photo" >> Makefile
		echo "tag/clean.photo: |tag" >> Makefile
		echo "	touch tag/clean.photo" >> Makefile
		exit 0
}

$banner photo >> Makefile

# Check if applicable
if [ ! -f imagelist ] ; then
	echo "No imagelist" >>$LOG
	echo "No imagelist"
	not_applicable
fi

echo "tag/photo: tag/photo.thumb tag/photo.medium tag/photo.fullsize |tag" >> Makefile
echo "	touch tag/photo" >> Makefile
echo "tag/clean.photo: |tag" >> Makefile
echo "	- rm -rf images" >> Makefile
echo "	- rm -rf tag/photo.*" >> Makefile
echo "	touch tag/clean.photo" >> Makefile

#                  _          _ _     _                __    __ _ _           
#  _ __ ___   __ _| | _____  | (_)___| |_ ___    ___  / _|  / _(_) | ___  ___ 
# | '_ ` _ \ / _` | |/ / _ \ | | / __| __/ __|  / _ \| |_  | |_| | |/ _ \/ __|
# | | | | | | (_| |   <  __/ | | \__ \ |_\__ \ | (_) |  _| |  _| | |  __/\__ \
# |_| |_| |_|\__,_|_|\_\___| |_|_|___/\__|___/  \___/|_|   |_| |_|_|\___||___/
# 
TMP=/tmp/photo.$$.$RANDOM
grep -v '^#'  imagelist | sed 's/#.*//' | while read image altname rest ; do
	case a$image in
		(a)
			echo '.'
			;;
		(aTYPE)
			echo ';'
			;;
		(aHOST*)
			echo Host directive found and ignored
			;;
		(aDIR)
			DIR=$rest
			;;
		(a*)	
			if [ "$altname" = "" ] ; then
				echo $image >> $TMP
			else
				echo $altname >> $TMP
			fi
			;;
	esac
done

cat $TMP >>$LOG
#                  _                                      
#  _ __ ___   __ _| | _____    __ _ _ __ ___  _   _ _ __  
# | '_ ` _ \ / _` | |/ / _ \  / _` | '__/ _ \| | | | '_ \ 
# | | | | | | (_| |   <  __/ | (_| | | | (_) | |_| | |_) |
# |_| |_| |_|\__,_|_|\_\___|  \__, |_|  \___/ \__,_| .__/ 
#                             |___/                |_|    
#  _                       _       
# | |_ __ _ _ __ __ _  ___| |_ ___ 
# | __/ _` | '__/ _` |/ _ \ __/ __|
# | || (_| | | | (_| |  __/ |_\__ \
#  \__\__,_|_|  \__, |\___|\__|___/
#                |__/

for size in thumb medium fullsize ; do
	echo -n "tag/photo.$size:" >> Makefile
	cat $TMP | while read target ; do
		iext=${target##*.}
		ibase=${target%.*}
		case "$iext" in
			(mp4)	echo -n " images/$size/$ibase.jpg" >> Makefile ;;
			(MP4)	echo -n " images/$size/$ibase.jpg" >> Makefile ;;
			(mov)	echo -n " images/$size/$ibase.jpg" >> Makefile ;;
			(MOV)	echo -n " images/$size/$ibase.jpg" >> Makefile ;;
			(*)	echo -n " images/$size/$target" >> Makefile ;;
		esac
	done

	echo "|tag"  >> Makefile
	echo "	touch tag/photo.$size"  >> Makefile
	echo "images/$size:">>Makefile
	echo "	mkdir -p images/$size" >> Makefile

done
#  _                       _          __            
# | |_ __ _ _ __ __ _  ___| |_ ___   / _| ___  _ __ 
# | __/ _` | '__/ _` |/ _ \ __/ __| | |_ / _ \| '__|
# | || (_| | | | (_| |  __/ |_\__ \ |  _| (_) | |   
#  \__\__,_|_|  \__, |\___|\__|___/ |_|  \___/|_|   
#               |___/                               
#  _                                 
# (_)_ __ ___   __ _  __ _  ___  ___ 
# | | '_ ` _ \ / _` |/ _` |/ _ \/ __|
# | | | | | | | (_| | (_| |  __/\__ \
# |_|_| |_| |_|\__,_|\__, |\___||___/
#                    |___/  
doit_image(){
	echo "images/thumb/$toimage: $DIR/$image |images/thumb" >> Makefile
	echo "	convert -resize $THUMB $DIR/$image images/thumb/$toimage" >> Makefile
	echo "	exiftool -overwrite_original -Copyright='CC BY-NC ljm dullaart' images/thumb/$toimage" >> Makefile
	echo "images/medium/$toimage: $DIR/$image |images/medium" >> Makefile
	echo "	convert -resize $MEDIUM $DIR/$image images/medium/$toimage" >> Makefile
	echo "	exiftool -overwrite_original -Copyright='CC BY-NC ljm dullaart' images/medium/$toimage" >> Makefile
	echo "images/fullsize/$toimage: $DIR/$image |images/fullsize" >> Makefile
	echo "	cp $DIR/$image images/fullsize/$toimage" >> Makefile
	echo "	exiftool -overwrite_original -Copyright='CC BY-NC ljm dullaart' images/fullsize/$toimage" >> Makefile
}
doit_video(){
	iname=${image%.*}
	echo "images/fullsize/$iname.jpg: images/fullsize/$image |images/fullsize" >> Makefile
	echo "	echo ''|mplayer   -dumpfile images/fullsize/$iname.jpg $DIR/$image -vo jpeg -ss 3 -frames 1 2>&1 > /dev/null" >> Makefile
	echo "	mv 00000001.jpg images/fullsize/$iname.jpg" >> Makefile
	echo "images/thumb/$iname.jpg: images/fullsize/$iname.jpg |images/thumb" >> Makefile
	echo "	convert -resize $THUMB images/fullsize/$iname.jpg images/thumb/$iname.jpg" >> Makefile
	echo "	exiftool -overwrite_original -Copyright='CC BY-NC ljm dullaart' images/thumb/$iname.jpg" >> Makefile
	echo "images/medium/$iname.jpg: images/fullsize/$iname.jpg |images/medium" >> Makefile
	echo "	convert -resize $MEDIUM images/fullsize/$iname.jpg images/medium/$iname.jpg" >> Makefile
	echo "	exiftool -overwrite_original -Copyright='CC BY-NC ljm dullaart' images/medium/$iname.jpg" >> Makefile
	echo "images/fullsize/$image: $DIR/$image |images/fullsize" >> Makefile
	echo "	cp $DIR/$image images/fullsize/$image" >> Makefile
}

grep -v '^#'  imagelist | sed 's/#.*//' | while read image altname rest ; do
	case a$image in
		(a)
			echo '.'
			;;
		(aHOST*)
			echo 'Host directive found and ignored (twice)'
			;;
		(aTYPE)
			echo ';'
			;;
		(aDIR)
			DIR=$altname
			;;
		(a*)	
			if [ "$altname" = "" ] ; then
				toimage=$image
			else
				toimage="$altname"
			fi
			iext=${image##*.}
			case b$iext in
				(bjpg) doit_image ;;
				(bjpeg) doit_image ;;
				(bJPG) doit_image ;;
				(bJPEG) doit_image ;;
				(btif) doit_image ;;
				(btiff) doit_image ;;
				(bTIF) doit_image ;;
				(bTIFF) doit_image ;;
				(bmp4) doit_video ;;
				(bMP4) doit_video ;;
				(bmov) doit_video ;;
				(bMOV) doit_video ;;
				(bavi) doit_video ;;
				(bAVI) doit_video ;;
				(b*)	echo "Unknown extension $iext" ;;
			esac
	
			;;
	esac
done

echo '<!-- made by configyour.photo -->' > photoheader
sed -n "s/.*/\L&/;s/\(.*\)/<a href=\1.html>\1<\/a>/;s/type //gp" imagelist >> photoheader
echo "photoheader: imagelist" >> Makefile
echo "	echo '<!-- made by configyour.photo Makefile -->' > photoheader" >> Makefile
echo '	sed -n "s/.*/\L&/;s/\(.*\)/<a href=\1.html>\1<\/a>/;s/type //gp" imagelist >> photoheader'  >> Makefile

rm -f  $TMP
