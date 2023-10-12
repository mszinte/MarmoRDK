function [const]=sbjConfig(const)
% ----------------------------------------------------------------------
% [const]=sbjConfig(const)
% ----------------------------------------------------------------------
% Goal of the function :
% Define subject configurations (initials, gender...)
% ----------------------------------------------------------------------
% Input(s) :
% const : struct containing constant configurations
% ----------------------------------------------------------------------
% Output(s):
% const : struct containing constant configurations
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Last update : 22 / 06 / 2021
% Project :     MarmoRDK
% Version :     3.0
% ----------------------------------------------------------------------

% Define all subjects folders
for sjctNum = 1:size(const.marmo_ID,2)
    if sjctNum > 9
        const.sjct{sjctNum} = sprintf('sub-%i',sjctNum);
    else
        const.sjct{sjctNum} = sprintf('sub-0%i',sjctNum);
    end
end

if const.expStart == 0; const.sesNum = 1;
else const.sesNum = input(sprintf('\n\tSession number: '));
end

if isempty(const.sesNum)
    error('Incorrect run number');
end

if const.sesNum > 9
    const.session = sprintf('ses-%i',const.sesNum);
else
    const.session = sprintf('ses-0%i',const.sesNum);
end

if const.expStart == 0; const.runNum = 1; 
else  const.runNum = input(sprintf('\n\tRun number: '));
end

if isempty(const.runNum)
    error('Incorrect run number');
end

if const.runNum > 9
    const.run_txt   =  sprintf('run-%i',const.runNum);
else
    const.run_txt   =  sprintf('run-0%i',const.runNum);
end

if const.training
    const.task_txt = sprintf('Train_%i',const.training_step);
else
    const.task_txt = sprintf('RDK_Disc');
end
fprintf(1,'\n\tTask: %s\n',const.task_txt);


const.session_start = datetime('now','Format','d-MMM-y HH:mm:ss');


end