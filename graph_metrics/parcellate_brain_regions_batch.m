% parcellate_brain_regions_batch 
% Take an atlas and parcelate individual regions
p='/home/djw216/rds/hpc-work/atlases/templates_Hammersmith/Hammersmith/Hammers_mith_icbm_psp_to_ICBM/hammers_fsl_2mm_mask_parcEUCLIDIAN.nii';

tic
% parpool('local',4);
stream = RandStream('mlfg6331_64');  % Random number stream

v=spm_vol(p);
[y,XYZ]=spm_read_vols(v);
yout=zeros(size(y));

unique_y=unique(y);
unique_y=sort(unique_y);
unique_y(unique_y==0)=[];
%Each region parcellated will contain parcels beginning at 1 and will need
%to be increased by nstep
nstep=0;
for j=1:numel(unique_y)
   jy=unique_y(j);
    yr_p=y==jy;
    
    %Get volume of the roi
    yr_vol=sum(logical(yr_p(:)));
    yr_p=double(yr_p);
    %Break the volume into clusters according to the size of yr_vol
    %Attempt to use volumes ~750
    % Leave regions<1500 unchanged
    n=1;
    if yr_vol < 1500
        n=1;
    elseif yr_vol >= 1500 && yr_vol < 2250
        n=2;
    elseif yr_vol >= 2250 && yr_vol < 3000
        n=3;
    elseif yr_vol >= 3000 && yr_vol < 3750
        n=4;
    elseif yr_vol >= 3700 && yr_vol < 4500
        n=5;
    elseif yr_vol >= 4500 && yr_vol < 5250
        n=6;
    elseif yr_vol >= 5250 && yr_vol < 6000
        n=7;
    elseif yr_vol >= 6000 && yr_vol < 9000
        n=8;
    else
        n=round(yr_vol/2000);
    end
    
    if n>1
        yr_p=parcellate_brain_regions(yr_p,XYZ,n,stream);
    end
    
    %number of new parcels
    %remove 0 region OUTSIDE brain
    num_yr=numel(unique(yr_p))-1;
    yr_p(yr_p>0)=yr_p(yr_p>0)+ nstep;
    
    yout=yout+yr_p;
    nstep=nstep+num_yr; 
end

[ap,af,ax]=spm_fileparts(p);
vout=v;
vout.dt(1)=spm_type('int16');
vout.fname=fullfile(ap,strcat(af,'_parcEUCLIDIAN',ax));

vout=spm_create_vol(vout);
for j=1:vout.dim(3) spm_write_plane(vout,yout(:,:,j),j); end

disp('Finished all parcellations')
toc
