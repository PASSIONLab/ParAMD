#!/bin/bash

if [[ $# -eq 0 ]] ; then
  echo 'The path to a clean scratch directory needs to be provided!'
  exit 1
fi

pushd $1
SCRATCH_DIR=$(pwd)
popd

dataset="pre2 nd24k ldoor dielFilterV3real Flan_1565 HV15R Queen_4147 stokes nlpkkt240"
pushd $(dirname "$0")/..
for matrix in $dataset
do
  echo "Running breakdown experiments for matrix $matrix"
  for thread in 1 2 4 8 16 32 64
  do
    echo "--Running ParAMD with $thread thread(s)"
    OMP_NUM_THREADS=$thread OMP_PLACES=cores ./build/paramd \
      --matrix $SCRATCH_DIR/dataset/$matrix/$matrix.mtx --algo paramd --seed 1 --breakdown \
      > $SCRATCH_DIR/dataset/$matrix/$matrix.paramd.breakdown.s1.t$thread.log
  done
done

mkdir -p $SCRATCH_DIR/plots
python ./scripts/plot.py $SCRATCH_DIR breakdown
popd