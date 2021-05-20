#!/bin/bash
source ./raidFuncs.sh

clear
echo "RAID 1"
fileNameVer
echo "HDD Permaters Loaded: $(sed -n '3p' < $1)"
sleep 1
echo "Performing Operations..."

#Read variables from HDD.fg file
HDDs=$(echo $(sed -n '3p' < $1) | cut -d ':' -f1)
seekSpeed=$(echo $(sed -n '3p' < $1) | cut -d ':' -f2)
rwSpeed=$(echo $(sed -n '3p' < $1)  | cut -d ':' -f3)

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

#Last Job(Number)/Current Job(Number)|Read Parallel
ljb=""
ljbn=""
cjb=""
cjbn=""
PARA=0

for (( i=0; i<${#tasks[@]}; i++ ))
do
        #Set current job (>R|10) and job number (R|>10)
        cjb=$(echo ${tasks[$i]} | head -c 1)
        cjbn=$(echo ${tasks[$i]} | cut -c 2-) 

        #Check if current job is a read operation
        if [[ $cjb == "R" ]] 
        then
                #echo "A - $PARA - $cjb"
                #Check if parallel operations are below upper limit
                if (( $PARA == $(($HDDs - 1)) ))
                then
                        PARA=0
                        seek+=("PARA")
                        rw+=(0)
                elif (( $PARA > 0 ))
                then
                        PARA=$(($PARA+1))
                        seek+=("PARA")
                        rw+=(0)
                else
                        PARA=$(($PARA+1))
                        seek+=($seekSpeed)
                        rw+=($rwSpeed)
                fi
        else
                if [[ $cjb == $ljb ]]
                then
                        #Check if job is sequential read +/-
                        if [[ $cjbn -eq $ljbn-1 ]] || [[ $cjbn -eq $ljbn+1 ]]
                        then
                                #echo "B - $PARA - $cjb"
                                seek+=(0)
                                rw+=($rwSpeed)
                        else
                                #echo "C - $PARA - $cjb"
                                seek+=($seekSpeed)
                                rw+=($rwSpeed)
                        fi
                else
                        seek+=($seekSpeed)
                        rw+=($rwSpeed)
                fi
                PARA=0
        fi

        #Set just finished job (>R|10) and job number (R|>10)
        ljb=$(echo ${tasks[$i]} | head -c 1)
        ljbn=$(echo ${tasks[$i]} | cut -c 2-)
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
