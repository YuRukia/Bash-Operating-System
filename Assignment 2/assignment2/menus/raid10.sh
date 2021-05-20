#!/bin/bash
source ./raidFuncs.sh

clear
echo "RAID 10"
fileNameVer
echo "HDD Permaters Loaded: $(sed -n '4p' < $1)"
sleep 1
echo "Performing Operations..."

HDDs=$(echo $(sed -n '4p' < $1) | cut -d ':' -f1)
seekSpeed=$(echo $(sed -n '4p' < $1) | cut -d ':' -f2)
rwSpeed=$(echo $(sed -n '4p' < $1)  | cut -d ':' -f3)

tasks=()
seek=()
rw=()

while IFS= read -r line
do
        tasks+=($line)
done < $2

for value in "${tasks[@]}"
do
        echo $value
done

#Last Job/Current Job|Read/Write Parallel
ljb=""
cjb=""
RPARA=0
WPARA=0

for (( i=0; i<${#tasks[@]}; i++ ))
do
        cjb=$(echo ${tasks[$i]} | head -c 1)
        if [[ $cjb == "R" ]]       
        then
                #echo "A - $PARA - $cjb"
                if (( $RPARA == $(($HDDs - 1)) ))
                then
                        RPARA=0
                        seek+=("PARA")
                        rw+=(0)
                elif (( $RPARA > 0 ))
                then
                        RPARA=$(($RPARA+1))
                        seek+=("PARA")
                        rw+=(0)
                else
                        RPARA=$(($RPARA+1))
                        seek+=($seekSpeed)
                        rw+=($rwSpeed)
                fi
                WPARA=0
        else
                if (( $WPARA == $(($HDDs / 2 - 1)) ))
                then
                        WPARA=0
                        seek+=("PARA")
                        rw+=(0)
                elif (( $WPARA > 0 ))
                then
                        WPARA=$(($WPARA+1))
                        seek+=("PARA")
                        rw+=(0)
                else
                        WPARA=$(($WPARA+1))
                        seek+=($seekSpeed)
                        rw+=($rwSpeed)
                fi
                RPARA=0
        fi
        ljb=$(echo ${tasks[$i]} | head -c 1)
done

rm -f "$AFON.out"

#Print results and calculate total runtime
for (( i=0; i<${#tasks[@]}; i++))
do
        echo "${tasks[$i]}:${seek[$i]}:${rw[$i]}"
        echo "${tasks[$i]}:${seek[$i]}:${rw[$i]}" >> "$AFON.out"
        if (( ${seek[$i]} != "PARA" ))
        then
                total=$((${seek[$i]}+${rw[$i]}))
                totalRuntime=$(($totalRuntime+$total))
        fi
done

echo "Total Runtime: $totalRuntime"
echo "Total Runtime: $totalRuntime" >> "$AFON.out"

read pause

echo "Returning to Main Menu"
sleep 2
