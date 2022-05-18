#!/bin/bash -e
cmdname=`basename $0`
function usage()
{
    echo "$cmdname  [-d Datadir] [-p ncore] <odir> <build> <enzyme> <fastq_post [_|_R]>" 1>&2
}

if [ $# -ne 4 ]; then
  usage
  exit 1
fi

ncore=32
Datadir=/work/Database
while getopts d: option
do
    case ${option} in
        d)
            Datadir=${OPTARG}
            ;;
        p)
            ncore==${OPTARG}
            ;;
        *)
            usage
            exit 1
            ;;
    esac
done
shift $((OPTIND - 1))

if [ $# -ne 4 ]; then
  usage
  exit 1
fi

odir=$1
label=$(basename $odir)
build=$2
enzyme=$3
fastq_post=$4

jdir=/opt/juicer
gt=$Datadir/UCSC/$build/genome_table
bwaindex=$Datadir/bwa-indexes/UCSC-$build

bash $jdir/CPU/juicer.sh -t $ncore -g $build -d $odir \
     -s $enzyme -a $label -p $gt \
     -z $bwaindex -D $jdir -e $fastq_post -S map

bash $jdir/CPU/juicer.sh -t $ncore -g $build -d $odir \
     -s $enzyme -a $label -p $gt \
     -z $bwaindex -D $jdir -e $fastq_post -S aftermap
