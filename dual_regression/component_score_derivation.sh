for i in {0..9}; do

n=`expr 1 + ${i}`
echo $n >> good_components_score.txt
  for j in {00..78}; do
  fslmeants -i component${n}/dr_stage2_subject000${j}_Z.nii.gz -m component${i}_sig.nii.gz >> good_components_score.txt
  done

done

