function [ bad_channels ] = MEG_Clock_reject_channel( input, outfile)
%This function will check for bad channels by doing a FFT analysis on each
%channels timeseries, and flag channels with high frequency noise.
%
%Usage: [ bad_channels ] = MEG_reject_trial( input, outfile )
%   
%   input - fiff file to be loaded
%   outfile - text file with list of bad channels
%
%Last update 4.15.2014 by Kai

%Update log
%need to think about how to set threshold



%% setup
%thresholds for bad trials;
% MAGthresh = 5e-10;
% GRADthresh = 5e-9;
% varthresh = 5e-22;
% 
% Thresholds = {  ...
%     % cRegexp        cThres
%     {'M*1',          MAGthresh  }  % magnetometers
%     {'M*2',          GRADthresh }  % gradiometers, longitude or latitude
%     {'M*3',          GRADthresh }  % gradiometers, longitude or latitude
%     };

%% routine to read event code and define epochs, maybe fieldtrip?

% use fieldtrip routine to read in data
cfg=[];
cfg.dataset = input;
%cfg.trialdef.eventtype = 'STI102'; %read in responses (not STI101
%cfg.trialdef.prestim = 5; %four seconds before button press
%cfg.trialdef.poststim = 2; %one second after button press
%cfg.traildef.eventvalue = 2; %index finger
%cfg.trialdef.triallength = 'inf'
%cfg.trialdef.ntrials = '1';
%cfg = ft_definetrial(cfg);
cfg.channel = {'MEG'};
cfg.lpfilter = 'yes'
cfg.lpfreq = 100; %get rid of HPI noise
cfg.dftfreq = [60];% get rid of line noise
cfg.dftfilter = 'yes';
data = ft_preprocessing(cfg);

%% detect bad channels with fft
% do frequency analysis
cfg =[];
cfg.method ='mtmfft';
cfg.output ='pow';
%cfg.tapsmofrq = 4;
cfg.foi = 1:98;
cfg.pad    = 'maxperlen';
cfg.taper  = 'hanning';
[freq] = ft_freqanalysis(cfg, data);

a=zscore(freq.powspctrm(:,60:98));
[i,~]=find(abs(a)>7);
bad_channels = freq.label(unique(i));
%i = unique(i);

a=zscore(freq.powspctrm(:,1:59));
[i,~]=find(abs(a)>10);
bad_channels = [bad_channels;freq.label(unique(i))];
bad_channels = unique(bad_channels);

% channel_list = ft_channelselection('MEGMAG',data.label)
% r=[];
% for n = 1:size(channel_list,1)
%     r = [r,find(strcmp(data.label,channel_list(n)))]; 
% end
% a=zscore(freq.powspctrm(r,10:80));
% [i,~]=find((a)>5)
% channel_list(unique(i))
%[output, events] = MEG_load_sensor_trial_old(input,eventfile, prestim, poststim);
%[h]=fiff_setup_read_raw(input);

% 
% 
%  bad_triallist = [];
% % bad_channels = [];
% % PP=[];
% for t = 2:3
%     cRegexp = Thresholds{t}{1};
%     cThres  = Thresholds{t}{2};
%     
%     % get channels that match the list
%     channel_list = ft_channelselection(cRegexp,data.label);
%     
%     %loop through channel
%     for n = 1:size(channel_list,1)
%         r = find(strcmp(data.label,channel_list(n)));
%         bad_triallist = [];
%         
%         %loop through trial
%         for i = 1:size(data.trial,2)
%             %maxi = max(data.trial{i}(r,:));
%             %mini = min(data.trial{i}(r,:));
%             %peaktopeak = maxi-mini; %calculate peak to peak change
%             %PP=[PP,peaktopeak];
%             variance = var(data.trial{i}(r,:))
%             %if peaktopeak > cThres
%             %    bad_triallist = [bad_triallist, i];
%                 
%             %end
%             if variance < varthresh
%                 %variance;
%                 bad_triallist = [bad_triallist, i];
%                 %channel_list(n);
%             end
%         end
%         bad_triallist = unique(bad_triallist);
%         if length(bad_triallist)>31
%             bad_channels = [bad_channels;channel_list(n)];
%         end
%     end
%     
% end

%% wrote

%1212 is always bad
bad_channels = [bad_channels; 'MEG1212'];s
bad_channels = unique(bad_channels);
fid=fopen(outfile,'wt');

for b = 1:size(bad_channels,1)
    fprintf(fid, '%s\n',cell2mat(bad_channels(b)));
end
fclose(fid);
end

