#!/bin/sh

# Search files in folder for argument $1 search term

outfile="../grepout.txt"
if [ -e "$outfile" ]; then
	echo "" > "$outfile"
else
	touch "$outfile"
fi

find "Apps" -type f | while read filename; do
	encoding=$(file "$filename" | cut -d , -f 2)
	if [ "$encoding" = " UTF-16" ]; then
		echo "UTF-16: $filename"
		iconv -f UTF-16 -t UTF-8 "$filename" | grep -niH "$1" >> "$outfile"
	else
		grep -niH "$1" "$filename" >> "$outfile"
	fi
done
