# CustardPy_Juicer

**CustardPy_Juicer** is a docker image for Juicer analysis in [CustardPy](https://github.com/rnakato/Custardpy).
This is a wrapper of [Juicer](https://github.com/aidenlab/juicer/wiki) and internally executes juicertools. See the original website for the full description about each command.

## Related links

- The Dockerfile of **CustardPy_Juicer** is based on [aidenlab/juicer](https://hub.docker.com/r/aidenlab/juicer).
- **CustardPy_Juicer** is the newer version of [docker_juicer](https://github.com/rnakato/docker_juicer).
- Docker image of **CustardPy_Juicer** is available at: https://hub.docker.com/repository/docker/rnakato/custardpy_juicer/general

## Run

For Docker:

    # pull docker image
    docker pull rnakato/custardpy_juicer 

    # container login
    docker run [--gpus all] --rm -it rnakato/custardpy_juicer /bin/bash
    # execute a command
    docker run [--gpus all] --rm -v (your directory):/opt/work rnakato/custardpy_juicer <command>

For Singularity:

    # build image
    singularity build custardpy_juicer.sif docker://rnakato/custardpy_juicer
    # execute a command
    singularity exec [--nv] custardpy_juicer.sif <command>

## Usage

### juicer_map.sh: generate .hic file from fastq

    juicer_map.sh [-m $tmpdir] $odir $build $fqdir $enzyme $fastq_post
    <odir>: output directory (e.g., "JuicerResults")
    <build>: genome build
    <fqdir>: directory that contains input fastq files (e.g., "fastq/sample1")
    <enzyme>: enzyme name (e.g., "HindIII", "MboI")

Note that the fastq files of each sample should be stored in the separated directory. For example, if there are three Hi-C samples (`sample1`, `sample2`, and `sample3`), The fastq files should be in `fastq/sample1`,  `fastq/sample2`, and `fastq/sample3`. Then the mapping results including the .hic file is outputted in `JuicerResults/sample1`.

The outputs are stored in `JuicerResults/$cell`.

The BWA index files should be at `/work/Database/bwa-indexes/UCSC-$build`.

### call_HiCCUPS.sh: call loops using HiCCUPS

This command needs GPU. Supply `--nv` option to the singularity command as follows:

    singularity exec --nv custardpy_juicer.sif call_HiCCUPS.sh 

    call_HiCCUPS.sh $norm $odir $hic $build
    <norm>: normalization (NONE|VC|VC_SQRT|KR|SCALE)
    <odir>: output directory
    <hic>: .hic file
    <build>: genome build

### call_MotifFinder.sh: execute MotifFinder

If you have peak files of cohesin and CTCF, you can use MotifFinder:

    call_MotifFinder.sh $build $motifdir $loop
    <build>: genome build
    <motifdir>: the directory that contains the BED files
    <loop>: loop file (.bedpe) obtained by HiCCUPS

If the $build is (hg19|hg38|mm9|mm10), this command automatically supplies [FIMO](http://meme-suite.org/doc/fimo.html) motifs provided by Juicer.

Output:
* merged_loops_with_motifs.bedpe

See [MotifFinder manual](https://github.com/aidenlab/juicer/wiki/MotifFinder) for more information.


### Full command example

These scripts assume that the fastq files are stored in `fastq/$cell` (e.g., `fastq/Control_1`).
The outputs are stored in `JuicerResults/$cell`.
The BWA index files should be at `/work/Database/bwa-indexes/UCSC-$build`.

The whole commands using the Singularity image (`rnakato_juicer.sif`) are as follows:

    build=hg38
    fastq_post="_R"  # "_" or "_R"  before .fastq.gz
    enzyme=MboI      # enzyme type

    gt=genome_table.$build.txt  # genome_table file
    gene=refFlat.$build.txt # gene annotation (refFlat format)
    sing="singularity exec rnakato_juicer.sif"  # singularity command

    for cell in `ls fastq/* -d | grep -v .sh`
    do
        cell=$(basename $cell)
        odir=$(pwd)/JuicerResults/$cell
        echo $cell

        rm -rf $odir
        mkdir -p $odir
        if test ! -e $odir/fastq; then ln -s $(pwd)/fastq/$cell/ $odir/fastq; fi

        # generate .hic file by Juicer
        $sing juicer_map.sh $odir $build $enzyme $fastq_post

        # plot contact frequency
        if test ! -e $odir/distance; then $sing plot_distance_count.sh $cell $odir; fi

        # select normalization type
        norm=VC_SQRT

        # make contact matrix for chromosomes
        hic=$odir/aligned/inter_30.hic
        if test ! -e $odir/Matrix; then
            $sing juicer_makematrix.sh $norm $hic $odir $gt
        fi

        # call TADs (arrowHead)
        if test ! -e $odir/TAD; then
            $sing juicer_callTAD.sh $norm $hic $odir $gt
        fi

        # calculate Pearson coefficient and Eigenvector
        for resolution in 25000
        do
                $sing makeEigen.sh Pearson $norm $odir $hic $resolution $gt $gene
                $sing makeEigen.sh Eigen $norm $odir $hic $resolution $gt $gene
        done

        # calculate insulation score
        if test ! -e $odir/InsulationScore; then $sing juicer_insulationscore.sh $norm $odir $gt; fi

        # call loops (HICCUPS, add '--nv' option to use GPU)
        singularity exec --nv rnakato_juicer.sif call_HiCCUPS.sh $norm $odir $hic $build
        # motif analysis
        $sing juicertools.sh motifs $build $motifdir $odir/loops/$norm/merged_loops.bedpe hg38.motifs.txt
    done


## Build Docker image from Dockerfile
First clone and move to the repository

    git clone https://github.com/rnakato/CustardPy_Juicer.git
    cd CustardPy_Juicer

Then type:

    docker build -f Dokerfile.<version> -t <account>/custardpy_juicer .

## Contact

Ryuichiro Nakato: rnakato AT iqb.u-tokyo.ac.jp
