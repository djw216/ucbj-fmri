#!/bin/bash
export FSLOUTPUTTYPE=NIFTI_GZ
func=FUNCTIONAL_wds_std.nii.gz # functional file warped to MNI space 
echo "Creating mean functional image"
fslmaths $func -Tmean ${func/.nii.gz/_mean.nii.gz}

echo "Creating functional mask"
mask=${func/.nii.gz/_mask.nii.gz}
fslmaths ${func/.nii.gz/_mean.nii.gz} -mul ${func/.nii.gz/_mean.nii.gz} -bin $mask
echo "Removing existing parcellation templates"
rm parcel_*

# iterate through the parcellation schemes
#for parcel in /home/djw216/wbic/brainnetome/BN_Atlas_246_2mm.nii.gz ; do
for parcel in /home/djw216/rds/hpc-work/atlases/templates_Hammersmith/Hammersmith/Hammers_mith_icbm_psp_to_ICBM/hammers_fsl_2mm_mask.nii.gz ; do
 echo "Getting parcellation template"

 # create output file and overwrite any existing file
 #outFile=BN_Atlas_246_2mm_ts.txt
 outFile=hammers_2mm_ts.txt

 # remove any previous timeseries
 rm $outFile 
 touch $outFile

 # mask parcel file by input mask
 parcelm=parcel_m.nii.gz
 fslmaths $parcel -mas $mask $parcelm
 
 rm ind*
 for i in {1..16} {20..43} {50..51} {54..86} {88..89} {238..239} ; do
  ind=ind${x}.nii.gz
  fslmaths $parcelm -sub $i $ind
  # create a mask of 1's in the area of interest
  fslmaths $ind -mul $ind -bin -mul -1 -add 1 $ind
  
  # get number of voxels of parcellated brain
  nVox=`fslstats $ind -V`
  set -- $nVox
  nVox=$1
 
  if [ $nVox -gt 10 ] ; then 
   line=`fslmeants -i $func -m $ind --transpose`
   echo $line >> $outFile

  else
   line=`fslmeants -i $func -m $ind --transpose`
   len=`wc -w <<< $line`
   
   echo "Not enough voxels"
   echo `yes "NA" | head -n $len` >> $outFile

  fi


  rm $ind
 done 
done
# tidy up
rm parcel_*
rm ind*

mkdir timeseries
mv *ts.txt timeseries
