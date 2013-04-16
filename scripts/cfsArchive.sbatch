#!/bin/bash

#SBATCH --account=pi-joshuaelliott

#SBATCH --job-name=cfsrr

#SBATCH --workdir=/project/joshuaelliott/cfs

#SBATCH --time=60

#SBATCH --output=logs/cfsrr-%j.out

#SBATCH --nodes=1

#SBATCH --exclusive

R --slave -f scripts/cfsrr.R


