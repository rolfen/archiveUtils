scriptname=`basename "$0"`
tmpdir=/home/rolf/photo/archive/2023
remotedir=b2ro:Droppit/ArchivePhoto/2023
dstdir=/home/rolf/photo/previews/2023
maxtransfer=4G

Help()
{
   # Display Help
   echo "Manages preview creation from remote archive"
   echo
   echo "Syntax: $scriptname [-s|d|h]"
   echo "options:"
   echo " -s   Rclone pathspec of remote source"
   echo " -t   Temporary dir"
   echo " -d   Preview (target) dir"
   echo " -l   Transfer limit (eg: 4G)"
   echo " -h   Print this Help."
   echo
}

# Get the options
while getopts "hs:d:" option; do
   case $option in
      h) # display Help
         Help
         exit;;
      s) remotedir=$OPTARG;;
      d) dstdir=$OPTARG;;
      t) tmpdir=$OPTARG;;
     \?) # Invalid option
         echo "Error: Invalid option"
         exit;;
   esac
done

#this script relies on the other scripts skipping empty source files or files which already have previews.

rclone copy $remotedir $tmpdir --progress --ignore-existing --max-transfer $maxtransfer
./previews.bash -s $tmpdir -d $dstdir
./previews-rawdigest.bash -c -s $tmpdir -d $dstdir
find $tmpdir -type f \( -iname "*.ORF" -o -iname "*.ARW") -size +1 -exec bash -c 'echo  > "${0}"' {} \;
./previews-vid.bash -s $tmpdir -d $dstdir
find $tmpdir -type f \( -iname "*.MTS" -o -iname "*.AVI" -o -iname "*.MOV" -o -iname "*.MP4") -size +1 -exec bash -c 'echo  > "${0}"' {} \;
