#!/bin/bash
#INSTALL@ /usr/local/bin/configyour.photo

THUMB=300x300
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
		echo -n " images/$size/$target" >> Makefile
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
			echo "images/thumb/$toimage: $DIR/$image |images/thumb" >> Makefile
			echo "	convert -resize $THUMB $DIR/$image images/thumb/$toimage" >> Makefile
			echo "	exiftool -overwrite_original -Copyright='CC BY-NC ljm dullaart' images/thumb/$toimage" >> Makefile
			echo "images/medium/$toimage: $DIR/$image |images/medium" >> Makefile
			echo "	convert -resize $MEDIUM $DIR/$image images/medium/$toimage" >> Makefile
			echo "	exiftool -overwrite_original -Copyright='CC BY-NC ljm dullaart' images/medium/$toimage" >> Makefile
			echo "images/fullsize/$toimage: $DIR/$image |images/fullsize" >> Makefile
			echo "	cp $DIR/$image images/fullsize/$toimage" >> Makefile
			echo "	exiftool -overwrite_original -Copyright='CC BY-NC ljm dullaart' images/fullsize/$toimage" >> Makefile
	
			;;
	esac
done

echo '<!-- made by configyour.photo -->' > photoheader
sed -n "s/.*/\L&/;s/\(.*\)/<a href=\1.html>\1<\/a>/;s/type //gp" imagelist >> photoheader
echo "photoheader: imagelist" >> Makefile
echo "	echo '<!-- made by configyour.photo Makefile -->' > photoheader" >> Makefile
echo '	sed -n "s/.*/\L&/;s/\(.*\)/<a href=\1.html>\1<\/a>/;s/type //gp" imagelist >> photoheader'  >> Makefile

rm -f  $TMP
