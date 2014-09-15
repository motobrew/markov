#!/bin/sh
trap 'exit' 1 2 3 15

# KEY_NUM
#	1:RATIO
#	3:GAMES
KEY_NUM=1

# ORDER 
#	ASC: min to max
#	DESC: max to min
ORDER=ASC

TEST_TIMES=1000000
GAMES_LIST="50 100 150 200 250 300 400 500 750 1000 1500 2000 2500 3000 4000 5000 7500 10000"
RATIO_MIN=60
RATIO_MAX=95
WIN_MIN=5
WIN_MAX=30

WORKDIR=`pwd`
MODNAME=prob2
LOGDIR=${WORKDIR}/log
LOGNAME=${LOGDIR}/prob${TEST_TIMES}_`date +%y%m%d_%H%M%S`_${RATIO_MIN}_${RATIO_MAX}.log
SRCDIR=${WORKDIR}/src
BINDIR=${WORKDIR}/bin
TEMP1=/var/tmp/prob_temp1.$$

rebuild()
{
	cd $SRCDIR
	make clean
	make || exit 1
	cd $WORKDIR
	rm -f ${BINDIR}/${MODNAME}
	cp ${SRCDIR}/${MODNAME} ${BINDIR}/${MODNAME}
}

Main()
{
	rebuild
	case $KEY_NUM in
	1)
		case $ORDER in
		ASC)
			RatioUpMain
		;;
		DESC)
			RatioDownMain
		;;
		esac
	;;
	3)
		case $ORDER in
		ASC)
			GamesUpMain
		;;
		DESC)
			GamesDownMain
		;;
		esac
	;;
	esac
}

ExecCMD()
{
	RATIO=$1; WIN=$2; GAMES=$3
	${BINDIR}/${MODNAME} $RATIO $GAMES $WIN $TEST_TIMES | tee -a ${LOGNAME}
}

GamesList()
{
	for Games in $GAMES_LIST
	do
		echo $Games
	done
}

RatioCheck()
{
	ReturnCode=1

	case $ORDER in
	ASC)
		CHECK_VALUE=100.00
	;;
	DESC)
		CHECK_VALUE=0.00
	;;
	esac

	RatioCheck=`tail -1 $LOGNAME | awk '{ print $5 }'`
	if [ "$RatioCheck" = "$CHECK_VALUE" ]; then
		ReturnCode=0
	fi
	return $ReturnCode
}

GamesUpMain()
{
	GamesList | while read Games
	do
		RatioCnt=$RATIO_MIN
		while [ "$RatioCnt" -le "$RATIO_MAX" ]
		do
			WinCnt=$WIN_MAX
			while [ "$WinCnt" -ge "$WIN_MIN" ]
			do
				ExecCMD $RatioCnt $WinCnt $Games
				RatioCheck && break
				WinCnt=`expr $WinCnt - 1`
			done

			LastWins=`tail -1 $LOGNAME | awk '{ print $2 }'`
			if [ "$LastWins" -eq "$WIN_MAX" ]; then
				break
			fi
			RatioCnt=`expr $RatioCnt + 1`
		done
	done
}

GamesDownMain()
{
	GamesList | sort -rn | while read Games
	do
		RatioCnt=$RATIO_MAX
		while [ "$RatioCnt" -ge "$RATIO_MIN" ]
		do
			WinCnt=$WIN_MIN
			while [ "$WinCnt" -le "$WIN_MAX" ]
			do
				ExecCMD $RatioCnt $WinCnt $Games
				RatioCheck && break
				WinCnt=`expr $WinCnt + 1`
			done

			LastWins=`tail -1 $LOGNAME | awk '{ print $2 }'`
			if [ "$LastWins" -eq "$WIN_MIN" ]; then
				break
			fi
			RatioCnt=`expr $RatioCnt - 1`
		done
	done
}

RatioUpMain()
{
	RatioCnt=$RATIO_MIN

	while [ "$RatioCnt" -le "$RATIO_MAX" ]
	do
		WinCnt=$WIN_MAX
		while [ "$WinCnt" -ge "$WIN_MIN" ]
		do
			GamesList | while read Games
			do
				ExecCMD $RatioCnt $WinCnt $Games
				RatioCheck && break
			done

			LastGames=`tail -1 $LOGNAME | awk '{ print $3 }'`
			GamesMin=`GamesList | head -1`
			if [ "$LastGames" -eq "$GamesMin" ]; then
				break
			fi
			WinCnt=`expr $WinCnt - 1`
		done
		RatioCnt=`expr $RatioCnt + 1`
	done
}

RatioDownMain()
{
	RatioCnt=$RATIO_MAX

	while [ "$RatioCnt" -ge "$RATIO_MIN" ]
	do
		WinCnt=$WIN_MIN
		while [ "$WinCnt" -le "$WIN_MAX" ]
		do
			GamesList | sort -rn | while read Games
			do
				ExecCMD $RatioCnt $WinCnt $Games
				RatioCheck && break
			done
			
			LastGames=`tail -1 $LOGNAME | awk '{ print $3 }'`
			GamesMax=`GamesList | tail -1`
			if [ "$LastGames" -eq "$GamesMax" ]; then
				break
			fi
			WinCnt=`expr $WinCnt + 1`
		done
		RatioCnt=`expr $RatioCnt - 1`
	done
}

Main 

