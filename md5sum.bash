#/bin/bash

scriptname=`basename "$0"`
recalculate=0 #default: true
dryrun=1 #default: false
quiet=1

# limitations: does not support spaces in dirnames

Help()
{
   # Display Help
   echo "Recursively extract previews from raw images"
   echo
   echo "Syntax: $scriptname [-s|d|c|t|h|q]"
   echo
   echo "options:"
   echo " -s   Source dir"
   echo " -d   Destination dir"
   echo " -c   Skip targets that already have a checksum"
   echo " -t   Dry run"   
   echo " -q   Quiet output"
   echo " -h   Print this Help"
   echo
}

# Get the options
while getopts "s:d:cthq" option; do
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
      t) dryrun=0;;
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

for trgt in $(cd $srcdir && find . -type f \( -iname \*.ARW -o -iname \*.ORF \) );
do
   if [ $quiet -eq 1 ]; then
      echo "$srcdir/$trgt >> $destdir/$trgt.JPG" 
   fi
	mkdir -p `dirname $destdir/$trgt`
   skip=1
   if [ $recalculate -eq 1 ] && [ -f "$destdir/$trgt.JPG" ]; then
      # target present and recalculate is off: skip if we already have a checksum
      if [ `exiftool -rawimagedigest $destdir/$trgt.JPG | wc -c` -gt 0 ]; then
         skip=0
      fi
   fi

	if [ $skip -eq 1 ]; then
      cmd='cat '
      cmd+="$srcdir/$trgt"
      cmd+=' |exiftool -m -overwrite_original_in_place '
      cmd+="$destdir/$trgt.JPG"
      cmd+=' -rawimagedigest=`exiftool -m - -all= -o - | md5sum`'
      if [ $dryrun -eq 1 ]; then
         eval $cmd
         # cat $srcdir/$trgt |exiftool -m -overwrite_original_in_place $destdir/$trgt.JPG -rawimagedigest=`exiftool - -all= -o - | md5sum`
      else
         echo $cmd
      fi
	fi
done;


