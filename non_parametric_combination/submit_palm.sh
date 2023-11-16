#!/bin/bash
#SBATCH -A RITTMAN-SL3-CPU
#SBATCH -p cclake
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -t 12:00:00
#SBATCH -J npc
#SBATCH -o npc.out
#SBATCH -e npc.err

module purge
module load rhel7/default-peta4 matlab

matlab -nodisplay -r "palm_npc ; quit"
