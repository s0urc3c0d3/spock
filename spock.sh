#!/bin/bash

#dialog --backtitle "SPOCK v1.0" --title Welcome --textbox welcome.msg 10 40

#ustalenie jakie dyski i partycje beda przenoszone na VM

tmp=$(fdisk -l | grep '^/' | sed 's/\*//' | awk '{print $1"-"$2"-"$3"-"$4"-"$5"-"$6 } ')
cmd=""
for i in $tmp; do
	item=$(echo $i | awk 'BEGIN {FS="-"} {print $6 }')
	tag=$(echo $i | awk 'BEGIN {FS="-"} {print $1}')
	cmd="$cmd $tag ${item} 0" 
done
#dialog --backtitle "SPOCK v1.0" --title Partitions --checklist "Chosse partitions to migrate" 10 60 10 $cmd 2> /tmp/partitions

#dialog --backtitle "SPOCK v1.0" --title "MBR Grub" --yesno "Do you wish to select manualy the partition with /boot?" 5 60

#dialog --backtitle "SPOCK v1.0" --title "MBR Grub" --radiolist "Chosse bootloader" 10 60 5 grub "version 1" 0 grub2 "vesion 2" 0

cmd=""
for i in `cat /tmp/partitions | sed 's/"//g'`; do
	item=$i
	tag=$i
	cmd="$cmd $tag $item 0"
done

#dialog --backtitle "SPOCK v1.0" --title "/boot location" --radiolist "Chosse partition with /boot" 10 60 5 $cmd


#dialog --backtitle "SPOCK v1.0" --title "Remote Server" --inputbox "Input hostname or IP of remote server" 10 50

#dialog --backtitle "SPOCK v1.0" --title "Remote Server" --inputbox "Input login" 10 50

#dialog --backtitle "SPOCK v1.0" --title "Remote Server" --passwordbox "Input password to remote server" 10 50

#dialog --backtitle "SPOCK v1.0" --title "Remote Server" --inputbox "Destination dir for operations" 10 50
