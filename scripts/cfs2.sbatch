#!/bin/bash

#SBATCH --job-name=cfs2

#SBATCH --workdir=/project/joshuaelliott/users/nbest/cfs

# #SBATCH --time=0

#SBATCH --output=logs/cfs2-%j.out

#SBATCH --nodes=1

# #SBATCH --cpus-per-task=4

#SBATCH --exclusive

#SBATCH --partition=westmere

sbatch --begin=now+1day scripts/cfs2.sbatch
R --slave -f scripts/cfs2.R


