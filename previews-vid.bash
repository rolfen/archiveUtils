#/bin/bash

scriptname=`basename "$0"`
processed=0
skipped=0
failed=0
batchmode=1

Help()
{
   # Display Help
   echo "Recursively extract previews from videos"
   echo
   echo "Syntax: $scriptname [-s|d|b|h]"
   echo "options:"
   echo " -s   Source dir (without trailing /)."
   echo " -d   Destination dir (without trailing /)."
   echo " -h   Print this Help."
   echo
}

# Get the options
while getopts "hbs:d:" option; do
   case $option in
      h) # display Help
         Help
         exit;;
      b) # batch mode
         batchmode=0;;
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

while read -d $'\0' trgt
do
   mkdir -p $(dirname "$destdir/$trgt")
   if [ ! -f "$destdir/$trgt.webm" ]; then
      if [ $batchmode -eq 1 ]; then
         echo "$srcdir/$trgt"
      fi
      ffmpeg -n -hide_banner -loglevel error -stats -vsync vfr -i "$srcdir/$trgt" -c:v libvpx-vp9 -row-mt 1 -deadline good -crf 36 -c:a libopus -b:a 32k -vf "fps=6,scale=420:-1" "$destdir/$trgt.webm" < /dev/null
      if [ $? -ne 0 ]; then
        echo "Deleting partial output" >&2
        failed=$((failed+1))
        rm "$destdir/$trgt.webm";
        if [ $batchmode -ne 0 ]; then
          echo "Premature exit $scriptname" >&2
          echo "Processed: $processed. Skipped: $skipped. Failed: $failed."
          exit
        fi
      else
        processed=$((processed+1))
      fi
   else
     skipped=$((skipped+1))
   fi
   if [ ! -f "$destdir/$trgt.txt" ]; then
      exiftool -m "$srcdir/$trgt" > "$destdir/$trgt.txt"
   fi
done < <(cd "$srcdir" && find . -type f \( -size +1  -iname \*.MTS -o -size +1 -iname \*.AVI -o -size +1 -iname \*.MOV -o -size +1 -iname \*.MP4 \) -print0 )


echo "Processed: $processed. Skipped: $skipped. Failed: $failed."
