#!/bin/bash -e
cmdname=`basename $0`
function usage()
{
    echo "$cmdname <norm> <hic> <odir> <gt>" 1>&2
}

if [ $# -ne 4 ]; then
  usage
  exit 1
fi

norm=$1
hic=$2
odir=$3
gt=$4

dir=$odir/TAD/$norm
mkdir -p $dir

for res in 10000 25000 50000; do
    if test ! -e $dir/${res}_blocks.bedpe; then
        juicertools.sh arrowhead -m 2000 -r $res --threads 24 -k $norm $hic $dir # --ignore_sparsity
    fi

    # make TAD bed
    grep -v \# $dir/${res}_blocks.bedpe | awk '{OFS="\t"} NR>1 {printf "chr%s\t%d\t%d\tTAD%d\n", $1, $2, $3, NR }' > $dir/${res}_blocks.bed
    sort -k1,1 -k2,2n $dir/${res}_blocks.bed | bedtools merge > $dir/${res}_blocks.merged.bed

    # bedpe to boundary bed
    grep -v \# $dir/${res}_blocks.bedpe \
        | awk -v res=$res '{OFS="\t"} NR>1 {printf "chr%s\t%d\t%d\nchr%s\t%d\t%d\n", $1, $2, $2+res, $1, $3-res, $3}' \
        | sort -k1,1 -k2,2n \
        | uniq \
        | sort -k1,1 -k2,2n \
        | bedtools merge > $dir/${res}_blocks.boundaries.bed

    # TAD coverage
    bedtools genomecov -bga -i $dir/${res}_blocks.bed -g $gt > $dir/${res}_blocks.TADcoverage.bed

    # intra-TAD regions
    cat $dir/${res}_blocks.TADcoverage.bed \
        | awk '{if($4>0 && $3-$2>=100000) printf "%s\t%d\t%d\t%d\n", $1, $2,$3, $3-$2}' \
              >  $dir/${res}_blocks.TADregions.bed

    # non-TAD region
    cat $dir/${res}_blocks.TADcoverage.bed | awk '{if($4==0) print}' | cut -f1-3 | sort -k1,1 -k2,2n > $dir/${res}_blocks.nonTADregions.bed

#    tmpfile1=$(mktemp "/tmp/${0##*/}.tmp.XXXXXX")
#    tmpfile2=$(mktemp "/tmp/${0##*/}.tmp.XXXXXX")
#    cat $dir/${res}_blocks.merged.bed | awk -v res=$res '{OFS="\t"} NR>1 {printf "%s\t%d\t%d\n", $1, $2, $3+res }' > $tmpfile1
#    sort -k1,1 -k2,2n $gt > $tmpfile2
#    bedtools complement -i $tmpfile1 -g $tmpfile2 > $dir/${res}_blocks.nonTADregions.bed
#    rm $tmpfile1 $tmpfile2
done
