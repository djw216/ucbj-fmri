function kat_fmri_smri_gift_run_RSFA(X)% subjects, spmfiles, out_dir, gica_template_fname, gica_fname, ncomp, do_parallel, num_workers, nscans )
%RUN_GIFT Replaces parameters in GIFT batch script given to function, and
%runs group ICA analysis

%-Delete existing directory and make a new one
%---------------------------------------------
try
    rmdir(X.out_dir,'s');
end
mkdir(X.out_dir);
cd(X.out_dir);


% Read in batch template file
gift_batch_script = fileread(X.gica_template_fname);


try f_mask = [strcat('''', X.f_mask ,'''')]; catch f_mask ='[]'; end

% Type of analysis; Options are 1, 2 and 3.
% 1 - Regular Group ICA
% 2 - Group ICA using icasso
% 3 - Group ICA using MST
if X.do_icasso
    X.which_analysis = 2;
else
    X.which_analysis = 1;
end

% Parallel computing
if X.do_parallel
    mode_comp = 'parallel'; % 'serial' | 'parallel'
else
    mode_comp = 'serial';
end

gift_batch_script = regexprep(gift_batch_script, '<WHICH_ANALYSIS>', num2str(X.which_analysis));
gift_batch_script = regexprep(gift_batch_script, '<DO_PARALLEL>', strcat('''', mode_comp,''''));
gift_batch_script = regexprep(gift_batch_script, '<NUM_WORKERS>', num2str(X.num_workers));
gift_batch_script = regexprep(gift_batch_script, '<NUM_ICASSO_RUNS>', num2str(X.num_icasso_runs));


% Set input file list
X.fepi = [strcat('''', X.filepaths ,'''')];
X.fepi = ['char(' cell2mat(strcat(X.fepi', ','))];
X.fepi(end) = [')'];
fl_str = X.fepi;%strcat('{', strjoin(X.fepi', ';\n'), '}');
% sl_str = strcat('{', strjoin(X.fspm', ';\n'), '}');
gift_batch_script = regexprep(gift_batch_script, '<INPUT_FILES>', fl_str);
gift_batch_script = regexprep(gift_batch_script, '<MASK_FILE>', f_mask);
% gift_batch_script = regexprep(gift_batch_script, '<SPM_FILES>', sl_str);

% Set output directory and files
gift_batch_script = regexprep(gift_batch_script, '<OUT_DIR>', strcat('''', X.out_dir, ''''));
gift_batch_script = regexprep(gift_batch_script, '<PREFIX>', strcat('''', X.giftprefix, ''''));

% Set/estimated number of components (using MDL criterion or user defined)
gift_batch_script = regexprep(gift_batch_script, '<DO_MDL>', num2str(X.do_mdl));
gift_batch_script = regexprep(gift_batch_script, '<PCA_NCOMP>', num2str(min(X.ncomp_pca,X.nscans-1)));
gift_batch_script = regexprep(gift_batch_script, '<ICA_NCOMP>', num2str(X.ncomp));


% Write out customised batch file
if exist(X.gica_fname) == 2
    delete(X.gica_fname);
    pause(2);
end
fid = fopen( X.gica_fname, 'wt');
fprintf(fid, '%s', gift_batch_script);
fclose(fid);


% wait until file writing finishes
while (~exist(X.gica_fname, 'file'))
  sleep(2); 
end

% Run analysis
icatb_batch_file_run(X.gica_fname);



% N.B. Make sure spatial maps reflect positive values
%--------------------------------------------------------------------------
f_maps      = fullfile(X.out_dir,[X.giftprefix '_group_component_ica_.nii']);
dataMaps    = icatb_loadData(f_maps);
Vmaps       = spm_vol(f_maps);

f_loadings  = fullfile(X.out_dir,[X.giftprefix '_group_timecourses_ica_.nii']);
dataLoad    = icatb_loadData(f_loadings);
Vloadings   = spm_vol(f_loadings);

for iComp = 1:size(dataMaps,4)
    iDat = nonzeros(dataMaps(:,:,:,iComp));
    if skewness(iDat)<0
        dataMaps(:,:,:,iComp) = dataMaps(:,:,:,iComp).*-1;
        dataLoad(:,iComp) = dataLoad(:,iComp).*-1;
    end
end
icatb_write_nifti_data(f_maps,Vmaps,dataMaps);
icatb_write_nifti_data(f_loadings,Vloadings,dataLoad);


% SBM in parallel mode saves loadings to sbm_group_timecourses_ica_.nii
% instead of sbm_group_loading_coeff_.nii. Check if that is the case and
% rename to correct file name.
f_loadings = fullfile(X.out_dir,[X.giftprefix '_group_timecourses_ica_.nii']);
if exist(f_loadings,'file')
    copyfile(f_loadings,regexprep(f_loadings,'timecourses_ica','loading_coeff'));
end

%% Print Report
global GICA_PARAM_FILE;
global GICA_CONFIG;
param_file = fullfile(X.out_dir, sprintf('%s_ica_parameter_info.mat',X.giftprefix));
GICA_PARAM_FILE  = param_file;



% Assign param_file and cfg in workspace
opts.threshold      = 1.97;
opts.image_values   = 'Positive and Negative';% options are 'Positive and Negative', 'Positive', 'Absolute Value' and 'Negative'

try
    opts.groupsInfo     = X.groupsInfo;
end
GICA_CONFIG        = opts;

assignin('base', 'param_file', param_file);
assignin('base', 'opts', opts);
% assignin('base', 'results', results);


% Write results to file using Publish
optsPublish                = [];
optsPublish.outputDir      = fullfile(X.out_dir,'report');
optsPublish.showCode       = false;
optsPublish.useNewFigure   = false;
optsPublish.format = lower('pdf');
optsPublish.createThumbnail = true;
if (strcmpi(optsPublish.format, 'pdf'))
    opt.useNewFigure = false;
end
optsPublish.imageFormat     = 'bmp';
optsPublish.codeToEvaluate = 'icatb_sbm_html_report(param_file,opts);';    
publish('icatb_sbm_html_report', optsPublish);


close all;
clear global GICA_PARAM_FILE;    
% 
% 
%     publish('icatb_sbm_html_report', 'outputDir',    X.dir_print, ...
%                                       'showCode',     false, ...
%                                       'useNewFigure', false, ...
%                                       'format',       'pdf', ...
%                                       'imageFormat',  'bmp' ...
%                                       );
end

