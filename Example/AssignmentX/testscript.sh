#/!/bin/bash

#File: testscript
#Author: Andy Sayler
#Project: CSCI 3753 Programming Assignment 3
#Create Date: 2012/03/09
#Modify Date: 2012/03/21
#Description:
#	A simple bash script to run a signle copy of each test case
#	and gather the relevent data.

# Altered by Raymond Duncan for PAX alteration date 5/2/16

ITERATIONS=100000000
BYTESTOCOPY=1024000
BLOCKSIZE=1024
NUMPROCS="$1"
TIMEFORMAT="wall=%e user=%U system=%S CPU=%P i-switched=%c v-switched=%w"
FORMAT="%e,%U,%S,%P,%c,%w"
RANDOMIN="/dev/urandom"
DUMPOUT="rwoutput"

MAKE="make -s"

echo Building code...
$MAKE clean
$MAKE

echo Starting test runs...

#Compute Bound
echo Calculating pi over $ITERATIONS iterations using SCHED_OTHER with $NUMPROCS simultaneous processes...
(/usr/bin/time -f "$FORMAT" ./pi-sched $ITERATIONS SCHED_OTHER $NUMPROCS > /dev/null) &>> ComputeBoundOTHER.csv

echo Calculating pi over $ITERATIONS iterations using SCHED_FIFO with $NUMPROCS simultaneous processes...
(/usr/bin/time -f "$FORMAT" sudo ./pi-sched $ITERATIONS SCHED_FIFO $NUMPROCS > /dev/null) &>> ComputeBoundFIFO.csv

echo Calculating pi over $ITERATIONS iterations using SCHED_RR with $NUMPROCS simultaneous processes...
(/usr/bin/time -f "$FORMAT" sudo ./pi-sched $ITERATIONS SCHED_RR $NUMPROCS > /dev/null) &>> ComputeBoundRR.csv

echo
echo
#I/O Bound
echo Copying $BYTESTOCOPY bytes in blocks of $BLOCKSIZE from /dev/urandom to $DUMPOUT
echo using SCHED_OTHER with $NUMPROCS simultaneous processes...
(/usr/bin/time -f "$FORMAT" sudo ./rw $BYTESTOCOPY $BLOCKSIZE $RANDOMIN $DUMPOUT $NUMPROCS > /dev/null) &>> IOBoundOTHER.csv

echo Copying $BYTESTOCOPY bytes in blocks of $BLOCKSIZE from /dev/urandom to $DUMPOUT
echo using SCHED_FIFO with $NUMPROCS simultaneous processes...
(/usr/bin/time -f "$FORMAT" sudo ./rw $BYTESTOCOPY $BLOCKSIZE $RANDOMIN $DUMPOUT $NUMPROCS $SCHED_FIFO > /dev/null) &>> IOBoundFIFO.csv

echo Copying $BYTESTOCOPY bytes in blocks of $BLOCKSIZE from /dev/urandom to $DUMPOUT
echo using SCHED_RR with $NUMPROCS simultaneous processes...
(/usr/bin/time -f "$FORMAT" sudo ./rw $BYTESTOCOPY $BLOCKSIZE $RANDOMIN $DUMPOUT $NUMPROCS $SCHED_RR > /dev/null) &>> IOBoundRR.csv

echo
echo
#Mixed
echo Calculating pi over $(( $ITERATIONS/10 )) iterations using SCHED_OTHER with $NUMPROCS simultaneous processes...
(/usr/bin/time -f "$FORMAT" sudo ./pi-sched-mixed $(( $ITERATIONS / 10 )) SCHED_OTHER $NUMPROCS > /dev/null) &>> MixedOTHER.csv

echo Calculating pi over $(( $ITERATIONS/10 )) iterations using SCHED_FIFO with $NUMPROCS simultaneous processes...
(/usr/bin/time -f "$FORMAT" sudo ./pi-sched-mixed $(( $ITERATIONS / 10 )) SCHED_FIFO $NUMPROCS > /dev/null) &>> MixedFIFO.csv

echo Calculating pi over $(( $ITERATIONS/10 )) iterations using SCHED_RR with $NUMPROCS simultaneous processes...
(/usr/bin/time -f "$FORMAT" sudo ./pi-sched-mixed $(( $ITERATIONS / 10 )) SCHED_RR $NUMPROCS > /dev/null) &>> MixedRR.csv
