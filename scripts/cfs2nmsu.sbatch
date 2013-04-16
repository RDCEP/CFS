#!/bin/bash

#SBATCH --job-name=cfs2nmsu

#SBATCH --workdir=/project/joshuaelliott/cfs

#SBATCH --output=logs/cfs2nmsu-%j.out

#SBATCH --nodes=1

#SBATCH --tasks-per-node=4

#SBATCH --partition=westmere,sandyb

R --slave -f scripts/cfs2nmsu.R


