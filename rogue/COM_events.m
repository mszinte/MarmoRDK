function COM_events(obj,event)
% ----------------------------------------------------------------------
% COM_events(obj,event)
% ----------------------------------------------------------------------
% Goal of the function :
% Callback function to save the output of NHP smart system interface of 
% Rogue
% ----------------------------------------------------------------------
% Input(s) :
% obj:  port object
% event : mandatory input (useless)
% ----------------------------------------------------------------------
% Output(s):
% change in obj.UserData and print on command window (if asked)
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Last update : 22 / 06 / 2021
% Project :     MarmoRDK
% Version :     3.0
% ----------------------------------------------------------------------

obj.UserData.event_count = obj.UserData.event_count + 1;
obj.UserData.event_value{obj.UserData.event_count} = fgetl(obj);
if exist('GetSecs') %Psychtoolbox mex function
    obj.UserData.event_time{obj.UserData.event_count} = num2str(GetSecs);
else
    obj.UserData.event_time{obj.UserData.event_count} =  datestr(clock);
end

if obj.UserData.print_data
    %
    fprintf(obj.UserData.log_file,'%s output #%i at %s msg: %s\n',  obj.UserData.ID,...
                                                                    obj.UserData.event_count,...
                                                                    obj.UserData.event_time{obj.UserData.event_count},...
                                                                    obj.UserData.event_value{obj.UserData.event_count});
end
set(obj,'UserData',obj.UserData);

end