#!/bin/bash
#!
#! Example SLURM job script for WBIC
#! Last updated: Mon Nov 07 16:30:00 BST 2016
#! By: Paul Browne (pfb29)

#!#############################################################
#!#### Modify the options in this section as appropriate ######
#!#############################################################

#! sbatch directives begin here ###############################
#! Name of the job:
#SBATCH -J spm_func 
#! Which project should jobs run under:
# SBATCH -A RITTMAN-SL3-CPU
#! How many whole nodes should be allocated?
#SBATCH --nodes=1
#! How many (MPI) tasks will there be in total? (<= nodes*24)
#SBATCH --ntasks=4
#!COMMENT THIS OUT IF PASSING --array=1-N as a parameter passed to this function
#! PASS ARRAY SIZE ON THE FLY sbatch --array=1-`<infiles.txt wc -l` $func infiles.txt
#SBATCH --array=1-123
#SBATCH --output=array_spm.%A_%a.slurm
#SBATCH --error=array_spm.%A_%a.error
#! For multithread application
#!SBATCH cpus-per-task=1
#!SBATCH --mem=4000M
#!SBATCH --mem-per-cpu=5000M
#! How much wallclock time will be required?
#SBATCH --time=1:00:00
#! What qos? veryshort.q=00:01:00, short.q=00:08:00, long.q=7-00:00:00, verylong.q=14-00:00:00
#!SBATCH --qos=veryshort.q
#!SBATCH --mail-user=tp500@cam.ac.uk
#! What types of email messages do you wish to receive?
#!SBATCH --mail-type=NONE 	# Mail events(NONE, BEGIN, END, FAIL, ALL)
##SBATCH --output=${sid%.nii.gz}_%j_gtmseg_output
##SBATCH --error=${sid%.nii.gz}_%j_gtmseg_error
#! Uncomment this to prevent the job from being requeued (e.g. if
#! interrupted by node failure or system downtime):
#!SBATCH --no-requeue

#! Do not change:
#SBATCH -p icelake

#! sbatch directives end here (put any additional directives above this line)

#! Notes:
#! The --ntasks value refers to the number of tasks to be launched by SLURM only. This
#! usually equates to the number of MPI tasks launched. Reduce this from nodes*24 if
#! demanded by memory requirements, or if OMP_NUM_THREADS>1.

#! Each task is allocated 1 core by default, and each core is allocated 2500MB.
#! If this is insufficient, also specify --cpus-per-task and/or --mem (the latter specifies
#! MB per node).

#! Number of nodes and tasks per node allocated by SLURM (do not change):
numnodes=$SLURM_JOB_NUM_NODES
numtasks=$SLURM_NTASKS
mpi_tasks_per_node=$(echo "$SLURM_TASKS_PER_NODE" | sed -e  's/^\([0-9][0-9]*\).*$/\1/')
#! ############################################################
#! Modify the settings below to specify the application's environment, location
#! and launch method:

#! Optionally modify the environment seen by the application
#! (note that SLURM reproduces the environment at submission irrespective of ~/.bashrc):
. /etc/profile.d/modules.sh                # Leave this line (enables the module command)
module purge                               # Removes all modules still loaded
module load rhel7/default-peta4            # REQUIRED - loads the basic environment


module load matlab

#Apply func to ref image.
prepare=cat12/spm_prepare.sh
func=cat12/cat12_segment_v1791.m
#infile=$3
#ref=$3
#If there are other images ...
#source=$4
#other=$5
#other2=$6
#other3=$7
#other4=$8


#Read each line of infile into a variable LINE will contain n images or variables expected by $func
LINE=$(sed -n "$SLURM_ARRAY_TASK_ID"p files.txt)
pwd; hostname; date

#! Insert additional module load commands after this line if needed:

#!Put application here

indir=$PWD
application="${prepare} ${func} ${LINE}" 

#! Assume the $infile has 1 or 2 nifti images only
#ref=`echo $LINE | awk '{print $1}'`
#source=`echo $LINE | awk '{print $2}'`

#! Put  here
#of=`basename ${ref%.nii.gz}`
#of=`basename ${of%.nii}`
#if [ -z ${source} ] 
#then
#	echo source is empty#
#	outfile=output_${of}
#	errfile=error_${of}
#else
#	of2=`basename ${source%.nii.gz}`
#	of2=`basename ${of2%.nii}`
#	outfile=output_${of}_${of2}
#	errfile=error_${of}_${of2}	
#fi
	
#mkdir tmp

#options=" >${outfile} 2>${errfile}"

#! Work directory (i.e. where the job will run):
workdir="$SLURM_SUBMIT_DIR"  # The value of SLURM_SUBMIT_DIR sets workdir to the directory
                             # in which sbatch is run.

#! Are you using OpenMP (NB this is unrelated to OpenMPI)? If so increase this
#! safe value to no more than 16:
#! export OMP_NUM_THREADS=1

#! Number of MPI tasks to be started by the application per node and in total (do not change):
#!np=$[${numnodes}*${mpi_tasks_per_node}]

#! The following variables define a sensible pinning strategy for Intel MPI tasks -
#! this should be suitable for both pure MPI and hybrid MPI/OpenMP jobs:
#export I_MPI_PIN_DOMAIN=omp:compact # Domains are $OMP_NUM_THREADS cores in size
#export I_MPI_PIN_ORDER=scatter # Adjacent domains have minimal sharing of caches/sockets
#! Notes:
#! 1. These variables influence Intel MPI only.
#! 2. Domains are non-overlapping sets of cores which map 1-1 to MPI tasks.
#! 3. I_MPI_PIN_PROCESSOR_LIST is ignored if I_MPI_PIN_DOMAIN is set.
#! 4. If MPI tasks perform better when sharing caches/sockets, try I_MPI_PIN_ORDER=compact.

#! Uncomment one choice for CMD below (add mpirun/mpiexec options if necessary):

#! Choose this for a MPI code (possibly using OpenMP) using OpenMPI:
#!CMD="mpirun -npernode $mpi_tasks_per_node -np $np $application $options1" > output_${image} 2> error_${image} 
#!CMD="mpirun -npernode $mpi_tasks_per_node -np $np $application $options"

#! Choose this for a pure shared-memory OpenMP parallel program on a single node:
#! (OMP_NUM_THREADS threads will be created):
CMD="$application $options"

###############################################################
### You should not have to change anything below this line ####
###############################################################

cd $workdir
echo -e "Changed directory to `pwd`.\n"

JOBID=$SLURM_JOB_ID

echo -e "JobID: $JOBID\n======"
echo "Time: `date`"
echo "Running on master node: `hostname`"
echo "Current directory: `pwd`"

if [ "$SLURM_JOB_NODELIST" ]; then
        #! Create a machine file:
        export NODEFILE=`generate_pbs_nodefile`
        cat $NODEFILE | uniq > machine.file.$JOBID
        echo -e "\nNodes allocated:\n================"
        echo `cat machine.file.$JOBID | sed -e 's/\..*$//g'`
fi

echo -e "\nnumtasks=$numtasks, numnodes=$numnodes, mpi_tasks_per_node=$mpi_tasks_per_node (OMP_NUM_THREADS=$OMP_NUM_THREADS)"

echo -e "\nExecuting command:\n==================\n$CMD\n"

eval $CMD
