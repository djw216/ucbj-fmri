#!/bin/bash
export FSLOUTPUTTYPE=NIFTI_GZ
noddi=ODI_std.nii.gz # noddi file warped to MNI space 

echo "Creating noddi mask"
mask=${noddi/.nii.gz/_mask.nii.gz}
fslmaths $noddi -thr 0 -bin $mask

echo "Removing existing parcellation templates"
rm parcel_*

# iterate through the parcellation schemes
#for parcel in /brainnetome/BN_Atlas_246_2mm.nii.gz ; do
for parcel in hammers_fsl_2mm_mask.nii.gz ; do
 echo "Getting parcellation template"

 # create output file and overwrite any existing file
 #outFile=BN_Atlas_246_2mm_ts.txt
 outFile=noddi_hammers.txt

 # remove any previous timeseries
 rm $outFile 
 touch $outFile

 # mask parcel file by input mask
 parcelm=parcel_m.nii.gz
 fslmaths $parcel -mas $mask $parcelm
 
 rm ind*
 for i in {1..16} {20..43} {50..86} {88..89} {238..239} ; do
  ind=ind${x}.nii.gz
  fslmaths $parcelm -sub $i $ind
  # create a mask of 1's in the area of interest
  fslmaths $ind -mul $ind -bin -mul -1 -add 1 $ind
  
  # get number of voxels of parcellated brain
  nVox=`fslstats $ind -V`
  set -- $nVox
  nVox=$1
 
  if [ $nVox -gt 10 ] ; then 
   line=`fslstats $noddi -k $ind -m`
   echo "node"$i $line >> $outFile

  else
   line=`fslstats $noddi -k $ind -m`
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

mkdir hammers
mv noddi_hammers.txt hammers
