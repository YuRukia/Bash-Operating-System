#!/bin/bash

clear
echo "this is a place holder FOR RAID100"
echo "HDDs = $1"
echo "Seek = $2"
echo "RW = $3"

#OooOoOoOooo whats this new key word?
shift 3

for var in "$@"
do
    	echo "$var"
done


sleep 5

return 0