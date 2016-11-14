#!/bin/sh

TIME="/usr/bin/time"
TIME_FORMAT="%e\t %U\t %S\t %P\t %c\t %w"
LIGHT=10
MEDIUM=100
HEAVY=1000
ITERATIONS=1000000

test()
{
  # Current Directory
  CODE_DIR=$PWD;

  # Create temporary directory for output files
  TMP_DIR=$PWD/TMP_DIR
  if [ ! -d "$TMP_DIR" ]; then
    mkdir "$TMP_DIR"
  fi

  # Create directory for raw data files
  if [ ! -d "$CODE_DIR/results/raw" ]; then
    mkdir -p "$CODE_DIR/results/raw"
  fi

  cd "$TMP_DIR"

  # Make I/O file
  dd bs=4096 count=512 if=/dev/urandom of="TMP_DIR/rwinput"

  echo "Running benchmark . . ."
  echo "=================================================="
  echo ""
  run_cfs "$CODE_DIR"
  run_fcfs "$CODE_DIR"
  run_rr "$CODE_DIR"

  return 0
}

run_cfs()
{
  CODE_DIR="$1"

  # CPU Bound, Light Load
  echo "Benchmarking CFS scheduler using $LIGHT simultaneous processes"
    "$TIME" -ao "$CODE_DIR/results/raw/cfs-cpu-light.dat" -f "$TIME_FORMAT" \
        "$CODE_DIR/schedule" -n $LIGHT_USAGE -s 0 \
        "$CODE_DIR/prime" $PRIMES >/dev/null
}

run_fcfs()
{

}

run_rr()
{

}
