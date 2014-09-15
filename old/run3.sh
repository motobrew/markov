#!/bin/sh

WORKDIR=`pwd`
SRCDIR=${WORKDIR}/src
BINDIR=${WORKDIR}/bin
LOGDIR=${WORKDIR}/log
LOGNAME=${LOGDIR}/`date +%y%m%d_%H%M%S`.log
MODNAME=prob3

cd $SRCDIR
make || exit 1

cd $WORKDIR
rm -f ${BINDIR}/${MODNAME}
cp ${SRCDIR}/${MODNAME} ${BINDIR}/${MODNAME}


WIN_R=55
PAY_R=180
STOP_R=5
START_MONEY=500000
GAMES=100
TEST_TIMES=50

${BINDIR}/${MODNAME} $WIN_R $PAY_R $STOP_R $START_MONEY $GAMES $TEST_TIMES 2>&1 | tee -a ${LOGNAME}
