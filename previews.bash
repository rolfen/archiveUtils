#/bin/bash

# requires exiftool

scriptname=`basename "$0"`
processed=0
failed=0
quiet=1
skipped=0
resample=1


Help()
{
   # Display Help
   echo "Recursively extract previews from raw images"
   echo
   echo "Syntax: $scriptname [-s|d|q|h]"
   echo "options:"
   echo " -s   Source dir (without trailing /)."
   echo " -d   Destination dir (without trailing /)."
   echo " -m   Resample from RAW data - DOES NOT COPY EXIF."
   echo " -q   Quiet mode."
   echo " -h   Print this Help."
   echo
}

# Get the options
while getopts "hqms:d:" option; do
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
      m) # Resample original
         resample=0;;
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
      if [ $resample -eq 0 ]; then
         dcraw -c -h  "$srcdir/$trgt" | magick convert -resize 1000x1000 - - | cjpeg -dct fast -quality 80 > "$destdir/$trgt.JPG"
      else
   		cat "$srcdir/$trgt" | exiftool  -m - -b -previewimage | exiftool  -m -tagsfromfile "$srcdir/$trgt" "-all:all>all:all" - > "$destdir/$trgt.JPG" 
      fi
      if [ $? -ne 0 ]; then
         failed=$((failed+1))
      else
         processed=$((processed+1))
      fi
   else
      skipped=$((skipped+1))
	fi
done < <(cd "$srcdir" && find . -type f -size +1 \( -iname \*.ORF -o -iname \*.ARW -o -iname \*.DNG -o -iname \*.TIF \) -print0 )

echo "Processed: $processed. Failed: $failed. Skipped: $skipped."
