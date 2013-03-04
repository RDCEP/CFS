#!/bin/bash

#SBATCH --job-name=cfs2

#SBATCH --workdir=/project/joshuaelliott/cfs

#SBATCH --time=60

#SBATCH --output=logs/cfs2-%j.out

#SBATCH --nodes=1

#SBATCH --exclusive

#SBATCH --partition=westmere,sandyb

sbatch --begin=tomorrow scripts/cfs2.sbatch
R --slave -f scripts/cfs2.R


