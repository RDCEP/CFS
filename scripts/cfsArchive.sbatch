#!/bin/bash

#SBATCH --account=pi-joshuaelliott

#SBATCH --job-name=cfsArchive

#SBATCH --workdir=/project/joshuaelliott/users/nbest/cfs

#SBATCH --time=12:00:00

#SBATCH --output=logs/cfsArchive-%j.out

#SBATCH --nodes=1

#SBATCH --exclusive

R --slave -f scripts/cfsArchive.R


