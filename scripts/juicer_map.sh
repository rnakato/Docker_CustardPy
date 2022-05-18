#!/bin/bash -e
cmdname=`basename $0`
function usage()
{
    echo "$cmdname [-d Datadir] [-m tmpdir] [-p ncore] <odir> <build> <fastqdir> <enzyme> <fastq_post [_|_R]>" 1>&2
    echo '   Example: $cmdname $(pwd)/JuicerResults/Hap1-A hg38 $(pwd)/fastq/Hap1-A/ MboI _R' 1>&2
}

tmpdir=""
ncore=32
Datadir=/work/Database
while getopts d:p:m: option; do
    case ${option} in
        d) Datadir=${OPTARG} ;;
        p) ncore=${OPTARG} ;;
        m) tmpdir=${OPTARG} ;;
        *)
	    usage
            exit 1
            ;;
    esac
done
shift $((OPTIND - 1))

if [ $# -ne 5 ]; then
  usage
  exit 1
fi

odir=$1
label=$(basename $odir)
build=$2
fqdir=$3
enzyme=$4
fastq_post=$5

jdir=/opt/juicer
gt=$Datadir/UCSC/$build/genome_table
bwaindex=$Datadir/bwa-indexes/UCSC-$build

if [ -n "$tmpdir" ]; then
  param="-p $tmpdir"
fi

ex(){ echo $1; eval $1; }

pwd=`pwd`
ex "mkdir -p $odir"
ex "if test ! -e $odir/fastq; then ln -s $fqdir $odir/fastq; fi"
ex "bash $jdir/CPU/juicer.sh -t $ncore -g $build -d $odir $param \
     -s $enzyme -a $label -p $gt \
     -z $bwaindex -D $jdir -e $fastq_post -S map"
