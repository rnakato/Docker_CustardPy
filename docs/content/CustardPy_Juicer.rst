CustardPy_Juicer
=====================

**CustardPy_Juicer** is a docker image for Juicer analysis in `CustardPy <https://github.com/rnakato/Custardpy>`_.
This is a wrapper of `Juicer <https://github.com/aidenlab/juicer/wiki>`_ and internally executes `juicertools <https://github.com/aidenlab/juicer/wiki/Feature-Annotation>`_.
See the original website for the full description about each command.

juicer_map.sh
----------------------------------------------------------------

``juicer_map.sh`` generates ``.hic`` file from fastq.
The input fastq files can be gzipped (.fastq.gz).
The results including the ``.hic`` file is outputted in ``$odir``.
Because this command uses `BWA <http://bio-bwa.sourceforge.net/>`_ for read mapping, the index files for BWA is needed.

.. code-block:: bash

    juicer_map.sh [options] <fastqdir> <odir> <build> <gt> <bwaindex> <fastq_post>
      <fastqdir>: directory that contains input fastq files (e.g., "fastq/sample1")
      <odir>: output directory (e.g., "JuicerResults/sample1")
      <build>: genome build (e.g., hg38)
      <gt>: genome table
      <bwaindex>: index file of BWA
      <fastq_post (_|_R)>: if the filename of fastqs is *_[1|2].fastq, supply "_". if *_[R1|R2].fastq, choose "_R".

    Options:
        -e enzyme: enzyme (default: HindIII)
        -p ncore: number of CPUs (default: 32)
        -m tmpdir: tempdir
    Example:
      juicer_map.sh $(pwd)/fastq/Hap1-A/ $(pwd)/JuicerResults/Hap1-A hg38 genometable.hg38.txt bwaindex/hg38 _R


.. note::

    The input fastq files of each sample should be stored in the separated directory.
    For example, if there are three Hi-C samples (``sample1``, ``sample2``, and ``sample3``), the fastq files should be in ``fastq/sample1/``,  ``fastq/sample2/``, and ``fastq/sample3/``.

(Optional) juicer_pigz.sh
-----------------------------------------------------------------

The output of Juicer is quite large, we provide a script ``juicer_pigz.sh`` that compresses the intermediate files.
This command is optional.

.. code-block:: bash

     juicer_pigz.sh <odir>
       <odir> output directory of juicer_map.sh (e.g., "JuicerResults/sample1")

Note that some commands provided in Juicer use the intermediate files (e.g, mega.sh).
Because these commands do not accept the compressed format, use ``juicer_unpigz.sh`` that uncompresses the compressed files.

.. code-block:: bash

     juicer_unpigz.sh <odir>
       <odir> output directory of juicer_map.sh (e.g., "JuicerResults/sample1")

plot_distance_count.sh
----------------------------------------------------------------

``plot_distance_count.sh`` calcultes the fragment distance and generates a figure (.pdf).


.. code-block:: bash

     plot_distance_count.sh <label> <odir>
       <label>: title of the figure
       <odir> output directory of juicer_map.sh (e.g., "JuicerResults/sample1")

call_HiCCUPS.sh
----------------------------------------------------------------

``call_HiCCUPS.sh`` call loops using Juicer HiCCUPS.
This command needs GPU. Supply ``--nv`` option to the singularity command as follows:

.. code-block:: bash

    singularity exec --nv custardpy_juicer.sif call_HiCCUPS.sh

    call_HiCCUPS.sh $norm $odir $hic $build
      <norm>: normalization (NONE|VC|VC_SQRT|KR|SCALE)
      <odir>: output directory
      <hic>: .hic file
      <build>: genome build

call_MotifFinder.sh
----------------------------------------------------------------

If you have peak files of cohesin and CTCF, you can use MotifFinder by ``call_MotifFinder.sh``:

.. code-block:: bash

    call_MotifFinder.sh $build $motifdir $loop
      <build>: genome build
      <motifdir>: the directory that contains the BED files
      <loop>: loop file (.bedpe) obtained by HiCCUPS

If the $build is (hg19|hg38|mm9|mm10), this command automatically supplies `FIMO <http://meme-suite.org/doc/fimo.html>`_ motifs provided by Juicer.

Output:
* merged_loops_with_motifs.bedpe

See `MotifFinder manual <https://github.com/aidenlab/juicer/wiki/MotifFinder>`_ for more information.

.. note ::

    Because of the version-dependent error, ``CustardPy`` uses ``juicer_tools.1.9.9_jcuda.0.8.jar`` for MotifFinder.


Full command example
----------------------------------------------------------------

These scripts assume that the fastq files are stored in ``fastq/$cell`` (e.g., ``fastq/Control_1``).
The outputs are stored in `JuicerResults/$cell`.

The whole commands using the Singularity image (``rnakato_juicer.sif``) are as follows:

.. code-block:: bash

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
