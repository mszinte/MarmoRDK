% Infra-red sensors
% -----------------
% Settings
IR.ID = 'Infra-Red';                                           % system identification
IR.port_ID = 'COM5';                                           % port id number
IR.print_data = 1;                                             % write logs
IR.event_count = 0;                                            % set event counter to 0
IR.log_file = 1;                                               % log file identifier (1 for command window)
IR.terminator = {'CR', 'CR'};                                  % serial port terminator command

% Commands
IR.check_port_cmd = 'IR1';                                     % check if port is ok => return 'OK'
IR.start_cmd = 'ST1';                                          % start system  => return 'OK'
IR.stop_cmd = 'ST0';                                           % stop system => return 'OK'

% Main
IR.port_obj = serial(IR.port_ID);                              % create serial port object
set(IR.port_obj, 'FlowControl', 'none');                       % define flow control 
set(IR.port_obj, 'Terminator', IR.terminator);                 % define terminator
set(IR.port_obj, 'BytesAvailableFcn',{@COM_events});           % define event function
set(IR.port_obj, 'UserData',IR)                                % define UserData cell containing data
fopen(IR.port_obj);                                            % open the port
write_cmd(IR,IR.check_port_cmd);                               % check if port is ok => return 'OK'
write_cmd(IR,IR.start_cmd);                                    % start system  => return 'OK'
                                                               % Next return change of status of the IRs
                                                               % => return 'IR_0' no sensor are obstructed
                                                               % => return 'IR_1' head sensor is obstructed
                                                               % => return 'IR_2' body sensor is obstructed
                                                               % => return 'IR_3' head and body sensors are obstructed                                      
write_cmd(IR,IR.stop_cmd);                                     % stop system => return 'OK'
fclose(IR.port_obj);                                           % close the port

% Reward
% ------

% Settings
RW.ID = 'Reward';                                              % system identification
RW.port_ID = 'COM6';                                           % port id number
RW.print_data = 1;                                             % write logs
RW.event_count = 0;                                            % set event counter to 0
RW.log_file = 1;                                               % log file identifier (1 for command window)
RW.terminator = {'CR', 'CR'};                                  % serial port terminator command

% Commands
RW.check_port_cmd = 'RV1';                                     % check if port is ok  => return 'OK'

% Main
RW.port_obj = serial(RW.port_ID);                              % create serial port object
set(RW.port_obj, 'FlowControl', 'none');                       % define flow control 
set(RW.port_obj, 'Terminator', RW.terminator);                 % define terminator
set(RW.port_obj, 'BytesAvailableFcn',{@COM_events});           % define event function
set(RW.port_obj, 'UserData', RW)                               % define UserData cell containing data
fopen(RW.port_obj);                                            % open the port

write_cmd(RW,RW.check_port_cmd);                               % check if port is ok => return 'OK'
send_reward(RW, 10);                                           % rotate motor => return 'Done'
fclose(RW.port_obj);                                           % close the port

% RFID
% ----

% Settings
RFID.ID = 'RFID';                                              % system identification
RFID.port_ID = 'COM4';                                         % port id number
RFID.print_data = 1;                                           % write logs
RFID.event_count = 0;                                          % set event counter to 0
RFID.log_file = 1;                                             % log file identifier (1 for command window)
RFID.terminator = {'CR', 'CR'};                                % serial port terminator command

% Commands
RFID.check_port_cmd = 'ST2';                                   % check port => Return 'OK'
RFID.tag_cmd = 'RSD';                                          % start reading Animal Tag Data => return '?1' or tag

% Main
RFID.port_obj = serial(RFID.port_ID);                          % create serial port object
set(RFID.port_obj, 'FlowControl', 'none');                     % define flow control 
set(RFID.port_obj, 'Terminator', RFID.terminator);             % define terminator
set(RFID.port_obj, 'BytesAvailableFcn',{@COM_events});         % define event function
set(RFID.port_obj, 'UserData',RFID)                            % define UserData cell containing data
fopen(RFID.port_obj);                                          % open the port
write_cmd(RFID,RFID.check_port_cmd);                           % check port => Return 'OK'
write_cmd(RFID,RFID.tag_cmd);                                  % start reading Animal Tag Data => return '?1' or tag
fclose(RFID.port_obj);                                         % close the port
