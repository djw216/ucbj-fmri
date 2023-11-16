LOGDIR=//home/djw216/rds/rds-rowe-k1PgZFWfeZY/group/p00259/ucbj/revision/dual_regression/sm6_tailored/component/scripts+logs
mkdir $LOGDIR

echo "sorting maps and running randomise"

$FSLDIR/bin/randomise -i /home/djw216/rds/rds-rowe-k1PgZFWfeZY/group/p00259/ucbj/revision/dual_regression/sm6_tailored/component/dr_stage2_ic0000.nii.gz -o /home/djw216/rds/rds-rowe-k1PgZFWfeZY/group/p00259/ucbj/revision/dual_regression/sm6_tailored/component/dr_stage3_ic0000.nii.gz -m /home/djw216/rds/rds-rowe-k1PgZFWfeZY/group/p00259/ucbj/revision/dual_regression/sm6_tailored/component_sig_mask.nii.gz -d /home/djw216/rds/rds-rowe-k1PgZFWfeZY/group/p00259/ucbj/revision/dual_regression/sm6_tailored/design.mat -t /home/djw216/rds/rds-rowe-k1PgZFWfeZY/group/p00259/ucbj/revision/dual_regression/sm6_tailored/design.con -n 5000 -T -v 3




