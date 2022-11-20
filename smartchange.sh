#!/bin/bash

if ! command -v smartctl >/dev/null ; then
	echo "This script requires smartctl to be installed"
	echo ""
	apt install smartctl
fi

if [ ! -d "logs" ]; then
    mkdir logs
fi

if [ ! -d "changes" ]; then
    mkdir changes
fi

date=$(date)
unset -v latest
for file in "logs"/*; do
  [[ $file -nt $latest ]] && latest=$file
done

echo "-----------------------------------------------------" >> "logs/smartvalue - ${date}.txt"
echo "${date}" >> "logs/smartvalue - ${date}.txt"

for drive in /dev/sd[a-z] /dev/sd[a-z][a-z]
do

if [[ ! -e $drive ]]; then continue ; fi

echo -n "$drive "

changersc=$(grep -A 8 "$drive" "$file" 2>/dev/null | grep Reallocated_Sector_Ct |  cut -d "=" -f2)
changeru=$(grep -A 8 "$drive" "$file" 2>/dev/null | grep Reported_Uncorrect |  cut -d "=" -f2)
changect=$(grep -A 8 "$drive" "$file" 2>/dev/null | grep Command_Timeout |  cut -d "=" -f2)
changecps=$(grep -A 8 "$drive" "$file" 2>/dev/null | grep Current_Pending_Sector |  cut -d "=" -f2)
changeou=$(grep -A 8 "$drive" "$file" 2>/dev/null | grep Offline_Uncorrectable |  cut -d "=" -f2)
rsc=$(smartctl -a "$drive" 2>/dev/null | grep Reallocated_Sector_Ct | awk '{ print $10 }')
ru=$(smartctl -a "$drive" 2>/dev/null | grep Reported_Uncorrect | awk '{ print $10 }')
ct=$(smartctl -a "$drive" 2>/dev/null | grep Command_Timeout | awk '{ print $10 " " $11 " " $12 }')
cps=$(smartctl -a "$drive" 2>/dev/null | grep Current_Pending_Sector | awk '{ print $10 }')
ou=$(smartctl -a "$drive" 2>/dev/null | grep Offline_Uncorrectable | awk '{ print $10 }')
smarthealth=$(smartctl -H "$drive" 2>/dev/null | grep '^SMART overall' | awk '{ print $6 }')

# change detection

if [[ $rsc == '' || $changersc == '' ]]; then true; elif [ "$rsc" != "$changersc" ]; then echo "$date | $drive | Reallocated_Sector_Ct=$rsc --> $changersc" >> "changes/smartchangelog - ${date}.txt"; fi
if [[ $ru == '' || $changeru == '' ]]; then true; elif [ "$ru" != "$changeru" ]; then echo "$date | $drive | Reallocated_Sector_Ct=$ru --> $changeru" >> "changes/smartchangelog - ${date}.txt"; fi
if [[ $ct == '' || $changect == '' ]]; then true; elif [ "$ct" != "$changect" ]; then echo "$date | $drive | Reallocated_Sector_Ct=$ct --> $changect" >> "changes/smartchangelog - ${date}.txt"; fi
if [[ $cps == '' || $changecps == '' ]]; then true; elif [ "$cps" != "$changecps" ]; then echo "$date | $drive | Reallocated_Sector_Ct=$cps --> $changecps" >> "changes/smartchangelog - ${date}.txt"; fi
if [[ $ou == '' || $changeou == '' ]]; then true; elif [ "$ou" != "$changeou" ]; then echo "$date | $drive | Reallocated_Sector_Ct=$ou --> $changeou" >> "changes/smartchangelog - ${date}.txt"; fi

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