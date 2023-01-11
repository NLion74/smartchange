#!/bin/bash

# Detecting if smartctl is installed

if ! command -v smartctl >/dev/null ; then
	echo "This script requires smartctl to be installed"
	echo ""
	apt install smartctl
fi

# Looking for existing logs and changes directory
if [ ! -d "${Workingdir}${Folder}logs" ]; then
    /bin/mkdir ${Workingdir}${Folder}logs
fi

if [ ! -d "${Workingdir}${Folder}changes" ]; then
    /bin/mkdir ${Workingdir}${Folder}changes
fi

# Folder Variables

Folder='smartcheck/'
Workingdir=$HOME/

# Getting latest Smartvaluelog
unset -v latest
for file in "${Workingdir}${Folder}logs"/*; do
  [[ $file -nt $latest ]] && latest=$file
done

# Initiating Smartvaluelog

date=$(date)
echo "-----------------------------------------------------" >> "${Workingdir}${Folder}logs/smartvalue - ${date}.txt"
echo "${date}" >> "${Workingdir}${Folder}logs/smartvalue - ${date}.txt"

# Detecting Drives

for drive in /dev/sd[a-z] /dev/sd[a-z][a-z]
do

if [[ ! -e $drive ]]; then continue ; fi

echo -n "$drive "

# detecting changes, collecting smartctl data and running smarthealth test 

changersc=$(grep -A 8 "$drive" "$file" 2>/dev/null | grep Reallocated_Sector_Ct |  cut -d "=" -f2)
changeru=$(grep -A 8 "$drive" "$file" 2>/dev/null | grep Reported_Uncorrect |  cut -d "=" -f2)
changect=$(grep -A 8 "$drive" "$file" 2>/dev/null | grep Command_Timeout |  cut -d "=" -f2)
changecps=$(grep -A 8 "$drive" "$file" 2>/dev/null | grep Current_Pending_Sector |  cut -d "=" -f2)
changeou=$(grep -A 8 "$drive" "$file" 2>/dev/null | grep Offline_Uncorrectable |  cut -d "=" -f2)
rsc=$(/bin/bash -c '/usr/sbin/smartctl -a '$drive'' | grep Reallocated_Sector_Ct | awk '{ print $10 }')
ru=$(/bin/bash -c '/usr/sbin/smartctl -a '$drive'' | grep Reported_Uncorrect | awk '{ print $10 }')
ct=$(/bin/bash -c '/usr/sbin/smartctl -a '$drive'' | grep Command_Timeout | awk '{ print $10 " " $11 " " $12 }')
cps=$(/bin/bash -c '/usr/sbin/smartctl -a '$drive'' | grep Current_Pending_Sector | awk '{ print $10 }')
ou=$(/bin/bash -c '/usr/sbin/smartctl -a '$drive'' | grep Offline_Uncorrectable | awk '{ print $10 }')
smarthealth=$(smartctl -H "$drive" 2>/dev/null | grep '^SMART overall' | awk '{ print $6 }')

# Creating Changelog

if [[ $rsc == '' || $changersc == '' ]]; then true; elif [ "$rsc" != "$changersc" ]; then echo "$date | $drive | Reallocated_Sector_Ct(5)=${changersc} --> $rsc" >> "${Workingdir}${Folder}changes/smartchangelog - ${date}.txt"; fi
if [[ $ru == '' || $changeru == '' ]]; then true; elif [ "$ru" != "$changeru" ]; then echo "$date | $drive | Reported_Uncorrect(187)=${changeru} --> $ru" >> "${Workingdir}${Folder}changes/smartchangelog - ${date}.txt"; fi
if [[ $ct == '' || $changect == '' ]]; then true; elif [ "$ct" != "$changect" ]; then echo "$date | $drive | Command_Timeout(188)=${changect} --> $ct" >> "${Workingdir}${Folder}changes/smartchangelog - ${date}.txt"; fi
if [[ $cps == '' || $changecps == '' ]]; then true; elif [ "$cps" != "$changecps" ]; then echo "$date | $drive | Current_Pending_Sector(197)=${changecps} --> $cps" >> "${Workingdir}${Folder}changes/smartchangelog - ${date}.txt"; fi
if [[ $ou == '' || $changeou == '' ]]; then true; elif [ "$ou" != "$changeou" ]; then echo "$date | $drive | 198: Offline_Uncorrectable(198)=${changeou} --> $ou" >> "${Workingdir}${Folder}changes/smartchangelog - ${date}.txt"; fi

# Creating Smartvaluelog


echo "" >> "${Workingdir}${Folder}logs/smartvalue - ${date}.txt"
echo "drive=${drive}" >> "${Workingdir}${Folder}logs/smartvalue - ${date}.txt"
echo "status=${smarthealth}" >> "${Workingdir}${Folder}logs/smartvalue - ${date}.txt"
echo "" >> "${Workingdir}${Folder}logs/smartvalue - ${date}.txt"
echo "S.M.A.R.T:" >> "${Workingdir}${Folder}logs/smartvalue - ${date}.txt"
echo "Reallocated_Sector_Ct(5)=${rsc}" >> "${Workingdir}${Folder}logs/smartvalue - ${date}.txt"
echo "Reported_Uncorrect(187)=${ru}" >> "${Workingdir}${Folder}logs/smartvalue - ${date}.txt"
echo "Command_Timeout(188)=${ct}" >> "${Workingdir}${Folder}logs/smartvalue - ${date}.txt"
echo "Current_Pending_Sector(197)=${cps}" >> "${Workingdir}${Folder}logs/smartvalue - ${date}.txt"
echo "Offline_Uncorrectable(198)=${ou}" >> "${Workingdir}${Folder}logs/smartvalue - ${date}.txt"
echo "" >> "${Workingdir}${Folder}logs/smartvalue - ${date}.txt"

# Printing Smarthealthcheck Result

echo "$smarthealth"

done