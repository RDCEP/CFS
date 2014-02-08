#!/bin/bash

#SBATCH --account=pi-joshuaelliott

#SBATCH --job-name=cfsrr

#SBATCH --workdir=/project/joshuaelliott/cfs

#SBATCH --time=4:00:00

#SBATCH --output=logs/cfsrr-%j.out

#SBATCH --nodes=1

#SBATCH --exclusive

#SBATCH --partition=westmere,sandyb

R --slave -f scripts/cfsrr.R


