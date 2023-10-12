function [const] = dirSaveFile(const)
% ----------------------------------------------------------------------
% [const] = dirSaveFile(const)
% ----------------------------------------------------------------------
% Goal of the function :
% Make directory and saving files name and fid.
% ----------------------------------------------------------------------
% Input(s) :
% const : struct containing constant configurations
% ----------------------------------------------------------------------
% Output(s):
% const : struct containing constant configurations
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Last update : 02 / 07 / 2021
% Project :     MarmoRDK
% Version :     3.0
% ----------------------------------------------------------------------

for sjctNum = 1:size(const.marmo_ID,2)
    % Create data directory
    if ~isfolder(sprintf('data/%s/%s/func/',const.sjct{sjctNum},const.session))
        mkdir(sprintf('data/%s/%s/func/',const.sjct{sjctNum},const.session))
    end
    
    % Define directory
    const.dat_output_file = sprintf('data/%s/%s/func/%s_%s_task-%s_%s',const.sjct{sjctNum},...
                                        const.session,const.sjct{sjctNum},const.session,const.task_txt,const.run_txt);
                                        
    % Behavioral data
    const.behav_file{sjctNum} = sprintf('%s_events.tsv',const.dat_output_file);
    if const.expStart
        if exist(const.behav_file{sjctNum},'file')
            aswErase = upper(strtrim(input(sprintf('\n\t[%s] allready exist, do you want to erase it ? (Y or N): ',const.behav_file{sjctNum}),'s')));
            if upper(aswErase) == 'N'
                error('Please restart the program with correct input.')
            elseif upper(aswErase) == 'Y'
            else
                error('Incorrect input => Please restart the program with correct input.')
            end
        end
    end
    const.behav_file_fid{sjctNum} = fopen(const.behav_file{sjctNum},'w');
end

% Define add saving folder
if ~isfolder('data/add/')
    mkdir('data/add/')
end
const.log_file = sprintf('data/add/%s_task-%s_%s_log.txt',const.session,const.task_txt,const.run_txt);
const.log_fid = fopen(const.log_file,'w');
fprintf(const.log_fid,'session_start : %s\n', const.session_start);

% Define .mat saving file
const.mat_file = sprintf('data/add/%s_task-%s_%s.mat',const.session,const.task_txt,const.run_txt);

% Define stimulis .mat file
const.stim_file = 'stim/rdk.mat';

end