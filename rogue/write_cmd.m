function write_cmd(port,cmd_str)
% ----------------------------------------------------------------------
% write_cmd(port,cmd_str)
% ----------------------------------------------------------------------
% Goal of the function :
% Send a command to the Rogue Smart System Interface and print it in
% command window or log file
% ----------------------------------------------------------------------
% Input(s) :
% port_struct:  port structure (e.g. RFID)
% cmd_str : command to send (e.g. 'ST1') without the carriage return
% ----------------------------------------------------------------------
% Output(s):
% action + logging
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Last update : 22 / 06 / 2021
% Project :     MarmoRDK
% Version :     3.0
% ----------------------------------------------------------------------

cmd_ascii = [uint8(cmd_str),13];
fwrite(port.port_obj,cmd_ascii);

if exist('GetSecs') %Psychtoolbox mex function
    log_time = num2str(GetSecs);
else
    log_time = datestr(clock);
end

fprintf(port.log_file,'%s input at %s msg: %s\n', port.ID, log_time, cmd_str);

end