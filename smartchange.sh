#!/bin/bash

if ! command -v smartctl >/dev/null ; then
	echo "This script requires smartctl to be installed"
	echo ""
	apt install smartctl
fi

if [ ! -d "logs" ]; then
    mkdir logs
fi

date=$(date)
echo "-----------------------------------------------------" >> "logs/smartvalue - ${date}.txt"
echo "${date}" >> "logs/smartvalue - ${date}.txt"

for drive in /dev/sd[a-z] /dev/sd[a-z][a-z]
do

if [[ ! -e $drive ]]; then continue ; fi

echo -n "$drive "

rsc=$(smartctl -a $drive 2>/dev/null | grep Reallocated_Sector_Ct | awk '{ print $10 }')
ru=$(smartctl -a $drive 2>/dev/null | grep Reported_Uncorrect | awk '{ print $10 }')
ct=$(smartctl -a $drive 2>/dev/null | grep Command_Timeout | awk '{ print $10 " " $11 " " $12 }')
cps=$(smartctl -a $drive 2>/dev/null | grep Current_Pending_Sector | awk '{ print $10 }')
ou=$(smartctl -a $drive 2>/dev/null | grep Offline_Uncorrectable | awk '{ print $10 }')
smarthealth=$(smartctl -H $drive 2>/dev/null | grep '^SMART overall' | awk '{ print $6 }')

# smartvalue log

echo "" >> "logs/smartvalue - ${date}.txt"
echo "drive=${drive}" >> "logs/smartvalue - ${date}.txt"
echo "status=${smarthealth}" >> "logs/smartvalue - ${date}.txt"
echo "" >> "logs/smartvalue - ${date}.txt"
echo "S.M.A.R.T:" >> "logs/smartvalue - ${date}.txt"
echo "Reallocated_Sector_Ct(5)=${rsc}" >> "logs/smartvalue - ${date}.txt"
echo "Reported_Uncorrect(187)=${ru}" >> "logs/smartvalue - ${date}.txt"
echo "Command_Timeout(188)=${ct}" >> "logs/smartvalue - ${date}.txt"
echo "Current_Pending_Sector(197)=${cps}" >> "logs/smartvalue - ${date}.txt"
echo "Offline_Uncorrectable(198)=${ou}" >> "logs/smartvalue - ${date}.txt"
echo "" >> "logs/smartvalue - ${date}.txt"

echo "$smarthealth"

done