#/bin/bash

# requires exiftool

scriptname=`basename "$0"`
processed=0
failed=0
quiet=1
skipped=0


Help()
{
   # Display Help
   echo "Recursively extract previews from raw images"
   echo
   echo "Syntax: $scriptname [-s|d|q|h]"
   echo "options:"
   echo " -s   Source dir (without trailing /)."
   echo " -d   Destination dir (without trailing /)."
   echo " -q   Quiet mode."
   echo " -h   Print this Help."
   echo
}

# Get the options
while getopts "hqs:d:" option; do
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
   	echo "$srcdir/$trgt >> $destdir/$trgt.JPG" 
   fi
	mkdir -p $(dirname "$destdir/$trgt")
	if [ ! -f "$destdir/$trgt.JPG" ]; then
		cat "$srcdir/$trgt" | exiftool  -m - -b -previewimage | exiftool  -m -tagsfromfile "$srcdir/$trgt" "-all:all>all:all" - > "$destdir/$trgt.JPG" 
      if [ $? -ne 0 ]; then
         failed=$((failed+1))
      else
         processed=$((processed+1))
      fi
   else
      skipped=$((skipped+1))
	fi
done < <(cd "$srcdir" && find . -type f -size +1 \( -iname \*.ORF -o -iname \*.ARW -o -iname \*.DNG \) -print0 )

echo "Processed: $processed. Failed: $failed. Skipped: $skipped."
