#/bin/bash

scriptname=`basename "$0"`
processed=0
failed=0

Help()
{
   # Display Help
   echo "Recursively extract previews from videos"
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

find "$srcdir" -type f \( -size +1  -iname \*.MTS -o -size +1 -iname \*.AVI -o -size +1 -iname \*.MOV -o -size +1 -iname \*.MP4 \) -print0 | while read -d $'\0' trgt;
do
   echo "$srcdir/$trgt >> $destdir/$trgt.webm+txt" 
   mkdir -p `dirname $destdir/$trgt`
   if [ ! -f "$destdir/$trgt.webm" ]; then
      ffmpeg -n -hide_banner -loglevel error -stats -vsync vfr -i "$srcdir/$trgt" -c:v libvpx-vp9 -row-mt 1 -deadline good -crf 36 -c:a libopus -b:a 32k -vf "fps=6,scale=420:-1" "$destdir/$trgt.webm" < /dev/null
      if [ $? -ne 0 ]; then
        echo "Deleting partial output";
        failed=$((failed+1))
        rm "$destdir/$trgt.webm";
        echo "Exiting $scriptname: Processed: $processed. Failed: $failed."
        exit
      else
        processed=$((processed+1))
      fi
   fi
   if [ ! -f "$destdir/$trgt.txt" ]; then
      exiftool -m "$srcdir/$trgt" > "$destdir/$trgt.txt"
   fi
done;

echo "$scriptname done: Processed: $processed. Failed: $failed."
