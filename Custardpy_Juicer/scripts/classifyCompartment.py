#! /usr/bin/env python
# -*- coding: utf-8 -*-

import numpy as np
import pandas as pd
import os
import argparse
import subprocess

def add_compartment(d):
    d["Compartment"] = "NaN"
    st = d["Eigen"].describe().transpose()

    for i, row in d.iterrows():
        if row['Eigen'] > st["75%"]:
            d.loc[i, 'Compartment'] = 'Strong A'
        elif row['Eigen'] > np.nanmedian(d["Eigen"]):
            d.loc[i,'Compartment'] = 'Weak A'
        elif row['Eigen'] > st["25%"]:
            d.loc[i,'Compartment'] = 'Weak B'
        elif row['Eigen'] >= st["min"]:
            d.loc[i,'Compartment'] = 'Strong B'

    return d

def merge_compartmentfiles(prefix, outfile):
    subprocess.call("grep 'Strong A' " + outfile + " | bedtools merge -d 1 > " + prefix + ".StrongA.bed", shell=True)
    subprocess.call("grep 'Weak A' "   + outfile + " | bedtools merge -d 1 > " + prefix + ".WeakA.bed", shell=True)
    subprocess.call("grep 'Weak B' "   + outfile + " | bedtools merge -d 1 > " + prefix + ".WeakB.bed", shell=True)
    subprocess.call("grep 'Strong B' " + outfile + " | bedtools merge -d 1 > " + prefix + ".StrongB.bed", shell=True)
    subprocess.call("cat " + prefix + ".StrongA.bed " + prefix + ".WeakA.bed" "| sort -k1,1 -k2,2n | bedtools merge -d 1 > " + prefix + ".A.bed", shell=True)
    subprocess.call("cat " + prefix + ".StrongB.bed " + prefix + ".WeakB.bed" "| sort -k1,1 -k2,2n | bedtools merge -d 1 > " + prefix + ".B.bed", shell=True)
    subprocess.call("cat " + prefix + ".WeakA.bed " + prefix + ".WeakB.bed" "| sort -k1,1 -k2,2n | bedtools merge -d 1 > " + prefix + ".Suppressed.bed", shell=True)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("input", help="Input (eigen file)", type=str)
    parser.add_argument("output", help="Output prefix", type=str)
    parser.add_argument("chr", help="Chromosome name", type=str)
    parser.add_argument("resolution", help="resolution", type=int)

    args = parser.parse_args()

    file = args.input
    df = pd.read_csv(file, header=None)
    df.columns = ["Eigen"]
    chr = args.chr
    resolution = args.resolution
    df["chromosome"] = chr
    df["start"] = [n*resolution for n in list(range(0, df.shape[0]))]
    df["end"] = [n*resolution for n in list(range(1, df.shape[0]+1))]

    df = add_compartment(df)

    outfile = args.output + ".All.bed"
    df[["chromosome", "start", "end", "Compartment"]].to_csv(outfile, sep="\t", header=False, index=False)

    merge_compartmentfiles(args.output, outfile)


if(__name__ == '__main__'):
    main()
