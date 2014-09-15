#!/bin/sh

WORKDIR=`pwd`
SRCDIR=${WORKDIR}/src
BINDIR=${WORKDIR}/bin
LOGDIR=${WORKDIR}/log
LOGNAME=${LOGDIR}/`date +%y%m%d_%H%M%S`.log
MODNAME=prob2

cd $SRCDIR
make || exit 1
cd $WORKDIR
rm -f ${BINDIR}/${MODNAME}
cp ${SRCDIR}/${MODNAME} ${BINDIR}/${MODNAME}

for RATIO in 55 50
do
for WIN in 13 14 15
do
        for GAMES in 100 250 500 750 1000 1500 2000 3000
        do
                ${BINDIR}/${MODNAME} $RATIO $GAMES $WIN 1000000 2>&1 | tee -a ${LOGNAME}
        done
done
done
