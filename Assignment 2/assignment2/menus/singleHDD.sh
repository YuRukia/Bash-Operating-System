#! /bin/bash
source ./raidFuncs.sh

clear
echo "Single HDD"
fileNameVer
echo "HDD Permaters Loaded: $(sed -n '1p' < $1)"
sleep 1
echo "Performing Operations..."

#Read variables from HDD.cfg file
HDDs=$(echo $(sed -n '1p' < $1) | cut -d ':' -f1)
seekSpeed=$(echo $(sed -n '1p' < $1) | cut -d ':' -f2)
rwSpeed=$(echo $(sed -n '1p' < $1) | cut -d ':' -f3)

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

#Last Job(Number)/Current Job(Number)
ljb=""
ljbn=""
cjb=""
cjbn=""

for (( i=0; i<${#tasks[@]}; i++ ))
do
        #Set current job (>R|10) and job number (R|>10)
        cjb=$(echo ${tasks[$i]} | head -c 1)
        cjbn=$(echo ${tasks[$i]} | cut -c 2-)

        #Check if current job is the same type as last job, R=R / W=W
        if [[ $cjb == $ljb ]]
        then
                #Check if the job is a sequential read +/-
                if (( $cjbn == $ljbn-1 )) || (( $cjbn == $ljbn+1 ))
                then
                        seek+=(0)
                        rw+=($rwSpeed)
                else
                        seek+=($seekSpeed)
                        rw+=($rwSpeed)
                fi
        else
                seek+=($seekSpeed)
                rw+=($rwSpeed)
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

        total=$((${seek[$i]}+${rw[$i]}))
        totalRuntime=$(($totalRuntime+$total))
done

echo "Total Runtime: $totalRuntime"
echo "Total Runtime: $totalRuntime" >> "$AFON.out"

read pause

echo "Returning to Main Menu"
sleep 2
