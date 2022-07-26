for build in #mm39 #galGal5 #ce10 #hg19 hg38 mm10
do
    genome=/work/Database/UCSC/$build/genome.fa
    for enzyme in HindIII DpnII MboI; do
	python ../misc/generate_site_positions.py $enzyme $build $genome &
    done
done

genome=/work/Database/Database_fromDocker/Ensembl-GRCg6a/genome.fa
for enzyme in HindIII DpnII MboI; do
    python ../misc/generate_site_positions.py $enzyme galGal6 $genome &
done
