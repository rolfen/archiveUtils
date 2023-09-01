#/bin/bash

scriptname=`basename "$0"`
recalculate=0 #default: true
quiet=1
processed=0
failed=0
skipped=0

# limitations: does not support spaces in dirnames

Help()
{
   # Display Help
   echo "Recursively extract previews from raw images"
   echo
   echo "Syntax: $scriptname [-s|d|c|h|q]"
   echo
   echo "options:"
   echo " -s   Source dir"
   echo " -d   Destination dir"
   echo " -c   Skip targets that already have a checksum"
   echo " -q   Quiet output"
   echo " -h   Print this Help"
   echo
}

# Get the options
while getopts "s:d:chq" option; do
   case $option in
      h) # display Help
         Help
         exit;;
      s) # Enter source
         srcdir=$OPTARG;;
      d) # Enter source
         destdir=$OPTARG;;
      c) # "continue mode", skip targets which already have a checksum
         recalculate=1;;
      q) quiet=0;;
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
   if [ $quiet -eq 1 ]; then
      echo "$srcdir/$trgt >> $destdir/$trgt.JPG" 
   fi
   skip=1
   if [ $recalculate -eq 1 ] && [ -f "$destdir/$trgt.JPG" ]; then
      # target present and recalculate is off: skip if we already have a checksum
      if [ `exiftool -rawimagedigest $destdir/$trgt.JPG | wc -c` -gt 0 ]; then
         skip=0
      fi
   fi

	if [ $skip -eq 1 ]; then
      mkdir -p `dirname $destdir/$trgt`
      rawdigest=`exiftool -m "$srcdir/$trgt" -all= -o - | md5sum | cut -d ' ' -f 1`
      exiftool -m -overwrite_original_in_place "$destdir/$trgt.JPG" -rawimagedigest="$rawdigest"
      if [ $? -ne 0 ]; then
         failed=$((failed+1))
         echo "Processed: $processed. Failed: $failed. Skipped: $skipped"
         echo “Failure, press Ctrl-C to quit or any key to continue”
         read garbage
      else
         processed=$((processed+1))
      fi
   else
      skipped=$((skipped+1))
	fi
done;

echo "Processed: $processed. Failed: $failed. Skipped: $skipped"


