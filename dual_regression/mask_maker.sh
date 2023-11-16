for i in {0..9}; do

n=`expr 1 + ${i}`
echo $n
fslmaths controls/dr_stage3_ic000${i}_tfce_corrp_tstat1.nii.gz -thr 0.99 component${n}_sig.nii.gz
fslmaths component${n}_sig.nii.gz -bin component${n}_sig.nii.gz 
fslmaths component${n}_sig.nii.gz -mas /rds/user/djw216/hpc-work/ucbj/MNI152_T1_2mm_brain_mask2.nii.gz component${n}_sig.nii.gz 

done

