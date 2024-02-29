#!/bin/bash

# Import and organize into subfolders by date taken (YYYY/MM/DD)

scriptname=`basename "$0"`

if [[ $# -ne 2 ]]; then
    echo "Usage: $scriptname /source/dir /archive/dir"
else
	(cd "$2"; exiftool -progress -ext MTS -ext ARW -ext ORF -ext xmp -r -m -d %Y/%m/%d "-Directory<DateTimeOriginal" "$1")
fi

