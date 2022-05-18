#!/bin/bash
cmdname=`basename $0`
function usage()
{
    echo "$cmdname <norm> <odir> <hic file> <resolution> <genometable>" 1>&2
}

if [ $# -ne 5 ]; then
  usage
  exit 1
fi

norm=$1
matrixdir=$2
hic=$3
binsize=$4
gt=$5

pwd=$(cd $(dirname $0) && pwd)
chrlist=$($pwd/getchr_from_genometable.sh $gt)

dir=$matrixdir/Matrix/intrachromosomal/$binsize
mkdir -p $dir
for chr in $chrlist
do
    if test $chr = "chrY" -o $chr = "chrM" -o $chr = "chrMT" ;then continue; fi

    echo "$chr"
    for type in observed oe
    do
	tempfile=$dir/$type.$norm.$chr.txt
        juicertools.sh dump $type $norm $hic $chr $chr BP $binsize $tempfile
	if test -s $tempfile; then
            convert_JuicerDump_to_dense.py $tempfile $dir/$type.$norm.$chr.matrix.gz $gt $chr $binsize
	fi
	rm $tempfile
    done
    #    for type in expected norm
    #    do
    #        juicertools.sh dump $type $norm $hic.hic $chr BP $binsize $dir/$type.$norm.$chr.matrix -d
    #    done
done
