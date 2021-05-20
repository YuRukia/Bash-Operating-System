#!/bin/bash

#This is skel code

#Global Vars

Uname=""
HDDs=0
Seek=0
RW=0
SimData=""

#Menu Display & Select
Menu()
{
clear
echo "HDD SIM MENU:"
echo "Make your selection or type bye to exit:" 
echo "1 for Single HDD"
echo "2 for RAID 0"
echo "3 for RAID 1"
echo "4 for RAID 01"
echo "5 for RAID 100"
echo "bye for exit"
echo "Please Enter Selection:"
read Sel
MenuSel $Sel
}


# Simple Check Bye & selection (only place of exit in this code!)
Bye()
{
echo "Are you sure you want to Exit? Y/N"
read Ans
Awnser=$(echo $Ans | tr [:lower:] [:upper:])

if [ $Awnser == Y ]
	then
	exit 0
elif [ $Awnser == N ]
	then
  	return 0
fi
}

#Menu case
MenuSel()
{

# These are known, so we can just cut them out (HDD Configs)!
HDDs=$(cat hdd.cfg | cut -d ';' -f 1)
Seek=$(cat hdd.cfg | cut -d ';' -f 2)
RW=$(cat hdd.cfg | cut -d ';' -f 3)

SimData=""
index=0;
while read line; do
SimData="$SimData $line"
((index++))
done < sim.job

temp=$(echo $1 | tr [:lower:] [:upper:])
case $temp in
	1) bash HDD.sh $HDDs $Seek $RW $SimData;;
    2) bash RAID0.sh $HDDs $Seek $RW $SimData;;
	3) bash RAID1.sh $HDDs $Seek $RW $SimData;;
	4) bash RAID01.sh $HDDs $Seek $RW $SimData;;
	5) bash RAID100.sh $HDDs $Seek $RW $SimData;;
	BYE) Bye;;
	*) echo "Invalid Selection"
	sleep 1
	Menu;;
esac
}


#####################
### RUNNING CODE ####
#####################

#Store username in global var
clear
echo "Please Enter Username"
read Uname

while true;do
	Menu
done