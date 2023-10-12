function [mc]=chairConfig(const)
% ----------------------------------------------------------------------
% [mc]=chairConfig(const)
% ----------------------------------------------------------------------
% Goal of the function :
% Configurations of the Rogue Research monkey chair
% ----------------------------------------------------------------------
% Input(s) :
% const : struct containing constant configurations
% ----------------------------------------------------------------------
% Output(s):
% mc : struct containing mcant configurations
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Last update : 23 / 06 / 2021
% Project :     MarmoRDK
% Version :     3.0
% ----------------------------------------------------------------------

fprintf(1,'\n\tConnecting Rogue Research monkey chair...\n');

% Infra-red sensors
mc.IR.ID = 'Infra-red';                                                 % system identification
mc.IR.port_ID = 'COM5';                                                 % port id number
mc.IR.print_data = 1;                                                   % write logs
mc.IR.event_count = 0;                                                  % set event counter to 0
mc.IR.log_file = const.log_fid;                                         % log file identifier (1 for command window)
mc.IR.terminator = {'CR', 'CR'};                                        % serial port terminator command
mc.IR.check_port_cmd = 'IR1';                                           % check if port is ok => return 'OK'
mc.IR.start_cmd = 'ST1';                                                % start system  => return 'OK'
mc.IR.stop_cmd = 'ST0';                                                 % stop system => return 'OK'

if const.chair 
    mc.IR.port_obj = serial(mc.IR.port_ID);                             % create serial port object
    set(mc.IR.port_obj, 'FlowControl', 'none');                         % define flow control
    set(mc.IR.port_obj, 'Terminator', mc.IR.terminator);                % define terminator
    set(mc.IR.port_obj, 'BytesAvailableFcn',{@COM_events});             % define event function
    set(mc.IR.port_obj, 'UserData',mc.IR)                               % define UserData cell containing data
  
    fopen(mc.IR.port_obj);                                              % open the port
    pause(2);
    
    write_cmd(mc.IR,mc.IR.check_port_cmd);                              % check if port is ok => return 'OK'
    pause(0.5);
    if strcmp(mc.IR.port_obj.UserData.event_value{1},'OK') == 0
        error('Error with Infra-red port connection');
    end
    
    write_cmd(mc.IR,mc.IR.start_cmd);                                   % start system  => return 'OK'
    pause(0.5);
    if strcmp(mc.IR.port_obj.UserData.event_value{2},'OK') == 0
        error('Error with Infra-red system starting mode');
    end
end

% Reward
mc.RW.ID = 'Reward';                                                    % system identification
mc.RW.port_ID = 'COM6';                                                 % port id number
mc.RW.print_data = 1;                                                   % write logs
mc.RW.event_count = 0;                                                  % set event counter to 0
mc.RW.log_file = const.log_fid;                                         % log file identifier (1 for command window)
mc.RW.terminator = {'CR', 'CR'};                                        % serial port terminator command
mc.RW.check_port_cmd = 'RV1';                                           % check if port is ok  => return 'OK'

if const.chair 
    mc.RW.port_obj = serial(mc.RW.port_ID);                             % create serial port object
    set(mc.RW.port_obj, 'FlowControl', 'none');                         % define flow control
    set(mc.RW.port_obj, 'Terminator', mc.RW.terminator);                % define terminator
    set(mc.RW.port_obj, 'BytesAvailableFcn',{@COM_events});             % define event function
    set(mc.RW.port_obj, 'UserData', mc.RW)                              % define UserData cell containing data
    fopen(mc.RW.port_obj);                                              % open the port
    pause(2);
    
    write_cmd(mc.RW,mc.RW.check_port_cmd);                              % check if port is ok => return 'OK'
    pause(0.5);
    if strcmp(mc.RW.port_obj.UserData.event_value{1},'OK') == 0
        error('Error with Reward port connection');
    end
end

% RFID
% ----
mc.RFID.ID = 'RFID';                                                    % system identification
mc.RFID.port_ID = 'COM4';                                               % port id number
mc.RFID.print_data = 1;                                                 % write logs
mc.RFID.event_count = 0;                                                % set event counter to 0
mc.RFID.log_file = const.log_fid;                                       % log file identifier (1 for command window)
mc.RFID.terminator = {'CR', 'CR'};                                      % serial port terminator command
mc.RFID.check_port_cmd = 'ST2';                                         % check port => Return 'OK'
mc.RFID.tag_cmd = 'RSD';                                                % start reading Animal Tag Data => return '?1' or tag

if const.chair
    mc.RFID.port_obj = serial(mc.RFID.port_ID);                         % create serial port object
    set(mc.RFID.port_obj, 'FlowControl', 'none');                       % define flow control
    set(mc.RFID.port_obj, 'Terminator', mc.RFID.terminator);            % define terminator
    set(mc.RFID.port_obj, 'BytesAvailableFcn',{@COM_events});           % define event function
    set(mc.RFID.port_obj, 'UserData',mc.RFID)                           % define UserData cell containing data
    fopen(mc.RFID.port_obj);                                            % open the port
    pause(2);
    
    write_cmd(mc.RFID,mc.RFID.check_port_cmd);                          % check port => Return 'OK'pause(0.5);
    pause(0.5)
    if strcmp(mc.RFID.port_obj.UserData.event_value{1},'OK') == 0
        error('Error with RFID port connection');
    end
    
    write_cmd(mc.RFID,mc.RFID.tag_cmd);                                % start reading Animal Tag Data => return '?1' or tag
    pause(0.5)
    if strcmp(mc.RFID.port_obj.UserData.event_value{2},'?1') == 0
        error('Error with RFID system starting mode');
    end
end

end