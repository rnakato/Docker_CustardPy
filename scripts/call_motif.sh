#!/bin/bash
cmdname=`basename $0`
function usage()
{
    echo "$cmdname <norm> <outputdir> <build> <motifdir>" 1>&2
}

if [ $# -ne 4 ]; then
  usage
  exit 1
fi

norm=$1
odir=$2
build=$3
motifdir=$4

ex(){ echo $1; eval $1; }

pwd=$(cd $(dirname $0) && pwd)
juicertool="juicertools.sh"

# motif
loopfile=$odir/loops/$norm/merged_loops.bedpe
ex "$juicertool motifs $build $motifdir $loopfile"
