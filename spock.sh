#!/bin/bash

function check_boot_part_manual()
{
	exit 0
}

function check_boot_part()
{
	exit 0
}


dialog --backtitle "SPOCK v1.0" --title Welcome --textbox welcome.msg 10 40

#ustalenie jakie dyski i partycje beda przenoszone na VM

tmp=$(fdisk -l | grep '^/' | sed 's/\*//' | awk '{print $1"-"$2"-"$3"-"$4"-"$5"-"$6 } ')
cmd=""
for i in $tmp; do
	item=$(echo $i | awk 'BEGIN {FS="-"} {print $6 }')
	tag=$(echo $i | awk 'BEGIN {FS="-"} {print $1}')
	if ! [ $item == 'Extended' ]; then cmd="$cmd $tag ${item} 0" ; fi
done
while ! [ -f /tmp/partitions ] ;
do
	dialog --backtitle "SPOCK v1.0" --title Partitions --checklist "Chosse partitions to migrate" 10 60 10 $cmd 2> /tmp/partitions
	size=$(du /tmp/partitions | awk '{print $1}')
	if [ $size -lt 5 ]; then rm /tmp/partitions; fi
done

dialog --backtitle "SPOCK v1.0" --title "MBR Grub" --yesno "Do you wish to select manualy the partition with /boot?" 5 60
yesno=$?

if [ $yesno -eq 0 ];
then
	ok=1;
	while [ $ok -eq 1 ];
	do
		while ! [ -f /tmp/grubver ] ;
		do
			dialog --backtitle "SPOCK v1.0" --title "MBR Grub" --radiolist "Chosse bootloader" 10 60 5 grub "version 1" 0 grub2 "vesion 2" 0 2> /tmp/grubver
			size=$(du /tmp/grubver | awk '{print $1}')
			if [ $size -lt 5 ]; then rm /tmp/grubver; fi
		done
		cmd=""
		for i in `cat /tmp/partitions | sed 's/"//g'`; do
			item=$i
			tag=$i
			cmd="$cmd $tag $item 0"
		done

		while ! [ -f /tmp/bootpart ] ;
		do
			dialog --backtitle "SPOCK v1.0" --title "/boot location" --radiolist "Chosse partition with /boot" 10 60 5 $cmd 2> /tmp/bootpart
			size=$(du /tmp/bootpart | awk '{print $1}')
			if [ $size -lt 5 ]; then rm /tmp/bootpart; fi
		done
		ok=$(check_boot_part_manual)
	done
fi

dialog --backtitle "SPOCK v1.0" --title "Remote Server" --inputbox "Input hostname or IP of remote server" 10 50

dialog --backtitle "SPOCK v1.0" --title "Remote Server" --inputbox "Input login" 10 50

dialog --backtitle "SPOCK v1.0" --title "Remote Server" --passwordbox "Input password to remote server" 10 50

dialog --backtitle "SPOCK v1.0" --title "Remote Server" --inputbox "Destination dir for operations" 10 50

dialog --backtitle "SPOCK v1.0" --title "Processors" --inputbox "Number of CPUs for VM" 10 50

dialog --backtitle "SPOCK v1.0" --title "Memory" --inputbox "Memory in MB for VM" 10 50


