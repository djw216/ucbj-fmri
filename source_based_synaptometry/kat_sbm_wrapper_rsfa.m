function [S T] = kat_sbm_rsfa_wrapper(S,T,cfg)
% Run SBM on brain maps (e.g. RSFA or T1 nii)
% Inputs:
% S   - structure with subfields containing general information about the
%       analysis. e.g. S.paths.scripts is the filepath to the scripts for
%       this project.
%       required subfields:
%       +   S.paths.scripts - filepath to the scripts for this project
%
% T   - table with subject specific information, e.g. age (T.age)
%       required subfield:
%       +   T.f_**** - filepaths to nii images, where **** is the name of the
%           images, e.g. f_rsfa is variable with filepaths to rsfa images.
%       +   T.subID  - Subject IDs
% cfg - structure with fields containing information for SBM analysis
%
% Outputs:
% S   - same as S input including some setting about SBM analysis
% T   - same as T input including subject loadings for all ICs
%
% Use rsfacv_util_ica_process for estimation of optimal number of ICs 

dirICA      = cfg.dirICA;
nameData    = cfg.nameData;
try ncomps      = cfg.ncomps;   catch ncomps = [10]; end
try doMDL       = cfg.doMDL;    catch doMDL = 0;    end
try doICASSO    = cfg.doICASSO; catch doICASSO = 0; end
% try doICA       = cfg.doICA;    catch doICA = 0;    end

%-Identify subjects with  available brain maps (eg. RSFA)
%--------------------------------------------------------
idxSub = ~cellfun(@isempty, T.(['f_' nameData])); %  Identify subjects with available data
% idxSub = all([idxSub cfg.idxSub],2);
numSub = numel(find(idxSub));
tbl    = T(idxSub,:);


%-Assign a new variable with filepaths to images
%------------------------------------------------
filepaths = tbl.(['f_' nameData]);

%-Assign new variable with Subject IDs for cross-referencing with outputs
%------------------------------------------------------------------------
subID = tbl.SubID;


%-Brain mask (in the same resolution as brain images)
%---------------------------------------------------------------------------
f_brainmask =  cfg.f_mask;

%-Path and name of gift batch template file
%-------------------------------------------------------------------------
f_gica_template = fullfile(S.paths.scripts,'kat_sbm_gift_batch_template_rsfa.m'); 

% ICA Setup
%--------------------------------------------------------------------------
ICA                     = [];
ICA.do_mdl              = doMDL; % 1 - Do number of PCs using MDL criterion estimation
ICA.ncomps              = ncomps;%,30,40,50,75,100];
ICA.prefix              = sprintf('sbm_%s',nameData); % prefix for output directory
ICA.giftprefix          = 'sbm';% Prefix of sbm output files;{'CC700', 'CC280', 'CC700_CC280'};
ICA.scan_vec            = 1:100; 
ICA.nscans              = 100;%S.data.numVols;
ICA.filepaths           = filepaths;
ICA.nsubjects           = numSub;
ICA.SubID               = subID;
ICA.do_parallel         = 1; % 1-do parallel | 0 - do serial
ICA.num_workers         = 128;
ICA.num_icasso_runs     = 128;
ICA.do_icasso           = doICASSO;
ICA.f_mask              = f_brainmask;
ICA.root_dir            = fullfile(dirICA,nameData);
ICA.gica_template_fname = f_gica_template; % Path and name of gift batch template file
%     ICA.groupsInfo.name   = 'Age';
%     ICA.groupsInfo.val    = T.Age'; % Varible to be correlated with subject loading values

global GICA_PARAM_FILE;

for ii = 1:length(ICA.ncomps)
    ICA.ncomp     = ICA.ncomps(ii);  
    ICA.ncomp_pca = ICA.ncomp;%min([ceil(ICA.ncomp*1.5),ICA.nsubjects ]) ; % Number of Principle Components = number of ICs with a factor of 1.25
   
    %-Output directory and settings file
    %-------------------------------------------------------------
    if ICA.do_mdl == 1
         ICA.out_dir = fullfile(ICA.root_dir, sprintf('%s_mdl_n%0.3d_%s', ICA.prefix,ICA.nsubjects,datestr(now,'yyyymmdd')));
    else
        ICA.out_dir    = fullfile(ICA.root_dir, sprintf('%s_IC%0.3d_n%0.3d_%s', ICA.prefix, ICA.ncomp,ICA.nsubjects,datestr(now,'yyyymmdd')));
    end
    ICA.gica_fname = fullfile(ICA.out_dir,'gift_batch_config.m');
    

    %-Run SBM with settings in ICA
    %----------------------------------
    kat_sbm_gift_run_rsfa(ICA);
    close all;
    
    
    %-Collect some outputs after running SBM
    %---------------------------------------
    ICA.param_file  = fullfile(ICA.out_dir, sprintf('%s_ica_parameter_info.mat',ICA.giftprefix));
    ICA.icasso_file = fullfile(ICA.out_dir, sprintf('%s_icasso_results.mat',ICA.giftprefix));

    Loadings        = icatb_loadData([ICA.out_dir '/sbm_group_loading_coeff_.nii']);
    [~,idxSub]      = ismember(ICA.SubID,T.SubID);

    if ismember(['loadings_' nameData],T.Properties.VariableNames)
        T.(['loadings_' nameData])=[];
    end
    T.(['loadings_' nameData]) = nan(height(T),size(Loadings,2));
    T(idxSub,(['loadings_' nameData])) = num2cell(Loadings,2); 

    S.paths.(['ica_' nameData]) = ICA.root_dir;
    S.ica.(nameData) = ICA;
    save(fullfile(ICA.out_dir,'settings_ica_output.mat'),'S','T','ICA');
end


