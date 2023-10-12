function send_reward(port, quarter_rev)
% ----------------------------------------------------------------------
% send_reward(port, quarter_rev)
% ----------------------------------------------------------------------
% Goal of the function :
% Function to give a reward with the reward system of Rogue
% smart system interface
% ----------------------------------------------------------------------
% Input(s) :
% port:  port structure
% quarter_rev : quarters of revolution of the motor (e.g. 4 = 1 turn)
% ----------------------------------------------------------------------
% Output(s):
% none
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Last update : 22 / 06 / 2021
% Project :     MarmoRDK
% Version :     3.0
% ----------------------------------------------------------------------
string_cmd = sprintf('R_%i_1E',quarter_rev);
write_cmd(port,string_cmd)

end