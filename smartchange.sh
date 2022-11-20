#!/bin/bash

if ! command -v smartctl >/dev/null ; then
	echo "This script requires smartctl to be installed"
	echo ""
	apt install smartctl
fi

date=$(date)
echo "-----------------------------------------------------" >> smartvalue.txt
echo "${date}" >> smartvalue.txt

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

echo "" >> smartvalue.txt
echo "drive=${drive}" >> smartvalue.txt
echo "status=${smarthealth}" >> smartvalue.txt
echo "" >> smartvalue.txt
echo "S.M.A.R.T:" >> smartvalue.txt
echo "Reallocated_Sector_Ct(5)=${rsc}" >> smartvalue.txt
echo "Reported_Uncorrect(187)=${ru}" >> smartvalue.txt
echo "Command_Timeout(188)=${ct}" >> smartvalue.txt
echo "Current_Pending_Sector(197)=${cps}" >> smartvalue.txt
echo "Offline_Uncorrectable(198)=${ou}" >> smartvalue.txt
echo "" >> smartvalue.txt

echo "$smarthealth"

done