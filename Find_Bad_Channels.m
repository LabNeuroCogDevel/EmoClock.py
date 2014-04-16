[~,hostname] = system('hostname');
hostname = hostname(hostname ~= 10);

if strcmp('wallace.wpic.upmc.edu',hostname)
   subj_dir = '/raid/r3/p2/Luna/Multimodal/Clock';  
end

Subjects = [10997 11243 11246 11252 11253 11255 11258 11262 11263];


for s = 1:length(Subjects)
   working_dir = fullfile(subj_dir,num2str(Subjects(s)),'MEG');
   for run = 1:8
      input = fullfile(working_dir, strcat(num2str(Subjects(s)),'_clock_run', num2str(run),'_raw.fif')); 
      output = fullfile(working_dir, strcat(num2str(Subjects(s)),'_clock_bad_run', num2str(run),'.txt'));
      [~] = MEG_Clock_reject_channel(input,output);
      
   end 
end