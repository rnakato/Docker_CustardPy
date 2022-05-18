#!/bin/bash

norm=$1
odir=$2
gt=$3

for res in 100000 50000 25000
do
    makeInslationScore.sh $norm $odir $res $gt
done
