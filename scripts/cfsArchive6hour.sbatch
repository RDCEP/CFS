#!/bin/bash

#SBATCH --account=pi-joshuaelliott

#SBATCH --job-name=cfsArchive6hour

#SBATCH --workdir=/project/joshuaelliott/cfs

#SBATCH --time=8:00:00

#SBATCH --output=logs/cfsArchive6hour-%j.out

#SBATCH --nodes=1

#SBATCH --exclusive

#SBATCH --partition=westmere
#, sandyb 

R --slave -f scripts/cfsArchive6hour.R


