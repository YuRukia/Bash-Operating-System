#! /bin/bash

#When called, checks to see if user has entered "Bye", and if so, checks if input is "yY/nN"
exitVerification ()
{
        shopt -s nocasematch
        if [[ $1 == "Bye" ]]
        then
                loop=0
                while [ $loop -lt 1 ]
                do 
                        echo "Are You Sure: Y/N?"
                        read exitVerification
                        if [[ $exitVerification == "y" ]]
                        then
                                loop=$(($loop+1))
                                if [[ $2 == 1 ]]
                                then
                                        userExitLoop
                                fi
                                clear
                                exit
                        fi      
                        if [[ $exitVerification == "n" ]]
                        then
                                loop=$(($loop+1))
                        fi
                done
        fi
}

#Checks if string entered is alphanumeric or not and returns a result
alphanumericVerification ()
{
        if [[ "$1" =~ ^[[:alnum:]]*$ ]]
        then
                return 1
        else
                return 0
        fi
}

#Checks if string entered is purely numeric or not and returns a result
numericVerification ()
{
        if [[ $1 =~ ^[0-9]+$ ]]
        then
                return 1
        else
                return 0
        fi
}

#Asks the user to enter the admin pin, and loops to infinity if incorrect  unless "Bye" is entered
adminVerification()
{
        adminPinLoop=0
        while [ $adminPinLoop -lt 1 ]
        do
                echo "Please Enter Admin Pin"
                read adminPin
                exitVerification $adminPin

                if [ $adminPin = "999" ]
                then
                        adminPinLoop=$(($adminPinLoop+1))
                else
                        echo "Incorrect Pin"
                        read pause
                fi
        done
}

#Prints user login time to log file
userLoginLog()
{
        currentTime=$(date)
        echo -n "$1:LOG TIME:$currentTime|" >> ./Usage.db
}

#Prints how many times simulations were used to log file
userSimLog()
{
        echo -n "SINGLEHDD:$1|" >> ./Usage.db
        echo -n "RAID0:$2|" >> ./Usage.db
        echo -n "RAID1:$3|" >> ./Usage.db
        echo -n "RAID01:$4|" >> ./Usage.db
        echo -n "RAID100:$5|" >> ./Usage.db
}

#Prints if the user changed their password to the log file
#Depricated function, it was causing issues with the log file, so it's not in use anymore
userChangedPassword()
{
        currentTime=$(date)
        echo -n "PASSWORD CHANGE TIME:$currentTime|" >> ./Usage.db
        cat ./Usage.db
}

#Prints when the user logged out and how long they were logged in
userExitLog()
{
        currentTime=$(date)
        echo -n "LOG OUT TIME:$currentTime|SESSION LENGTH:$1 SECONDS" >> ./Usage.db
        #Prints empty line at bottom of log file
        echo -e "\n" >> ./Usage.db
}

#Displays the full log of a specific user
viewFullLog()
{
        mainLoop=0
        while [ $mainLoop -lt 1 ]
        do
                echo "Enter Username"
                read userName
                exitVerification $userName
                retUsername=$(cat ./users/UPP.db | grep $userName | cut -d: -f1)
                if [[ $userName = $retUsername ]]
                then
                        if grep -q "$userName" ./Usage.db;
                        then
                                cat ./Usage.db | grep $userName
                                read pause

                                mainLoop=$(($mainLoop+1))
                        else
                                echo "User Has No Logs"
                                read pause
                        fi
                else
                        echo "Username Not Found"simulations
                        read pause
                fi
        done
}

#Displays how long a specific user has been online
userTimeUsedLog()
{
        mainLoop=0
        while [ $mainLoop -lt 1 ]
        do
                rm -f tempAdd.txt
                echo "Enter Username"
                read userName
                exitVerification $userName
                retUsername=$(cat ./users/UPP.db | grep $userName | cut -d: -f1)
                if [[ $userName = $retUsername ]]
                then
                        rm -f tempAdd.txt
                        time=0
                        if grep -q "$userName" ./Usage.db;
                        then
                                cat ./Usage.db | grep $userName | rev | cut -d '|' -f1 | rev | cut -d ':' -f2 | tr -dc '0-9\n' >> tempAdd.txt
                                while IFS= read -r line 
                                do
                                        time=$(($time+$line))
                                done < ./tempAdd.txt
                                rm -f tempAdd.txt
                                echo "Time Online:$time"
                                read pause
                                mainLoop=$(($mainLoop+1))
                        else
                                echo "User Has No Logs"
                                read pause
                        fi
                else
                        echo "Username Not Found"
                        read pause
                fi
        done
}

#Displays the most popular sim for a specific user
popularSimPerUser()
{
        mainLoop=0
        while [ $mainLoop -lt 1 ]
        do
                #Remove temporary files that might still exist
                rm -f tempAdd.txt
                rm -f tempArray.txt
                echo "Enter Username"
                read userName
                exitVerification $userName
                retUsername=$(cat ./users/UPP.db | grep $userName | cut -d: -f1)
                if [[ $userName = $retUsername ]]
                then
                        SHDD=0
                        R0=0
                        R1=0
                        R01=0
                        R100=0
                        if grep -q "$userName" ./Usage.db;
                        then
                                rm -f tempAdd.txt
                                rm -f tempArray.txt
                                
                                popularSimFunc "$userName" 2 "SINGLEHDD"
                                popularSimFunc "$userName" 3 "RAID0"
                                popularSimFunc "$userName" 4 "RAID1"
                                popularSimFunc "$userName" 5 "RAID01"
                                popularSimFunc "$userName" 6 "RAID100"
                                
                                sort -t":" -k2 -nr -o tempArray.txt tempArray.txt
                                cat tempArray.txt | head -n 1
                                rm -f tempArray.txt
                                rm -f tempAdd.txt
                                read pause

                                mainLoop=$(($mainLoop+1))
                        else
                                echo "User Has No Logs"
                                read pause
                        fi
                else
                        echo "Username Not Found"
                        read pause
                fi
        done
}

#Displays the most popular sim overall
popularSim()
{
        mainLoop=0
        while [ $mainLoop -lt 1 ]
        do
                rm -f tempAdd.txt
                rm -f tempArray.txt

                popularSimFunc "SINGLEHDD" 2 "SINGLEHDD"
                popularSimFunc "RAID0" 3 "RAID0"
                popularSimFunc "RAID1" 4 "RAID1"
                popularSimFunc "RAID01" 5 "RAID01"
                popularSimFunc "RAID100" 6 "RAID100"
                
                sort -t":" -k2 -nr -o tempArray.txt tempArray.txt
                cat tempArray.txt | head -n 1
                rm -f tempAdd.txt
                rm -f tempArray.txt
                read pause

                mainLoop=$(($mainLoop+1))
        done
}

#Displays ranking of users, based on whoever has been logged in the longest
userRankingList()
{
        rm -f tempAdd.txt

        #Add all usernames to file
        cat ./users/UPP.db | cut -d ':' -f1 >> tempAdd.txt
        #Create temp files containing the time logged in for each user
        while IFS= read -r line
        do
                #Pipe is reversed so that it always gets the last field
                #Because the log may or may not contain a "Password Changed" field
                #Password Change Log no longer in use, but this still works perfectly so why change it
                cat ./Usage.db | grep "$line" | rev | cut -d '|' -f1 | rev | cut -d ':' -f2 | tr -dc '0-9\n' >> "$line.txt"
        done < ./tempAdd.txt

        #Add together all time logged in for each user to a single line, then write to file
        while IFS= read -r line
        do
                paste -sd+ "$line.txt" | bc >> result.txt
        done < ./tempAdd.txt

        #Add usernames and the time they spent logged in to a single file
        paste tempAdd.txt result.txt > output.txt
        #Sort file by second column numerically
        sort -k2 -nr -o output.txt output.txt
        cat output.txt

        #Delete all temporary files used
        while IFS= read -r line
        do
                rm -f "$line.txt"
        done < ./tempAdd.txt
        rm -f tempAdd.txt
        rm -f result.txt
        rm -f output.txt

        read pause
}

#Prints how long a user has been online to tempArray.txt
popularSimFunc()
{
        result=0
        cat ./Usage.db | grep $1 | cut -d '|' -f$2 | cut -d ':' -f2 | tr -dc '0-9\n' >> tempAdd.txt
        while IFS= read -r line 
        do
                result=$(($result+$line))
        done < ./tempAdd.txt
        rm tempAdd.txt
        echo "$3:$result"
        echo "$3:$result" >> tempArray.txt
}

#Animation function
animationFunc()
{
        local i sp n
        sp='/-\|'
        n=${#sp}
        loop=0
        clear
        #Play animation on loop for 5 seconds
        while [ $loop -lt 10 ] 
        do
                sleep 0.5
                printf "%s\b" "${sp:i++%n:1}"
                loop=$(($loop+1))
        done
        clear
}

#Creates and manages the config files
createConfig()
{
        hddLoop=0
        shopt -s nocasematch
        while [ $hddLoop -lt 1 ]
        do
                #Check if argument 1 config exists
                if [[ -f $1 ]]
                then
                        echo -n ""
                else
                        #If argument 1 is HDD.cfg, overwrite with default
                        #If sim.job, overwrite with default
                        if [[ "$1" == "HDD.cfg" ]]
                        then
                                echo "1:5:60" > $1
                                echo "4:5:60" >> $1
                        else
                                echo "R9" >1
                                echo "R9" >> $1
                                echo "W10" >> $1
                                echo "W11" >> $1
                                echo "R13" >> $1
                                echo "R18" >> $1
                                echo "R19" >> $1
                                echo "R20" >> $1
                                echo "R21" >> $1
                        fi
                fi

                echo "Do You Want To Use The Existing $1 Configuration?"
                read useConfig
                exitVerification $useConfig

                if [[ $useConfig == 'y' ]]
                then
                        echo -n ""
                else
                        #Check if argument 1 is HDD.cfg or sim.job
                        if [[ "$1" == "HDD.cfg" ]]
                        then
                                echo "Enter New Config"
                                echo "DRIVES:READ:WRITE"
                                read newConfig
                                exitVerification $newConfig
                        else
                                echo "Enter New Config"
                                echo "R/W | 0-999"
                                read newConfig
                                exitVerification $newConfig
                        fi
                        
                        #Overwrite or create config file with user input
                        echo "$newConfig" > $1
                fi
                hddLoop=$(($hddLoop+1))
        done
}
