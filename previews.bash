#/bin/bash

# limitations: does not support spaces in dirnames
# requires exiftool

scriptname=`basename "$0"`
processed=0
failed=0
skipped=0


Help()
{
   # Display Help
   echo "Recursively extract previews from raw images"
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

for trgt in $(cd $srcdir && find . -type f \( -size +1 -iname \*.ORF -o -size +1 -iname \*.ARW \) );
do
	# echo "$srcdir/$trgt >> $destdir/$trgt.JPG" 
	mkdir -p `dirname $destdir/$trgt`
	if [ ! -f "$destdir/$trgt.JPG" ]; then
		cat $srcdir/$trgt | exiftool  -m - -b -previewimage | exiftool  -m -tagsfromfile "$srcdir/$trgt" "-all:all>all:all" - > $destdir/$trgt.JPG
		# exiftool  -m $srcdir/$trgt  -b -previewimage -ext ORF -ext ARW > $destdir/$trgt.JPG 
		# exiftool  -overwrite_original -m -tagsfromfile $srcdir/$trgt "-all:all>all:all" $destdir/$trgt.JPG
      if [ $? -ne 0 ]; then
         failed=$((failed+1))
      else
         processed=$((processed+1))
      fi
   else
      skipped=$((skipped+1))
	fi
done;

echo "Processed: $processed. Failed: $failed. Skipped: $skipped."
