#!/bin/bash
source ./raidFuncs.sh

clear
echo "RAID 0"
fileNameVer
echo "HDD Permaters Loaded: $(sed -n '2p' < $1)"
sleep 1
echo "Performing Operations..."

#Read variables from HDD.cfg file
HDDs=$(echo $(sed -n '2p' < $1) | cut -d ':' -f1)
seekSpeed=$(echo $(sed -n '2p' < $1) | cut -d ':' -f2)
rwSpeed=$(echo $(sed -n '2p' < $1)  | cut -d ':' -f3)

#Array that stores job tasks
tasks=()

#Arrays that store results
seek=()
rw=()

totalRuntime=0

#Read sim.job into tasks array
while IFS= read -r line
do
        tasks+=($line)
done < $2

#Last Job/Current Job
ljb=""
cjb=""
PARA=0

for (( i=0; i<${#tasks[@]}; i++ ))
do
        #Set current job (>R|10)
        cjb=$(echo ${tasks[$i]} | head -c 1)

        #Check if current job is the same type as last job, R=R / W=W
        #And check if parallel operations is less than the upper limit
        if [[ $cjb == $ljb ]] && (( $PARA < $HDDs-1 ))
        then
                PARA=$(($PARA+1))
                seek+=("PARA")
                rw+=(0)
        else
                PARA=0
                seek+=($seekSpeed)
                rw+=($rwSpeed)
        fi

        #Set just completed Job (>R|10)
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
