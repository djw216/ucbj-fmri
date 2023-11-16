##line to perform regression pf UCB-J maps v gm segmentations in standard space

fsl_glm -i pet_all_sm6.nii.gz -d gm_all8.nii.gz -m mask.nii.gz -o regressed.txt --out_res=res.nii.gz

