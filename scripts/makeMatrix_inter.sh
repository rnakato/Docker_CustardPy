#!/bin/bash
cmdname=`basename $0`
function usage()
{
    echo "$cmdname [-l] <norm> <odir> <hic> <resolution> <gt>" 1>&2
    echo '   <norm>: normalization type (NONE|VC|VC_SQRT|KR|SCALE)' 1>&2
    echo '   <odir>: output directory (e.g., "JuicerResults/sample1")' 1>&2
    echo '   <hic>: .hic file' 1>&2
    echo '   <resolution>: resolution of the matrix' 1>&2
    echo '   <gt>: genome table' 1>&2
#    echo '   <lim_pzero>: ' 1>&2
#    echo '   Options:' 1>&2
#    echo '     -l: output contact matrix as a list (default: dense matrix)' 1>&2
}

list="no"
while getopts l option; do
    case ${option} in
        l) list="yes" ;;
        *)
            usage
            exit 1
            ;;
    esac
done
shift $((OPTIND - 1))

if [ $# -ne 6 ]; then
  usage
  exit 1
fi

norm=$1
matrixdir=$2
hic=$3
binsize=$4
gt=$5
lim_pzero=$6

pwd=$(cd $(dirname $0) && pwd)
chrlist=$($pwd/getchr_from_genometable.sh $gt)

dir=$matrixdir/Matrix/interchromosomal/$binsize
mkdir -p $dir
for chr1 in $chrlist
do
    if test $chr1 = "chrY" -o $chr1 = "chrM" -o $chr1 = "chrMT"; then continue; fi

    for chr2 in $chrlist
    do
	if test $chr2 = "chrY" -o $chr2 = "chrM" -o $chr2 = "chrMT"; then continue; fi

	  d=$matrixdir/interchromosomal/$binsize/$chr1-$chr2
          mkdir -p $d

	  echo "$chr1-$chr2"
	  for type in observed oe
	  do
	      tempfile=$d/$type.$norm.txt
              juicertools.sh dump $type $norm $hic $chr1 $chr2 BP $binsize $tempfile
#	      if test $list = "no" -o -s $tempfile; then
#		  convert_JuicerDump_to_dense.py $tempfile $d/$type.$norm.matrix.gz $gt $chr $binsize
#		  rm $tempfile
#	      fi
	  done
    #    for type in expected norm
    #    do
    #        juicertools.sh dump $type $norm $hic.hic $chr BP $binsize $dir/$type.$norm.$chr.matrix -d
    #    done
    done
done

#for str in observed #oe
#do
#    merge_JuicerMatrix_to_Genome.py $dir/interchromosomal \
#				    $dir/interchromosomal/$binsize/genome.$str.full.$lim_pzero.pickle \
#				    $binsize $str $lim_pzero $chrnum
 #   merge_JuicerMatrix_to_Genome.py $dir/interchromosomal \
#				    $dir/interchromosomal/$binsize/genome.$str.evenodd.$lim_pzero.pickle \
#				    $binsize $str $lim_pzero $chrnum --evenodd
#done
