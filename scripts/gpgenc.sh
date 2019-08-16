#!/bin/bash

# USAGE 'gpgenc [[ -e or -d]] <optional file name>'
# if file name is not specified all files in the current directory (except with .txt extension) are recursively operated upon

dir=$(pwd)

while getopts "ed" opt; do
  case $opt in
    "e")
      mode="encrypt"
      ;;
    "d")
      mode="decrypt"
      ;;
  esac
done

if [[ -z $mode ]]
then
  echo "USAGE 'gpgenc [[ -e or -d]] <optional path to file to operate on>'"
  exit
fi

filesp=${@:$OPTIND:1}
[[ ! -z "$filesp" ]] && echo "Working only the file "$filesp"" || echo "Working all files in $dir recursively"

echo "Enter key"
read -s key

if [[ $mode == "encrypt" ]]
then
  [[ ! -z "$filesp" ]] && files="$filesp" || files=$(find $dir -type f -not -iname '*.txt')
  for file in $files
  do
    echo "Encrypting $file"
    gpg --symmetric --cipher-algo AES256 --pinentry-mode loopback --output $file.txt --passphrase $key $file
    echo "Removing plain text file"
    rm $file
  done
else
  [[ ! -z "$filesp" ]] && files="$filesp" || files=$(find $dir -type f -iname '*.txt')
  for file in $files
  do
    echo "Decrypting $file"
    filename=$(basename $file)
    outfile=$(echo "${filename%.*}")
    [[ $outfile == $filename ]] && echo "input and output filenames can't be same" && exit
    gpg --pinentry-mode loopback --output $outfile --passphrase $key --decrypt $file
  done
fi

echo "Done"
