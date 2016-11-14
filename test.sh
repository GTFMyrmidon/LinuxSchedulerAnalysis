#!/bin/sh

TIME="/usr/bin/time"
TIME_FORMAT="%e\t %U\t %S\t %P\t %c\t %w"
LIGHT=10
MEDIUM=100
HEAVY=1000
ITERATIONS=1000000

BYTESTOCOPY=102400
BLOCKSIZE=1024

test()
{
  # Current Directory
  CODE_DIR=$PWD;

  # Array of Loads
  loads={$LIGHT $MEDIUM $HEAVY}

  # Create temporary directory for output files
  TMP_DIR=$CODE_DIR/TMP_DIR
  if [ ! -d "$TMP_DIR" ]; then
    mkdir "$TMP_DIR"
  fi

  # Create directory for raw data files
  if [ ! -d "$CODE_DIR/results/raw" ]; then
    mkdir -p "$CODE_DIR/results/raw"
  fi

  # cd "$TMP_DIR"

  echo "Running benchmark . . ."
  echo "=================================================="
  echo ""
  run_cfs "$CODE_DIR"

  return 0
}

run_cfs()
{
  CODE_DIR="$1"

  # CPU Bound, Light Load
  echo Benchmarking CFS scheduler using $LIGHT simultaneous processes
  for i in 1 2 3
  do
      "$TIME" -ao "results/raw/cfs-cpu-light.dat" -f "$TIME_FORMAT" \
      sudo ./pi-sched $ITERATIONS SCHED_OTHER $LIGHT_USAGE 1 > /dev/null
      echo "Run $i complete"
  done

  awk 'BEGIN {FS = "\t"} { sum1 += $1; sum2 += $2; sum3 += $3; sum4 += $4; sum5 += $5; sum6 += $6; } END {print sum1/3, sum2/3 sum3/3, sum4/3}'

  echo Complete!

  return 0
}

test
