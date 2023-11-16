This folder contains code used in image preprocessing and analysis for 	'Synaptic density affects clinical severity via network dysfunction in syndromes associated with Frontotemporal Lobar Degeneration'

1) Scripts for fMRI preprocessing are in preprocessing_fmri, adapted from Tim Rittman.

These require FSL, FSL's FIX, Matlab, and the Brain Wavelet toolbox

2) Scripts to derive weighted degree for the various referenced atlases are in the graph_metrics folder, which uses Tim Rittman's Maybrain (https://github.com/RittmanResearch/maybrain) and NetworkX. This folder also contains a script to reparcellate an atlas (in this case, the modified Hammer's atlas) into approximate equal sized parcels

3) Script using samseg in freesurfer in order to calculate total intracranial volume

4) Source based synaptometry was performed using Kamen Tsvetanov's scripts. These require the GIFT toolbox.

5) Non-parametric combination testing was performed using the scripts in the 'non_parametric_combination' folder, which require Palm (version-119alpha)

6) Dual regression requires FSL 

7) Normalization of UCB-J and ODI maps used Advanced Normalization Tools

8) Analysis scripts are performed in R, with the exception of spatial-autocorrelation preserving permuation testing with needs python and the neuromaps toolbox

Relevant data and derived values are included in the data source file