#/bin/bash

scriptname=`basename "$0"`

# limitations: does not support spaces in dirnames
# requires exiftool and md5sum

Help()
{
   # Display Help
   echo "Recursively generate rawdigest exif property on targets from md5 sum of raw data"
   echo
   echo "Syntax: $scriptname [-s|d|h]"
   echo "options:"
   echo " -s   Source dir (without trailing /)."
   echo " -d   Destination dir (without trailing /)."
   echo " -h   Print this Help."
   echo
}

# Get the options
while getopts "hs:d:" option; do
   case $option in
      h) # display Help
         Help
         exit;;
      s) # Enter source
         srcdir=$OPTARG;;
      d) # Enter source
         destdir=$OPTARG;;
     \?) # Invalid option
         echo "Error: Invalid option"
         exit;;
   esac
done

if [[ ! -v srcdir ]]; 
then 
	echo “Enter source”
	read srcdir
fi

if [[ ! -v destdir ]]; 
	then  
	echo “Enter destination”
	read destdir
fi

for trgt in $(cd $srcdir && find . -type f \( -iname \*.ARW -o -iname \*.ORF \) );
do
	echo "$srcdir/$trgt >> $destdir/$trgt.JPG" 
	mkdir -p `dirname $destdir/$trgt`
	# if [ ! -f "$destdir/$trgt.JPG" ]; then
		cat $srcdir/$trgt |exiftool -m -overwrite_original_in_place $destdir/$trgt.JPG -rawimagedigest=`exiftool - -all= -o - | md5sum`
	# fi
done;


