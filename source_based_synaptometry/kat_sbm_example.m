

%% SBM 
addpath(genpath('/home/djw216/ucbj/'))
%kat_import('gica');

%-Variable name in table T containing paths to images (this has to be prefixed by 'f_')
% e.g. T.f_rsfa contains filepaths to rsfa images
%--------------------------------------------------------------------------
nameData = 'ucbj';

S.paths.scripts = '/home/djw216/ucbj/sbm/'
T=readtable('ucbj_pvc_files.txt', 'Delimiter', 'tab');

%-Root directory for SBM outputs
%--------------------------------------------------------------------------
dirICA = '/home/djw216/rds/rds-rowe-k1PgZFWfeZY/group/p00259/ucbj/revision/sbm/ucbj/';

%-Brain mask (in the same resolution as brain images)
%---------------------------------------------------------------------------
f_brainmask = '/home/djw216/ucbj/ucbj/mask.nii.gz'


% -----------------------
% Initiate cfg structure 
% -----------------------
cfg                 = [];
cfg.doMDL           = 0;% 1 - estimate components empirically (ignores input in ncomops);
cfg.ncomps          = [10];% set desired number of compoents, could be more than one
cfg.nameData        = nameData; % Name of the variable in T table to point to files
cfg.dirICA          = dirICA; % Root directory for SBM outputs
cfg.f_mask          = f_brainmask;%
%cfg.doICASSO        = 1;
[S,T]               = kat_sbm_wrapper_rsfa(S,T,cfg);
