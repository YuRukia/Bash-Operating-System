#! /bin/bash

AFON=""

fileNameVer()
{
        sleep 2
                echo "Enter Alternate File Output Name?"
                read AFO
        if [[ $AFO == "y" ]]
        then
                echo "Enter Alternate File Output Name: "
                read AFON
        else
                AFON="a"
        fi
        sleep 1        
}
