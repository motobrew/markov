#!/bin/sh
trap 'exit' 1 2 3 15

# KEY_NUM
#	1:RATIO
#	2:WINS
#	3:GAMES
KEY_NUM=3

TEMP1=/var/tmp/org_edit_log_temp1.$$
TEMP2=/var/tmp/org_edit_log_temp2.$$
ECHO=/bin/echo

Usage()
{
	echo "`basename $0` <log file>" 1>&2
}

Main()
{
	KeyList $LOGNAME | while read KEY
	do
		export KEY
		CreateTemp
		case $KEY_NUM in
		1)
			ShowRatioTable
		;;
		2)
			ShowWinsTable
		;;
		3)
			ShowGamesTable
		;;
		esac
		rm $TEMP1
	done
}

KeyList()
{
	case $KEY_NUM in
	1)
		cat $LOGNAME | awk '{ print $1 }' | sort -un
	;;
	2)
		cat $LOGNAME | awk '{ print $2 }' | sort -un
	;;
	3)
		cat $LOGNAME | awk '{ print $3 }' | sort -un
	;;
	esac
}

RatioList()
{
	cat $TEMP1 | awk '{ print $1 }' | sort -un
}

WinsList()
{
	cat $TEMP1 | awk '{ print $2 }' | sort -un
}

GamesList()
{
	cat $TEMP1 | awk '{ print $3 }' | sort -un
}

CreateTemp()
{
	cat /dev/null > $TEMP1
	cat $LOGNAME | while read p1 p2 p3 p4 p5
	do
		case $KEY_NUM in
		1)
			Target=$p1
		;;
		2)
			Target=$p2
		;;
		3)
			Target=$p3
		;;
		esac

		if [ "$KEY" = "$Target" ]; then
			echo "$p1 $p2 $p3 $p4 $p5" >> $TEMP1
		fi
	done
}

ShowRatioTable()
{
	$ECHO "勝率:${KEY}%"
	$ECHO -n "ゲーム数 "
	GamesList | tr '\n' ' '
	echo

	WinsList | while read CheckWins
	do
		$ECHO -n "${CheckWins}連勝 "

		GamesList | while read CheckGames
		do
			ShowProb $CheckWins $CheckGames
		done
		echo
	done
	echo
}

ShowWinsTable()
{
	$ECHO "${KEY}連勝"
	$ECHO -n "ゲーム数 "
	GamesList | tr '\n' ' '
	echo

	RatioList | while read CheckRatio
	do
		$ECHO -n "${CheckRatio}% "

		GamesList | while read CheckGames
		do
			ShowProb $CheckRatio $CheckGames
		done
		echo
	done
	echo
}

ShowGamesTable()
{
	$ECHO "ゲーム数:$KEY"
	$ECHO -n "連勝数 "
	WinsList | tr '\n' ' '
	echo

	RatioList | while read CheckRatio
	do
		$ECHO -n "${CheckRatio}% "

		WinsList | while read CheckWins
		do
			ShowProb $CheckRatio $CheckWins
		done
		echo
	done
	echo
}


ShowProb()
{
	Check1=$1
	Check2=$2

	test -f $TEMP2 && rm $TEMP2

	cat $TEMP1 | while read p1 p2 p3 p4 p5
	do
		case $KEY_NUM in
		1)
			Target1=$p2	# Wins
			Target2=$p3	# Games
		;;
		2)
			Target1=$p1	# Ratio
			Target2=$p3	# Games
		;;
		3)
			Target1=$p1	# Ratio
			Target2=$p2	# Wins
		;;
		esac

		if [ "$Check1" = "$Target1" -a "$Check2" = "$Target2" ]; then
			$ECHO -n "${p5}% " | tee $TEMP2
			break
		fi
	done

	if [ ! -f "$TEMP2" ]; then
		$ECHO -n "- "
		return
	fi
	rm $TEMP2
}

if [ $# -ne 1 ]; then
	Usage
	exit 1
fi
LOGNAME=$1
Main

