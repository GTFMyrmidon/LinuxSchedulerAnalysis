#!/bin/bash

TIME="/usr/bin/time"
TIME_FORMAT="%e,%U,%S,%P,%c,%w"
LIGHT=10
MEDIUM=75
HEAVY=300
ITERATIONS=1000000

BYTESTOCOPY=102400
BLOCKSIZE=1024

test()
{
  # Current Directory
  CODE_DIR=$PWD;

  # Array of Loads
  loads=($LIGHT $MEDIUM $HEAVY)

  # Create temporary directory for output files
  TMP_DIR=$CODE_DIR/TMP_DIR
  if [ ! -d "$TMP_DIR" ]; then
    mkdir "$TMP_DIR"
  fi

  # Create directory for raw data files
  if [ ! -d "$CODE_DIR/results/raw" ]; then
    mkdir -p "$CODE_DIR/results/raw"
  fi

  echo "================================================================"
  echo "Running benchmark . . ."
  echo "================================================================"
  echo ""
  run_cfs "$CODE_DIR"
  run_fcfs "$CODE_DIR"
  run_rr "$CODE_DIR"

  echo All tests complete!

  return 0
}

run_cfs()
{
  CODE_DIR="$1"
  WORK="work.csv"

  # CPU-bound, same nice values
  OUTFILE="results/raw/cfs-cpu-same.csv"
  for LOAD in "${loads[@]}"
  do
    echo CFS scheduler, CPU-bound, $LOAD simultaneous processes, same nice values
    for i in 1 2 3
    do
      "$TIME" -ao $WORK -f "$TIME_FORMAT" \
      sudo ./pi-sched $ITERATIONS SCHED_OTHER $LOAD 1 > /dev/null
      echo "Run $i complete"
    done

    sed -i 's/%//' $WORK
    awk 'BEGIN {FS = ","; OFS = ","} { sum1 += $1; sum2 += $2; sum3 += $3; sum4 += $4; sum5 += $5; sum6 += $6; } END {print sum1/3, sum2/3, sum3/3, sum4/3, sum5/3, sum6/3}' $WORK >> $WORK
    cat $WORK >> $OUTFILE
    cat /dev/null > $WORK
    echo "" >> $OUTFILE
  done

  echo ""

  # I/O-bound, same nice values
  OUTFILE="results/raw/cfs-io-same.csv"
  for LOAD in "${loads[@]}"
  do
    echo CFS scheduler, I/O-bound, $LOAD simultaneous processes, same nice values
    for i in 1 2 3
    do
      "$TIME" -ao $WORK -f "$TIME_FORMAT" \
      sudo ./rw $BYTESTOCOPY $BLOCKSIZE /dev/urandom TMP_DIR/rwoutput SCHED_OTHER 1 > /dev/null
      echo "Run $i complete"
    done

    sed -i 's/%//' $WORK
    awk 'BEGIN {FS = ","; OFS = ","} { sum1 += $1; sum2 += $2; sum3 += $3; sum4 += $4; sum5 += $5; sum6 += $6; } END {print sum1/3, sum2/3, sum3/3, sum4/3, sum5/3, sum6/3}' $WORK >> $WORK
    cat $WORK >> $OUTFILE
    cat /dev/null > $WORK
    echo "" >> $OUTFILE
  done

  echo ""

  # Mixed, same nice values
  OUTFILE="results/raw/cfs-mixed-same.csv"
  for LOAD in "${loads[@]}"
  do
    echo CFS scheduler, mixed, $LOAD simultaneous processes, same nice values
    for i in 1 2 3
    do
      "$TIME" -ao $WORK -f "$TIME_FORMAT" \
      sudo ./mixed $ITERATIONS SCHED_OTHER $LOAD 1 > /dev/null
      echo "Run $i complete"
    done

    sed -i 's/%//' $WORK
    awk 'BEGIN {FS = ","; OFS = ","} { sum1 += $1; sum2 += $2; sum3 += $3; sum4 += $4; sum5 += $5; sum6 += $6; } END {print sum1/3, sum2/3, sum3/3, sum4/3, sum5/3, sum6/3}' $WORK >> $WORK
    cat $WORK >> $OUTFILE
    cat /dev/null > $WORK
    echo "" >> $OUTFILE
  done

  # CPU-bound, different nice values
  OUTFILE="results/raw/cfs-cpu-diff.csv"
  for LOAD in "${loads[@]}"
  do
    echo CFS scheduler, CPU-bound, $LOAD simultaneous processes, different nice values
    for i in 1 2 3
    do
      "$TIME" -ao $WORK -f "$TIME_FORMAT" \
      sudo ./pi-sched $ITERATIONS SCHED_OTHER $LOAD 0 > /dev/null
      echo "Run $i complete"
    done

    sed -i 's/%//' $WORK
    awk 'BEGIN {FS = ","; OFS = ","} { sum1 += $1; sum2 += $2; sum3 += $3; sum4 += $4; sum5 += $5; sum6 += $6; } END {print sum1/3, sum2/3, sum3/3, sum4/3, sum5/3, sum6/3}' $WORK >> $WORK
    cat $WORK >> $OUTFILE
    cat /dev/null > $WORK
    echo "" >> $OUTFILE
  done

  echo ""

  # I/O-bound, different nice values
  OUTFILE="results/raw/cfs-io-diff.csv"
  for LOAD in "${loads[@]}"
  do
    echo CFS scheduler, I/O-bound, $LOAD simultaneous processes, different nice values
    for i in 1 2 3
    do
      "$TIME" -ao $WORK -f "$TIME_FORMAT" \
      sudo ./rw $BYTESTOCOPY $BLOCKSIZE /dev/urandom TMP_DIR/rwoutput SCHED_OTHER 0 > /dev/null
      echo "Run $i complete"
    done

    sed -i 's/%//' $WORK
    awk 'BEGIN {FS = ","; OFS = ","} { sum1 += $1; sum2 += $2; sum3 += $3; sum4 += $4; sum5 += $5; sum6 += $6; } END {print sum1/3, sum2/3, sum3/3, sum4/3, sum5/3, sum6/3}' $WORK >> $WORK
    cat $WORK >> $OUTFILE
    cat /dev/null > $WORK
    echo "" >> $OUTFILE
  done

  echo ""

  # Mixed, different nice values
  OUTFILE="results/raw/cfs-mixed-diff.csv"
  for LOAD in "${loads[@]}"
  do
    echo CFS scheduler, mixed, $LOAD simultaneous processes, different nice values
    for i in 1 2 3
    do
      "$TIME" -ao $WORK -f "$TIME_FORMAT" \
      sudo ./mixed $ITERATIONS SCHED_OTHER $LOAD 0 > /dev/null
      echo "Run $i complete"
    done

    sed -i 's/%//' $WORK
    awk 'BEGIN {FS = ","; OFS = ","} { sum1 += $1; sum2 += $2; sum3 += $3; sum4 += $4; sum5 += $5; sum6 += $6; } END {print sum1/3, sum2/3, sum3/3, sum4/3, sum5/3, sum6/3}' $WORK >> $WORK
    cat $WORK >> $OUTFILE
    cat /dev/null > $WORK
    echo "" >> $OUTFILE
  done

  echo "CFS tests complete!"
  echo ""

  return 0
}

run_fcfs()
{
  CODE_DIR="$1"
  WORK="work.csv"

  # CPU-bound, same priorities
  OUTFILE="results/raw/fcfs-cpu-same.csv"
  for LOAD in "${loads[@]}"
  do
    echo FCFS scheduler, CPU-bound, $LOAD simultaneous processes, same priorities
    for i in 1 2 3
    do
      "$TIME" -ao $WORK -f "$TIME_FORMAT" \
      sudo ./pi-sched $ITERATIONS SCHED_FIFO $LOAD 1 > /dev/null
      echo "Run $i complete"
    done

    sed -i 's/%//' $WORK
    awk 'BEGIN {FS = ","; OFS = ","} { sum1 += $1; sum2 += $2; sum3 += $3; sum4 += $4; sum5 += $5; sum6 += $6; } END {print sum1/3, sum2/3, sum3/3, sum4/3, sum5/3, sum6/3}' $WORK >> $WORK
    cat $WORK >> $OUTFILE
    cat /dev/null > $WORK
    echo "" >> $OUTFILE
  done

  echo ""

  # I/O-bound, same priorities
  OUTFILE="results/raw/fcfs-io-same.csv"
  for LOAD in "${loads[@]}"
  do
    echo FCFS scheduler, I/O-bound, $LOAD simultaneous processes, same priorities
    for i in 1 2 3
    do
      "$TIME" -ao $WORK -f "$TIME_FORMAT" \
      sudo ./rw $BYTESTOCOPY $BLOCKSIZE /dev/urandom TMP_DIR/rwoutput SCHED_FIFO 1 > /dev/null
      echo "Run $i complete"
    done

    sed -i 's/%//' $WORK
    awk 'BEGIN {FS = ","; OFS = ","} { sum1 += $1; sum2 += $2; sum3 += $3; sum4 += $4; sum5 += $5; sum6 += $6; } END {print sum1/3, sum2/3, sum3/3, sum4/3, sum5/3, sum6/3}' $WORK >> $WORK
    cat $WORK >> $OUTFILE
    cat /dev/null > $WORK
    echo "" >> $OUTFILE
  done

  echo ""

  # Mixed, same priorities
  OUTFILE="results/raw/fcfs-mixed-same.csv"
  for LOAD in "${loads[@]}"
  do
    echo FCFS scheduler, mixed, $LOAD simultaneous processes, same priorities
    for i in 1 2 3
    do
      "$TIME" -ao $WORK -f "$TIME_FORMAT" \
      sudo ./mixed $ITERATIONS SCHED_FIFO $LOAD 1 > /dev/null
      echo "Run $i complete"
    done

    sed -i 's/%//' $WORK
    awk 'BEGIN {FS = ","; OFS = ","} { sum1 += $1; sum2 += $2; sum3 += $3; sum4 += $4; sum5 += $5; sum6 += $6; } END {print sum1/3, sum2/3, sum3/3, sum4/3, sum5/3, sum6/3}' $WORK >> $WORK
    cat $WORK >> $OUTFILE
    cat /dev/null > $WORK
    echo "" >> $OUTFILE
  done

  echo ""

  # CPU-bound, different priorities
  OUTFILE="results/raw/fcfs-cpu-diff.csv"
  for LOAD in "${loads[@]}"
  do
    echo FCFS scheduler, CPU-bound, $LOAD simultaneous processes, different priorities
    for i in 1 2 3
    do
      "$TIME" -ao $WORK -f "$TIME_FORMAT" \
      sudo ./pi-sched $ITERATIONS SCHED_FIFO $LOAD 0 > /dev/null
      echo "Run $i complete"
    done

    sed -i 's/%//' $WORK
    awk 'BEGIN {FS = ","; OFS = ","} { sum1 += $1; sum2 += $2; sum3 += $3; sum4 += $4; sum5 += $5; sum6 += $6; } END {print sum1/3, sum2/3, sum3/3, sum4/3, sum5/3, sum6/3}' $WORK >> $WORK
    cat $WORK >> $OUTFILE
    cat /dev/null > $WORK
    echo "" >> $OUTFILE
  done

  echo ""

  # I/O-bound, different priorities
  OUTFILE="results/raw/fcfs-io-diff.csv"
  for LOAD in "${loads[@]}"
  do
    echo FCFS scheduler, I/O-bound, $LOAD simultaneous processes, different priorities
    for i in 1 2 3
    do
      "$TIME" -ao $WORK -f "$TIME_FORMAT" \
      sudo ./rw $BYTESTOCOPY $BLOCKSIZE /dev/urandom TMP_DIR/rwoutput SCHED_FIFO 0 > /dev/null
      echo "Run $i complete"
    done

    sed -i 's/%//' $WORK
    awk 'BEGIN {FS = ","; OFS = ","} { sum1 += $1; sum2 += $2; sum3 += $3; sum4 += $4; sum5 += $5; sum6 += $6; } END {print sum1/3, sum2/3, sum3/3, sum4/3, sum5/3, sum6/3}' $WORK >> $WORK
    cat $WORK >> $OUTFILE
    cat /dev/null > $WORK
    echo "" >> $OUTFILE
  done

  echo ""

  # Mixed, different priorities
  OUTFILE="results/raw/fcfs-mixed-diff.csv"
  for LOAD in "${loads[@]}"
  do
    echo FCFS scheduler, mixed, $LOAD simultaneous processes, different priorities
    for i in 1 2 3
    do
      "$TIME" -ao $WORK -f "$TIME_FORMAT" \
      sudo ./mixed $ITERATIONS SCHED_FIFO $LOAD 0 > /dev/null
      echo "Run $i complete"
    done

    sed -i 's/%//' $WORK
    awk 'BEGIN {FS = ","; OFS = ","} { sum1 += $1; sum2 += $2; sum3 += $3; sum4 += $4; sum5 += $5; sum6 += $6; } END {print sum1/3, sum2/3, sum3/3, sum4/3, sum5/3, sum6/3}' $WORK >> $WORK
    cat $WORK >> $OUTFILE
    cat /dev/null > $WORK
    echo "" >> $OUTFILE
  done

  echo "FCFS tests complete!"
  echo ""

  return 0
}

run_rr()
{
  CODE_DIR="$1"
  WORK="work.csv"

  # CPU-bound, same priorities
  OUTFILE="results/raw/rr-cpu-same.csv"
  for LOAD in "${loads[@]}"
  do
    echo RR scheduler, CPU-bound, $LOAD simultaneous processes, same priorities
    for i in 1 2 3
    do
      "$TIME" -ao $WORK -f "$TIME_FORMAT" \
      sudo ./pi-sched $ITERATIONS SCHED_RR $LOAD 1 > /dev/null
      echo "Run $i complete"
    done

    sed -i 's/%//' $WORK
    awk 'BEGIN {FS = ","; OFS = ","} { sum1 += $1; sum2 += $2; sum3 += $3; sum4 += $4; sum5 += $5; sum6 += $6; } END {print sum1/3, sum2/3, sum3/3, sum4/3, sum5/3, sum6/3}' $WORK >> $WORK
    cat $WORK >> $OUTFILE
    cat /dev/null > $WORK
    echo "" >> $OUTFILE
  done

  echo ""

  # I/O-bound, same priorities
  OUTFILE="results/raw/rr-io-same.csv"
  for LOAD in "${loads[@]}"
  do
    echo RR scheduler, I/O-bound, $LOAD simultaneous processes, same priorities
    for i in 1 2 3
    do
      "$TIME" -ao $WORK -f "$TIME_FORMAT" \
      sudo ./rw $BYTESTOCOPY $BLOCKSIZE /dev/urandom TMP_DIR/rwoutput SCHED_RR 1 > /dev/null
      echo "Run $i complete"
    done

    sed -i 's/%//' $WORK
    awk 'BEGIN {FS = ","; OFS = ","} { sum1 += $1; sum2 += $2; sum3 += $3; sum4 += $4; sum5 += $5; sum6 += $6; } END {print sum1/3, sum2/3, sum3/3, sum4/3, sum5/3, sum6/3}' $WORK >> $WORK
    cat $WORK >> $OUTFILE
    cat /dev/null > $WORK
    echo "" >> $OUTFILE
  done

  echo ""

  # Mixed, same priorities
  OUTFILE="results/raw/rr-mixed-same.csv"
  for LOAD in "${loads[@]}"
  do
    echo RR scheduler, mixed, $LOAD simultaneous processes, same priorities
    for i in 1 2 3
    do
      "$TIME" -ao $WORK -f "$TIME_FORMAT" \
      sudo ./mixed $ITERATIONS SCHED_RR $LOAD 1 > /dev/null
      echo "Run $i complete"
    done

    sed -i 's/%//' $WORK
    awk 'BEGIN {FS = ","; OFS = ","} { sum1 += $1; sum2 += $2; sum3 += $3; sum4 += $4; sum5 += $5; sum6 += $6; } END {print sum1/3, sum2/3, sum3/3, sum4/3, sum5/3, sum6/3}' $WORK >> $WORK
    cat $WORK >> $OUTFILE
    cat /dev/null > $WORK
    echo "" >> $OUTFILE
  done

  echo ""

  # CPU-bound, different priorities
  OUTFILE="results/raw/rr-cpu-diff.csv"
  for LOAD in "${loads[@]}"
  do
    echo RR scheduler, CPU-bound, $LOAD simultaneous processes, different priorities
    for i in 1 2 3
    do
      "$TIME" -ao $WORK -f "$TIME_FORMAT" \
      sudo ./pi-sched $ITERATIONS SCHED_RR $LOAD 0 > /dev/null
      echo "Run $i complete"
    done

    sed -i 's/%//' $WORK
    awk 'BEGIN {FS = ","; OFS = ","} { sum1 += $1; sum2 += $2; sum3 += $3; sum4 += $4; sum5 += $5; sum6 += $6; } END {print sum1/3, sum2/3, sum3/3, sum4/3, sum5/3, sum6/3}' $WORK >> $WORK
    cat $WORK >> $OUTFILE
    cat /dev/null > $WORK
    echo "" >> $OUTFILE
  done

  echo ""

  # I/O-bound, different priorities
  OUTFILE="results/raw/rr-io-diff.csv"
  for LOAD in "${loads[@]}"
  do
    echo RR scheduler, I/O-bound, $LOAD simultaneous processes, different priorities
    for i in 1 2 3
    do
      "$TIME" -ao $WORK -f "$TIME_FORMAT" \
      sudo ./rw $BYTESTOCOPY $BLOCKSIZE /dev/urandom TMP_DIR/rwoutput SCHED_RR 0 > /dev/null
      echo "Run $i complete"
    done

    sed -i 's/%//' $WORK
    awk 'BEGIN {FS = ","; OFS = ","} { sum1 += $1; sum2 += $2; sum3 += $3; sum4 += $4; sum5 += $5; sum6 += $6; } END {print sum1/3, sum2/3, sum3/3, sum4/3, sum5/3, sum6/3}' $WORK >> $WORK
    cat $WORK >> $OUTFILE
    cat /dev/null > $WORK
    echo "" >> $OUTFILE
  done

  echo ""

  # Mixed, diferent priorities
  OUTFILE="results/raw/rr-mixed-diff.csv"
  for LOAD in "${loads[@]}"
  do
    echo RR scheduler, mixed, $LOAD simultaneous processes, different priorities
    for i in 1 2 3
    do
      "$TIME" -ao $WORK -f "$TIME_FORMAT" \
      sudo ./mixed $ITERATIONS SCHED_RR $LOAD 0 > /dev/null
      echo "Run $i complete"
    done

    sed -i 's/%//' $WORK
    awk 'BEGIN {FS = ","; OFS = ","} { sum1 += $1; sum2 += $2; sum3 += $3; sum4 += $4; sum5 += $5; sum6 += $6; } END {print sum1/3, sum2/3, sum3/3, sum4/3, sum5/3, sum6/3}' $WORK >> $WORK
    cat $WORK >> $OUTFILE
    cat /dev/null > $WORK
    echo "" >> $OUTFILE
  done

  echo "RR tests complete!"
  echo ""

  return 0
}

test
