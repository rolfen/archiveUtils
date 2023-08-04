#/bin/bash


# todo: check that temporary output file is removed on Ctrl-c interruption

# limitations: does not support spaces in dirnames
# requires md5sum

scriptname=`basename "$0"`
processed=0
failed=0
skipped=0
ext="md5.txt"


Help()
{
   # Display Help
   echo "Recursively calculate md5sums"
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

for trgt in $(cd $srcdir && find . -type f \( -size +1 \) );
do
	echo "$srcdir/$trgt >> $destdir/$trgt.$ext" 
	mkdir -p `dirname $destdir/$trgt`
	if [ ! -f "$destdir/$trgt.$ext" ]; then
		printf $(md5sum -b $srcdir/$trgt) > $destdir/$trgt.$ext
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