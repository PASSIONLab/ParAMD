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
  echo "Running distribution experiments for matrix $matrix"
  echo "--Running ParAMD with 64 thread(s)"
  OMP_NUM_THREADS=64 OMP_PLACES=cores ./build/paramd \
    --matrix $SCRATCH_DIR/dataset/$matrix/$matrix.mtx --algo paramd --seed 1 --stat \
    > $SCRATCH_DIR/dataset/$matrix/$matrix.paramd.distribution.s1.t64.log
done

mkdir -p $SCRATCH_DIR/plots
python ./scripts/plot.py $SCRATCH_DIR distribution
popd