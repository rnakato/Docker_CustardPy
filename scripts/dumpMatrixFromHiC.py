#! /usr/bin/env python
# -*- coding: utf-8 -*-
import numpy as np
import hicstraw
import argparse

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("hicfile", help="input file (.hic format)", type=str)
    parser.add_argument("output", help="prefix of output file", type=str)
    parser.add_argument("chr", help="chromosome", type=str)
    parser.add_argument("--resolution", help="resolution (bp, default: 100000)", type=int, default=100000)
    parser.add_argument("--start", help="start position (default: 0)", type=int, default=0)
    parser.add_argument("--end", help="end position (default: chromosome end)", type=int, default=-1)
    parser.add_argument("--norm", help="normalization type (NONE|VC|VC_SQRT|KR|SCALE, default: SCALE)", type=str, default="SCALE")

    args = parser.parse_args()
    print(args)

    outprefix = args.output
    chr = args.chr
    resolution = args.resolution
    start = args.start
    end = args.end
    norm = args.norm

    hic = hicstraw.HiCFile(args.hicfile)
#    print(hic.getGenomeID())
#    print(hic.getResolutions())

    if end == -1:
        for chrom in hic.getChromosomes():
            if chrom.name == chr:
                end = int(chrom.length/resolution) * resolution

    print (chr + ": " + str(start) + "-" + str(end) + ".")
    if end == -1:
        print ("Error. the chromosome " + chr + "is not in the genome table.")
        exit

    mzd = hic.getMatrixZoomData(chr, chr, "observed", norm, "BP", resolution)
    dense_matrix = mzd.getRecordsAsMatrix(start, end, start, end)

    filename = "observed." + norm + "." + chr + ".matrix"
    np.savetxt(filename, dense_matrix, fmt="%e")
