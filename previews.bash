#/bin/bash
echo “Enter source”
read dir
 
echo “Enter destination”
read dest
 
for trgt in $(cd $dir && find . -type f \( -iname \*.ARW -o -iname \*.ORF \) );
do
	echo "$dir/$trgt >> $dest/$trgt.JPG" 
	echo "mkdir "`dirname $dest/$trgt`
	exiftool  -m $dir/$trgt  -b -previewimage -ext ORF -ext ARW > $dest/$trgt.JPG 
	exiftool  -overwrite_original -m -tagsfromfile $dir/$trgt "-all:all>all:all" $dest/$trgt.JPG
done;