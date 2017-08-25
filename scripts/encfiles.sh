#!/bin/bash

# USAGE 'encfiles [[ -e or -d]] -k <path to keyfile> <optional file name>'
# if file name is not specified all files in the current directory (except with .txt extension) are recursively operated upon

dir=$(pwd)

while getopts ":edk:" opt; do
  case $opt in
    "e")
      mode="encrypt"
      ;;
    "d")
      mode="decrypt"
      ;;
    "k")
      keyfile=$OPTARG
      ;;
    "?")
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    ":")
      echo "Option -$OPTARG requires location of keyfile" >&2
      exit 1
      ;;
  esac
done

if [[ -z $mode ]] || [[ -z $keyfile ]]
then
  echo "USAGE 'encfiles [[ -e or -d]] -k <path to keyfile> <optional path to file to operate on>'"
  exit
fi

filesp=${@:$OPTIND:1}
[[ ! -z "$filesp" ]] && echo "Working only the file "$filesp"" || echo "Encrypting all files in $dir recursively"

echo "Enter keyfile password"
read -s pass

#decrypt the keyfile and get key
res=$(openssl enc -aes-256-cbc -d -in $keyfile -a -k $pass 2>&1) && key=$res
[[ -z $key ]] && echo "Decrypting keyfile failed" && exit

if [[ $mode == "encrypt" ]]
then
  [[ ! -z "$filesp" ]] && files="$filesp" || files=$(find $dir -type f -not -iname '*.txt')
  for file in $files
  do
    echo "Encrypting $file"
    openssl enc -aes-256-cbc -salt -in $file -out $file.txt -a -k $key
    echo "Removing plain text file"
    rm $file
  done
else
  [[ ! -z "$filesp" ]] && files="$filesp" || files=$(find $dir -type f -iname '*.txt')
  for file in $files
  do
    # skip if file and keyfile are same
    test $file -ef $keyfile && continue
    echo "Decrypting $file"
    filename=$(basename $file)
    outfile=$(echo "${filename%.*}")
    [[ $outfile == $filename ]] && echo "input and output filenames can't be same" && exit
    openssl enc -aes-256-cbc -d -in $file -out $outfile -a -k $key
  done
fi

echo "Done"
