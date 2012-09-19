#!/bin/bash

#dialog --backtitle "SPOCK v1.0" --title Welcome --textbox welcome.msg 10 40

#ustalenie jakie dyski i partycje beda przenoszone na VM

tmp=$(fdisk -l | grep '^/' | sed 's/\*//' | awk '{print $1"-"$2"-"$3"-"$4"-"$5"-"$6 } ')
for i in $tmp; do
	echo $i | awk 'BEGIN {FS="-"} {print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t"$6 }'
done
echo $tmp
#dialog --backtitle "SPOCK v1.0" --title Partitions --checklist "Chosse partitions to migrate" 10 60
