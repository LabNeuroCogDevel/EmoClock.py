function Clock_ICA_denoising_wrapper( subjects )
%This is a wrapper function that will run ICA denoising on multimodal clock
%subjects. The input files are assumed to be subj_clock_runx_ds_sss_raw.fif.
%Which has been downsampled and sss'd. The output will be
%subj_clock_runx_dn_ds_sss_raw.fif. The function will loop through subjects
%and runs in the multimodal anti study folder.
%   Usage: MEG_ICA_denoising_wrapper( subj, ekg_flag )
%   subjects - vector of subjects to be analyzed

%
%last update 4.16.2014.

for s = 1:size(subjects,2) 
    subj = subjects(s);
    
    %on arnold
    [~,hostname] = system('hostname');
    hostname = hostname(hostname ~= 10);
    if strcmp('Schwarzenagger.local',hostname)
        MultiModal_DIR = '/Volumes/T800/Multimodal/Clock/';
        WorkingDir = fullfile(MultiModal_DIR,num2str(subj),'/MEG');
    else %on wallace
        MultiModal_DIR = '/raid/r3/p2/Luna/Multimodal/Clock';
        WorkingDir = fullfile(MultiModal_DIR,num2str(subj),'/MEG');
    end
    
    for run =1:8
    Inputfile = fullfile(WorkingDir,strcat(num2str(subj),'_clock','_run',num2str(run),'_ds_sss_raw.fif'));
    Outputfile = fullfile(WorkingDir,strcat(num2str(subj),'_clock','_run',num2str(run),'_dn_ds_sss_raw.fif'));
    MEG_ICA_denoising_th(Inputfile,Outputfile);
    end
end
end

