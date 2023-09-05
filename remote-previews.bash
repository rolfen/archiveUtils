scriptname=`basename "$0"`
# tmpdir=/home/rolf/photo/archive/2023
# remotedir=b2ro:Droppit/ArchivePhoto/2023
# dstdir=/home/rolf/photo/previews/2023
# maxtransfer=1G
truncate_counter=0

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

Truncate()
{
   echo > "$1"
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

echo "Please wait for previews"
./previews.bash -q -s $tmpdir -d $dstdir
echo "Please wait for raw digests"
./previews-rawdigest.bash -q -c -s $tmpdir -d $dstdir
find $tmpdir -type f \( -iname "*.ORF" -o -iname "*.ARW" \) -size +1 > >( tee >(wc -l | xargs echo "In cam JPEGS truncated:") >(while read file; do Truncate `echo "$file" | sed 's/\(.*\)\..*/\1.JPG/'`; done) > /dev/null ) 
find $tmpdir -type f \( -iname "*.ORF" -o -iname "*.ARW" \) -size +1 > >( tee >(wc -l | xargs echo "Originals truncated:") >(while read file; do Truncate "$file" ; done) > /dev/null ) 
echo "Please wait for video previews"
./previews-vid.bash -b -s $tmpdir -d $dstdir
find $tmpdir -type f \( -iname "*.MTS" -o -iname "*.AVI" -o -iname "*.MOV" -o -iname "*.MP4" \) -size +1 > >(tee >(wc -l | xargs echo "Videos truncated:") >(while read file; do Truncate "$file" ; done) > /dev/null ) 
