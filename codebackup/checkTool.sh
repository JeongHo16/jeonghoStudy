#!/bin/bash

USER="2020177202"
PW="jewon2020"

GIT="hconnect.hanyang.ac.kr/"
CLASS1="2021_CSE4020_"
CLASS2="11273/"

STUDENT=(
2013011770
2013011866
2014004020
2014004211
2014004220
2014004393
2014004920
2014005041
2015001103
2015004002
2015004084
2015004593
2015004984
2015005023
2015058213
2016025032
2016025069
2016025569
2016025678
2016025850
2016025896
2016026035
2016056626
2017029270
2017029370
2017029452
2017029616
2017029643
2017029652
2017029661
2017029825
2017030019
2017030082
2017030246
2017030291
2017030337
2017030364
2017030382
2017030400
2017030528
2017036335
2018000300
2018000319
2018000328
2018000346
2018007838
2018008531
2018086244
2019000982
2019009261
2019017974
2019030673
2019094511
2019097656
9011220211
9013720216
9016120210
9024820217
9103920209
)

count=0
students_num=${#STUDENT[@]}
echo $students_num   #학생 수 보여줌

echo clone = c, pull = p, execute all = e
echo "==========================================================================="
read input

if [ "$input" == "c" ];then 
	for sNum in "${STUDENT[@]}";do
		echo "==========================================================================="
		git clone "https://$USER:$PW@$GIT$CLASS1$CLASS2$CLASS1$sNum"
		count=$(($count+1))
		echo "$CLASS1$sNum is cloned	$count"
	done
elif [ "$input" == "p" ];then
	for sNum in "${STUDENT[@]}";do
		currentDirectory=$CLASS1$sNum
		echo "==========================================================================="
		count=$(($count+1))
		echo "$currentDirectory		$count"
		cd ./$currentDirectory
		git pull
		cd ../
	done
elif [ "$input" == "e" ];then
	workon test # virtualenv activate
	echo Type Assignment Number and Problem Number.
	read num1 num2
	echo Start check
	for sNum in "${STUDENT[@]}";do
		currentDirectory=$CLASS1$sNum
		echo "==========================================================================="
		count=$(($count+1))
		echo "$currentDirectory		$count"
		read

		cd ./$currentDirectory
		#dir=$(ls -l | grep d | wc -l)
		#echo $dir
		assignmentName=$(find . -name "$sNum-$num1-$num2.py")
		if [ -n "${assignmentName}" ]; then
			python3 ${assignmentName:2}
			read
			vi ${assignmentName:2}
		else
			echo no file
		fi
		cd ../
	done
	deactivate
fi
#
#if [ "$input" == "rm" ];then
#	while [ $count -ne $students_num ];
#	do
#		rm -rf ''${STUDENT[${count}]}''
#		count=$((count+1))
#	done
#fi
