#!/bin/bash

if [[ $# -eq 0 ]] ; then
  echo 'The path to a clean scratch directory needs to be provided!'
  exit 1
fi

pushd $1
SCRATCH_DIR=$(pwd)
popd

dataset="nd24k nlpkkt240"
pushd $(dirname "$0")/..
for matrix in $dataset
do
  echo "Running tuning experiments for matrix $matrix"
  echo "--Running ParAMD with 64 thread(s)"
  for mult in 1.0 1.2 1.4 1.6 1.8 2.0
  do
    for lim in 512 2048 8192 32768 131072
    do
      echo "----Running ParAMD with mult = $mult and lim = $lim"
      OMP_NUM_THREADS=64 OMP_PLACES=cores ./build/paramd --breakdown \
        --matrix $SCRATCH_DIR/dataset/$matrix/$matrix.mtx --algo paramd --seed 1 --mult $mult --lim $lim \
        > $SCRATCH_DIR/dataset/$matrix/$matrix.paramd.tuning.s1.t64.m$mult.l$lim.log
    done
  done
done

mkdir -p $SCRATCH_DIR/plots
python ./scripts/plot.py $SCRATCH_DIR tuning
popd