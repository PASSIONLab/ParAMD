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
for seed in 1 2 3 4 5
do
  echo "Running scaling experiments for seed $seed"
  for matrix in $dataset
  do
    echo "--Running scaling experiments for matrix $matrix"
    for thread in 1 64
    do
      echo "----Running ParAMD with $thread thread(s)"
      OMP_NUM_THREADS=$thread OMP_PLACES=cores ./build/paramd \
        --matrix $SCRATCH_DIR/dataset/$matrix/$matrix.mtx --algo paramd --seed $seed \
        > $SCRATCH_DIR/dataset/$matrix/$matrix.paramd.scaling.s$seed.t$thread.log
    done
    echo "----Running AMD"
    OMP_NUM_THREADS=64 OMP_PLACES=cores ./build/paramd \
        --matrix $SCRATCH_DIR/dataset/$matrix/$matrix.mtx --algo amd --seed $seed \
        > $SCRATCH_DIR/dataset/$matrix/$matrix.amd.scaling.s$seed.log
  done
done

mkdir -p $SCRATCH_DIR/plots
python ./scripts/plot.py $SCRATCH_DIR scaling
popd