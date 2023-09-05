#/bin/bash

# requires exiftool

scriptname=`basename "$0"`
processed=0
failed=0
quiet=1
skipped=0
overwrite=1


Help()
{
   # Display Help
   echo "Recursively resample JPEGs"
   echo
   echo "Syntax: $scriptname [-s|d|q|h]"
   echo "options:"
   echo " -s   Source dir (without trailing /)."
   echo " -d   Destination dir (without trailing /)."
   echo " -q   Quiet mode."
   echo " -o   Overwrite."
   echo " -h   Print this Help."
   echo
}

# Get the options
while getopts "hqos:d:" option; do
   case $option in
      h) # display Help
         Help
         exit;;
      s) # Enter source
         srcdir=$OPTARG;;
      d) # Enter source
         destdir=$OPTARG;;
      q) # Quiet mode
         quiet=0;;
      o) overwrite=0;;
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


while read -d $'\0' trgt
do
   if [ $quiet -eq 1 ]; then
   	echo "$srcdir/$trgt >> $destdir/$trgt" 
   fi
   mkdir -p $(dirname "$destdir/$trgt")
   if [ ! -f "$destdir/$trgt" ] || [ $overwrite -eq 0 ]; then
     djpeg -fast "$srcdir/$trgt" | pnmscalefixed -pixels 2000000 |cjpeg -quality 75 > "$destdir/$trgt" 
     if [ $? -ne 0 ]; then
        failed=$((failed+1))
     else
        processed=$((processed+1))
     fi
   else
     skipped=$((skipped+1))
   fi
done < <(cd "$srcdir" && find . -type f -size +1 \( -iname \*.JPG -o -iname \*.JPEG \) -print0 )

echo "Processed: $processed. Failed: $failed. Skipped: $skipped."
