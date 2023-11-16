#!/bin/bash
# Script for preprocessing in keeping with the biobank/FSL approach. This method uses
# ICA denoising using fix, and motion correction with wavelet despiking.

##########################
#### Variables to set ####
##########################

# location of the preprocessing scripts
preproc_dir=preprocessing_tf_fmri/preprocessing_scripts

# set the location of the design file 
designfile=preprocessing_scripts/design_6DOFreg.fsf

## set variables for fix
# set the trained FIX data
trainingset=/fixTrainingSet.RData

# set the location of the fix programme 
fixLocation=/home/djw216/fix/

# set the location of your conda fix environment
condaFix=/home/tr332/.conda/envs/fix/

# fix threshold
fixthresh=20

############################################
# The lines below should not need changing #
############################################

# load FSL 6.0.3 environment
module unload fsl
module load fsl/6.0.4
export FSLOUTPUTTYPE=NIFTI_GZ

#cp $designfile design.fsf

# update the length of data in the design
#nvol=`fslnvols FUNCTIONAL.nii.gz`
#sed -i "s/XXXX/${nvol}/g" design.fsf

# update the total number of voxels in the design file
dim1=`fslval FUNCTIONAL.nii.gz dim1`
dim2=`fslval FUNCTIONAL.nii.gz dim2`
dim3=`fslval FUNCTIONAL.nii.gz dim3`
dim4=`fslval FUNCTIONAL.nii.gz dim4`

let "allvox = $dim1 * $dim2 * $dim3 * $dim4"
sed -i "s/TTTT/${allvox}/g" design.fsf

# update the directory in the design file
sed -i 's?CCCC?'`pwd`'?g' design.fsf

# skull strip the structural image
robustfov -i DATA -r DATA
bet DATA.nii.gz DATA_brain.nii.gz -R -f 0.4 -g -0.2

# run preprocessing with feat
feat design.fsf


############################################################
## The next lines will only work if fix has been trained   #
## You may wish to comment these lines before training fix #
############################################################

# load fix environment
module load Anaconda
source  /applications/Anaconda/etc/profile.d/conda.sh
conda activate fix

# set library path for gcc to work properly
export LD_PRELOAD=${condaFix}/lib/libstdc++.so.6.0.26:$LD_PRELOAD

# denoising with fix
${fixLocation}/fix FUNCTIONAL.ica $trainingset $fixthresh

# wavelet despiking
cd FUNCTIONAL.ica
ln -s ${preproc_dir}/doDespiking.m .
matlab -nosplash -nodesktop -r "doDespiking"

#warp functional image to standard MNI space
applywarp --ref=${FSLDIR}/data/standard/MNI152_T1_2mm_brain --in=FUNCTIONAL_wds.nii.gz --warp=reg/example_func2standard_warp --out=FUNCTIONAL_wds_std.nii.gz

# check motion parameters
cd ../
fsl_motion_outliers -i FUNCTIONAL.ica/FUNCTIONAL_wds_std.nii.gz -o motion_dvars -s motionmetrics_dvars.txt -p metrics_dvars.png --dvars
fsl_motion_outliers -i FUNCTIONAL.ica/FUNCTIONAL_wds_std.nii.gz -o motion_refrms -s motionmetrics_refrms.txt -p metrics_refrms.png --refrms
fsl_motion_outliers -i FUNCTIONAL.nii.gz -o motion_fd -s motionmetrics_fd.txt -p metrics_fd.png --fd
