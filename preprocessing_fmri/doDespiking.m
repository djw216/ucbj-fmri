pd = pwd
cd /home/djw216/wbic/Downloads/BrainWavelet
setup
cd(pd)
WaveletDespike('filtered_func_data_clean.nii.gz', 'FUNCTIONAL', 'LimitRAM', 4,'threshold', 70)
quit()
