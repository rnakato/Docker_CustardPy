#!/bin/bash
cmdname=`basename $0`
function usage()
{
    echo "$cmdname <norm> <outputdir> <hic file> <build>" 1>&2
}

if [ $# -ne 4 ]; then
  usage
  exit 1
fi

norm=$1
odir=$2
hic=$3

ex(){ echo $1; eval $1; }

pwd=$(cd $(dirname $0) && pwd)
juicertool="juicertools.sh"

hicdir=$odir/loops/$norm
mkdir -p $hicdir
ex "$juicertool hiccups -r 5000,10000,25000 -k $norm $hic $hicdir"
grep -v \# $hicdir/merged_loops.bedpe | awk '{OFS="\t"} {printf "chr%s\t%d\t%d\tchr%s\t%d\t%d\n", $1, $2, $3, $4, $5, $6 }' > $hicdir/merged_loops.simple.bedpe
