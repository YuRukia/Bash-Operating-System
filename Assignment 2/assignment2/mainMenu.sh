#! /bin/bash
source ./funcs.sh

loginLoop=0
userLoggedIn=""
userLoggedInTimer=0

#Logs user in
while [ $loginLoop -lt 1 ]
do
        clear
        echo "Please Enter Your Username"
        read userName
        exitVerification $userName
        userName=$(echo "$userName" | tr '[:upper:]' '[:lower:]')
        retUsername=$(cat ./users/UPP.db | grep $userName | cut -d: -f1)
        #Compares entered username to usernames in database, also checks to see if input is null
        if [[ $userName == $retUsername && ! -z $userName ]]
        then
                echo "User Found. Please Enter User Password: "
                read userPassword
                userPassword=$(echo "$userPassword" | tr '[:upper:]' '[:lower:]')
                retPassword=$(cat ./users/UPP.db | grep $userName | grep $userPassword | cut -d: -f2)
                #Compares entered password to passwords in database
                if [[ $userPassword == $retPassword && ! -z $userPassword ]]
                then
                        echo "User Password Correct. Logging In."
                        userLoggedIn=$userName
                        #Enters user login to the log file
                        userLoginLog $userName
                        #Starts counting how long the user has been using the system
                        userLoggedInTimer=$SECONDS
                        loginLoop=$(($loginLoop+1))
                        sleep 1
                else
                        echo "Password Incorrect"
                        read pause
                fi
        else
                echo "User Not Found"
                read pause
        fi
done

#Runs Loading Animation
#animationFunc
createConfig "HDD.cfg"
HDDConfig="./HDD.cfg"
createConfig "sim.job"
simLoc="./sim.job"

#Main Manu selection 
menuLoop=0
while [ $menuLoop -lt 1 ]
do
        menuLoop=0
        SHDD=0
        R0=0
        R1=0
        R01=0
        R100=0
        while [ $menuLoop -lt 1 ]
        do
                clear
                echo "----------"
                echo " Log Menu "
                echo "----------"

                echo -e "\e[31m1 - Single HDD"
                echo -e "\e[32m2 - Raid 0"
                echo -e "\e[33m3 - Raid 1"
                echo -e "\e[34m4 - Raid 01"
                echo -e "\e[35m5 - Raid 100"
                echo -e "\e[36m6 - Update User Password"
                echo -e "\e[0m7 - Exit"
                echo "Enter Choice: "
                read menuChoice
                exitVerification $menuChoice
                
                #Takes user entry and selects choice, ignores incorrect input
                case $menuChoice in
                1)
                        #Calls menu scripts
                        #animationFunc
                        source ./menus/singleHDD.sh "$HDDConfig" "$simLoc"
                        #Increments times used
                        SHDD=$(($SHDD+1))
                        ;;
                2)
                        #animationFunc
                        source ./menus/raid0.sh "$HDDConfig" "$simLoc"
                        R0=$(($RO+1))
                        ;;
                3)
                        #animationFunc
                        source ./menus/raid1.sh "$HDDConfig" "$simLoc"
                        R1=$(($R1+1))
                        ;;
                4)
                        #animationFunc
                        source ./menus/raid01.sh "$HDDConfig" "$simLoc"
                        R01=$(($R01+1))
                        ;;
                5)
                        #animationFunc
                        source ./menus/raid100.sh "$HDDConfig" "$simLoc"
                        R100=$(($R100+1))
                        ;;
                6)
                        source ./admin.sh
                        #Calls user version of update user, just updates their own password
                        updateUser 0 $userName
                        ;;
                7)
                        duration=$(( SECONDS - userLoggedInTimer ))
                        #Enters number of times sims are used to log
                        userSimLog $SHDD $R0 $R1 $R01 $R100
                        #Enters user exit to log
                        userExitLog $duration 1
                        menuLoop=$(($menuLoop+1))
                        #animationFunc
                        ;;
                esac
        done
done
