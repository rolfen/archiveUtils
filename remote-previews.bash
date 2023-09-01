scriptname=`basename "$0"`
# tmpdir=/home/rolf/photo/archive/2023
# remotedir=b2ro:Droppit/ArchivePhoto/2023
# dstdir=/home/rolf/photo/previews/2023
# maxtransfer=1G

unset remotedir

Help()
{
   # Display Help
   echo "Manages preview creation from remote archive"
   echo
   echo "Syntax: $scriptname [-s|t|d|l|h]"
   echo "Eg: $scriptname -s b2ro:Droppit/ArchivePhoto/2023 -t ../archive/2023 -d ../previews/2023 -l 4G"
   echo "options:"
   echo " -s   Rclone pathspec of remote source"
   echo " -t   Temporary dir"
   echo " -d   Preview (target) dir"
   echo " -l   Transfer limit (eg: 4G)"
   echo " -h   Print this Help."
   echo
}

# Get the options
while getopts "hs:d:t:l:" option; do
   case $option in
      h) # display Help
         Help
         exit;;
      s) remotedir=$OPTARG;;
      d) dstdir=$OPTARG;;
      t) tmpdir=$OPTARG;;
      l) maxtransfer=$OPTARG;;
     \?) # Invalid option
         echo "Error: Invalid option"
         exit;;
   esac
done

: ${tmpdir:?Specify temporary directory}
: ${dstdir:?Specify destination directory}

#this script relies on the other scripts skipping empty source files or files which already have previews.

if [ ! -z "$remotedir" ]; then
	: ${maxtransfer:?Transfer limit is required}
	rclone copy $remotedir $tmpdir --progress --ignore-existing --max-transfer $maxtransfer
fi

echo "Previews"
./previews.bash -s $tmpdir -d $dstdir
echo "Raw digests"
./previews-rawdigest.bash -q -c -s $tmpdir -d $dstdir
echo "Truncating originals"
find $tmpdir -type f \( -iname "*.ORF" -o -iname "*.ARW" \) -size +1 -exec bash -c 'echo  > "${0}"' {} \;
echo "Video previews"
./previews-vid.bash -s $tmpdir -d $dstdir
echo "Truncating original videos"
find $tmpdir -type f \( -iname "*.MTS" -o -iname "*.AVI" -o -iname "*.MOV" -o -iname "*.MP4" \) -size +1 -exec bash -c 'echo  > "${0}"' {} \;
