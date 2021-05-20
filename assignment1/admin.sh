#! /bin/bash

adminMenu()
{
        source ./funcs.sh
        #Verifies that the user is an admin
        adminVerification
        adminLoop=0
        while [ $adminLoop -lt 1 ]
        do
                clear
                echo "------------"
                echo " Admin Menu"
                echo "------------"

                echo "1 - Create User"
                echo "2 - Remove User"
                echo "3 - Update User"
                echo "4 - Log Statistics"
                echo "5 - Exit"
                echo "Enter Choice: "
                read menuChoice

                exitVerification $menuChoice
        
                case $menuChoice in
                1)
                        createUser
                        ;;
                2)
                        deleteUser
                        ;;
                3)
                        #Calls admin version of update user, lets you update any user in database
                        updateUser 1
                        ;;
                4)
                        logStatistics
                        ;;
                5)
                        adminLoop=$(($adminLoop+1))
                        ;;
                esac
        done
clear
}

createUser()
{
        source ./funcs.sh
        nameMasterLoop=0
        while [ $nameMasterLoop -lt 1 ]
        do
                nameLoop1=0
                while [ $nameLoop1 -lt 1 ]
                do
                        echo "Enter Username: "
                        read userName1
                        #Verification for the user to exit with "Bye" and "yY/nN"
                        exitVerification $userName1
                        #Checks to see if the input is alphanumeric
                        alphanumericVerification $userName1
                        local alphaVer=$?
                        nameSize=${#userName1}
                       if [[ $nameSize -eq 5 && $alphaVer == 1 ]]
                        then
                               nameLoop1=$(($nameLoop1+1))
                       else
                               echo "Username Must Be 5 Characters"
                        fi
                done
        
                nameLoop2=0
                while [ $nameLoop2 -lt 1 ]
                do
                        echo "Re-Enter Username: "
                        read userName2
                        exitVerification $userName2
                        alphanumericVerification $userName2
                        local alphaVer2=$?
                        nameSize=${#userName2}
                        if [[ $nameSize -eq 5 && $alphaVer2 == 1 ]]
                        then
                                nameLoop2=$(($nameLoop2+1))
                        else
                               echo "Username Must Be 5 Characters"

                        fi
                done
                #Check to see if both entries are the same, if so continue, otherwise loop again
                if [ $userName1 = $userName2 ]
                then
                        nameMasterLoop=$(($nameMasterLoop+1))
                        userName=$userName1
                else
                        echo "Entries do not match"
                fi
        done
        
        passwordMasterLoop=0

        while [ $passwordMasterLoop -lt 1 ]
        do

                passwordLoop1=0
                while [ $passwordLoop1 -lt 1 ]
                do
                        echo "Enter Password: "
                        read userPassword1
                        exitVerification $userPassword1
                        alphanumericVerification $userPassword1
                        local alphaVer=$?
                        passwordSize=${#userPassword1}
                        if [[ $passwordSize -eq 5 && $alphaVer == 1 ]]
                        then
                                passwordLoop1=$(($passwordLoop1+1))
                        else
                                echo "Password Must Be 5 Characters"
                        fi
                done
                
                passwordLoop2=0
                while [ $passwordLoop2 -lt 1 ]
                do
                        echo "Re-Enter Password: "
                        read userPassword2
                        exitVerification $userPassword2
                        alphanumericVerification $userPassword2
                        local alphaVer=$?
                        passwordSize=${#userPassword2}
                        if [[ $passwordSize -eq 5 && $alphaVer == 1 ]]
                        then
                                passwordLoop2=$(($passwordLoop2+1))
                        else
                                echo "Password Must Be 5 Characters"
                        fi
                done
                
                if [ $userPassword1 = $userPassword2 ]
                then
                        passwordMasterLoop=$(($passwordMasterLoop+1))
                        userPassword=$userPassword1
                else
                        echo "Entries do not match"
                fi
        done

        masterPinLoop=0
        while [ $masterPinLoop -lt 1 ]
        do
                pinLoop1=0
                while [ $pinLoop1 -lt 1 ]
                do
                        echo "Enter PIN: "
                        read userPin1
                        exitVerification $userPin1
                        numericVerification $userPin1
                        local numVer=$?
                        pinSize=${#userPin1}
                        if [[ $pinSize -eq 3 && $numVer == 1 ]]
                        then
                                pinLoop1=$(($pinLoop1+1))
                        fi
                done
                pinLoop2=0
                while [ $pinLoop2 -lt 1 ]
                do
                        echo "Enter PIN: "
                        read userPin2
                        exitVerification $userPin2
                        numericVerification $userPin2
                        local numVer=$?
                        pinSize=${#userPin2}
                        if [[ $pinSize -eq 3 && $numVer == 1 ]]
                        then
                                pinLoop2=$(($pinLoop2+1))
                        fi
                done
                if [ $userPin1 = $userPin2 ]
                then
                        masterPinLoop=$(($masterPinLoop+1))
                        userPin=$userPin1
                else
                        echo "Entries do not match"
                fi
        done
        
        #Checks to see if username already exists in databse, if so, loop again
        retUsername=$(cat ./users/UPP.db | grep $userName | cut -d: -f1)
        if [ $userName = $retUsername ]
        then
                echo "Username In Use"
                read pause
        else
                #Enter new user into the database and strip the input of upper/lower case
                echo "$userName:$userPassword:$userPin" | tr '[:upper:]' '[:lower:]'  >> ./users/UPP.db
                cat ./users/UPP.db
        fi
}

deleteUser()
{
        source ./funcs.sh
        userExistsLoop=0
        while [ $userExistsLoop -lt 1 ]
        do
                echo "Please Enter The Username You Wish To Delete: "
                read userName
                exitVerification $userName
                retUsername=$(cat ./users/UPP.db | grep $userName | cut -d: -f1)
                #Check to see if user exists
                if [[ $userName = $retUsername ]]
                then
                        #Delete line containing user
                        grep -v $userName ./users/UPP.db > ./users/UPPtemp.db; mv ./users/UPPtemp.db ./users/UPP.db
                        echo "$userName Removed"
                        userExistsLoop=$(($userExistsLoop+1))
                else
                        echo "Username Not Found"
                        read pause
                fi
        done
}

#Update user password function
updateUser()
{
        source ./funcs.sh
        updateUserLoop=0
        while [ $updateUserLoop -lt 1 ]
        do 
                #Checks to see if user is an admin or not
                if [ $1 = "1" ]
                then
                        echo "Please Enter The Username You Wish To Update: "
                        read userName
                        exitVerification $userName
                        alphanumericVerification $userName
                        local alphaVer=$?
                        userNameSize=${#userName}

                        if [[ $userNameSize -eq 5 && $alphaVer == 1 ]]
                        then
                                retUsername=$(cat ./users/UPP.db | grep $userName | cut -d: -f1)
                                if [[ $userName = $retUsername ]]
                                then
                                        echo "Please Enter The New Password: "
                                        read password
                                        exitVerification $password
                                        alphanumericVerification $password
                                        local alphaVer=$?
                                        passwordSize=${#password}

                                        if [[ $passwordSize -eq 5 && $alphaVer == 1 ]]
                                        then
                                                updateUserLoop=$(($updateUserLoop+1))
                                                retPassword=$(cat ./users/UPP.db | grep $userName | cut -d: -f2)
                                                lineNum=$(grep -n $userName ./users/UPP.db | cut -d: -f1)
                                                #Edits password in the user database
                                                sed -i -e "${lineNum}s/$retPassword/$password/g" ./users/UPP.db
                                        else
                                                echo "Password Must Be 5 Characters"
                                        fi

                                else
                                        echo "Username Not Found"
                                        read pause
                        
                                fi
                        else
                                echo "Username Must be 5 Characters"
                        fi
                else
                        userName="$2"
                        echo "Please Enter Your New Password: "
                        read password
                        exitVerification $password
                        alphanumericVerification $password
                        local alphaVer=$?
                        passwordSize=${#password}

                        if [[ $passwordSize -eq 5 && $alphaVer == 1 ]]
                        then
                                updateUserLoop=$(($updateUserLoop+1))
                                retPassword=$(cat ./users/UPP.db | grep $userName | cut -d: -f2)
                                lineNum=$(grep -n $userName ./users/UPP.db | cut -d: -f1)
                                sed -i -e "${lineNum}s/$retPassword/$password/g" ./users/UPP.db

                        else
                                echo "Password Must Be 5 Characters"
                        fi
                fi
        done
}

logStatistics()
{
        source ./funcs.sh

        logLoop=0
        while [ $logLoop -lt 1 ]
        do
                clear
                echo "----------"
                echo " Log Menu "
                echo "----------"

                echo "1 - View Full Log"
                echo "2 - Total User Time Online"
                echo "3 - Popular Sim: User"
                echo "4 - Popular Sim: Overall"
                echo "5 - User Ranking List"
                echo "6 - Exit"
                echo "Enter Choice: "
                read menuChoice

                exitVerification $menuChoice
        
                case $menuChoice in
                1)
                        viewFullLog
                        ;;
                2)
                        userTimeUsedLog
                        ;;
                3)
                        popularSimPerUser
                        ;;
                4)
                        popularSim                        
                        ;;
                5)      
                        userRankingList
                        ;;
                6)
                        logLoop=$(($logLoop+1))
                        ;;
                esac
        done
}

#Checks to see if you are calling admin.sh to load it's functions, or if you want to use it as a user
if [[ $1 = 1 ]]
then
        adminMenu
fi

