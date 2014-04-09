function [ bad_channels ] = MEG_Clock_reject_channel( input, outfile)
%This function will check for MEG sensor artifacts for each trial, and reject
%channels that have more than 15 trials where peak-to-peak amplitude exceeds
%a preset threshold, or if the channel is flat. Bad channel list will be written out.
%
%Usage: [ bad_channels ] = MEG_reject_trial( input, outfile )
%
%   input - fiff file to be loaded
%
%Last update 4.09.2014 by Kai

%Update log
%need to think about how to set threshold



%% setup
%thresholds for bad trials;
MAGthresh = 5e-11;
GRADthresh = 5e-10;
varthresh = 1e-50;

Thresholds = {  ...
    % cRegexp        cThres
    {'M*1',          MAGthresh  }  % magnetometers
    {'M*2',          GRADthresh }  % gradiometers, longitude or latitude
    {'M*3',          GRADthresh }  % gradiometers, longitude or latitude
    };

%% routine to read event code and define epochs, maybe fieldtrip?

% use fieldtrip routine to read in data and define trials
cfg=[];
cfg.dataset = input;
cfg.trialdef.eventtype = 'STI102'; %read in responses (not STI101
cfg.trialdef.prestim = 4; %four seconds before button press
cfg.trialdef.poststim = 1; %one second after button press
cfg.traildef.eventvalue = 2; %index finger
cfg = ft_definetrial(cfg);
cfg.channel = {'MEG'};
cfg.lpfreq = 40; %get rid of HPI noisesize(
data = ft_preprocessing(cfg);
%[output, events] = MEG_load_sensor_trial_old(input,eventfile, prestim, poststim);
%[h]=fiff_setup_read_raw(input);


%% detect bad trials
bad_triallist = [];
bad_channels = [];
PP=[];
for t = 1:length(Thresholds)
    cRegexp = Thresholds{t}{1};
    cThres  = Thresholds{t}{2};
    
    % get channels that match the list
    channel_list = ft_channelselection(cRegexp,data.label);
    
    %loop through channel
    for n = 1:size(channel_list,1)
        r = find(strcmp(data.label,channel_list(n)));
        bad_triallist = [];
        
        %loop through trial
        for i = 1:size(data.trial,2)
            maxi = max(data.trial{i}(r,:));
            mini = min(data.trial{i}(r,:));
            peaktopeak = maxi-mini; %calculate peak to peak change
            PP=[PP,peaktopeak];
            variance = var(data.trial{i}(r,:));
            if peaktopeak > cThres
                bad_triallist = [bad_triallist, i];
                
            end
            if variance < varthresh
                %variance;
                bad_triallist = [bad_triallist, i];
                %channel_list(n);
            end
        end
        bad_triallist = unique(bad_triallist);
        if length(bad_triallist)>15
            bad_channels = [bad_channels;channel_list(n)];
        end
    end
    
end

%% wrote
bad_channels = unique(bad_channels);
fid=fopen(outfile,'wt');

for b = 1:size(bad_channels,1)
    fprintf(fid, '%s\n',cell2mat(bad_channels(b)));
end
fclose(fid);
end

