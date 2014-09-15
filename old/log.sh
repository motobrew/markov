#!/bin/bash

LOGNAME=$1

if [ $# -ne 1 ]; then
	echo "$0 <log file>"
	exit
fi

GamesNum=0
WinsNum=0
TempRatio=0
TempWins=0
FlagWins=0
while read p1 p2 p3 p4
do
	if [ $WinsNum -gt 0 -a $TempRatio -ne $p1 ]; then
		break
	fi
	if [ $TempWins -ne $p2 ]; then
		WinsNum=`expr $WinsNum + 1`
	fi

	if [ $GamesNum -eq 0 ]; then
		GAMES_STR=$p3
		GamesNum=`expr $GamesNum + 1`
	elif [ $TempWins -ne $p2 ]; then
		FlagWins=1
	fi

	if [ $TempWins -eq $p2 -a $FlagWins -eq 0 ]; then
		GAMES_STR=${GAMES_STR},${p3}
		GamesNum=`expr $GamesNum + 1`
	fi

	TempRatio=$p1
	TempWins=$p2
done < $LOGNAME

cnt1=0
cnt2=0
while read p1 p2 p3 p4
do
	if [ $cnt1 -eq 0 ]
	then
		RATIO=`expr 100 - $p1`
		echo "勝率${RATIO}％"
		echo "トレード数,${GAMES_STR}"
		cnt1=`expr $cnt1 + 1`
	fi
	
	if [ $cnt2  -eq 0 ]
	then
		echo -n "${p2}連敗,"
	fi
	echo -n "$p4,"
	cnt2=`expr $cnt2 + 1`
	
	if [ $cnt2 -eq $GamesNum ]
	then
		echo ""
		cnt2=0
		cnt1=`expr $cnt1 + 1`
	fi
	
	if [ $cnt1 -eq `expr $WinsNum + 1` ]
	then
		cnt1=0
	fi
done < $LOGNAME
