#!/bin/bash
source ./raidFuncs.sh

clear
echo "RAID 100"
fileNameVer
echo "HDD Permaters Loaded: $(sed -n '5p' < $1)"
sleep 1
echo "Performing Operations..."

#Read varaibles from HDD.cfg
HDDs=$(echo $(sed -n '5p' < $1) | cut -d ':' -f1)
seekSpeed=$(echo $(sed -n '5p' < $1) | cut -d ':' -f2)
rwSpeed=$(echo $(sed -n '5p' < $1)  | cut -d ':' -f3)

#Array that stores job tasks
tasks=()

#Arrays that store results
seek=()
rw=()

totalRuntime=0

#Read sim.job into tasks Array
while IFS= read -r line
do
        tasks+=($line)
done < $2

#Last Job/Current Job|Read/Write Parallel
ljb=""
cjb=""
RPARA=0

for (( i=0; i<${#tasks[@]}; i++ ))
do
        #Set current job (>R|10)
        cjb=$(echo ${tasks[$i]} | head -c 1)

        #Check if current job is a read operation
        if [[ $cjb == $ljb ]]       
        then
                #echo "A - $PARA - $cjb"
                #Check if parallel operations are below upper limit
                if (( $PARA < $(($HDDs / 2 - 1)) ))
                then
                        PARA=$(($PARA+1))
                        seek+=("PARA")
                        rw+=(0)
                else
                        PARA=0
                        seek+=($seekSpeed)
                        rw+=($rwSpeed)
                fi
        else
                seek+=($seekSpeed)
                rw+=($rwSpeed)
                PARA=0
        fi
        #Set just finished job (>R|10)
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
