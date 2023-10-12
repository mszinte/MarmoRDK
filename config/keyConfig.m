function [my_key]=keyConfig
% ----------------------------------------------------------------------
% [my_key]=keyConfig
% ----------------------------------------------------------------------
% Goal of the function :
% Unify key names and define structure containing each key names
% ----------------------------------------------------------------------
% Input(s) :
% ----------------------------------------------------------------------
% Output(s):
% my_key : structure containing keyboard configurations
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Last update : 28 / 06 / 2021
% Project :     MarmoRDK
% Version :     3.0
% ----------------------------------------------------------------------

KbName('UnifyKeyNames');

my_key.escapeVal        =   'escape';               % escape button
my_key.escape           =   KbName(my_key.escapeVal);

my_key.keyboard_idx     =   GetKeyboardIndices;
for keyb = 1:size(my_key.keyboard_idx,2)
    KbQueueCreate(my_key.keyboard_idx(keyb));
    KbQueueFlush(my_key.keyboard_idx(keyb));
    KbQueueStart(my_key.keyboard_idx(keyb));
end

[~,keyCodeMat]   = KbQueueCheck(my_key.keyboard_idx(1));
my_key.keyCodeNum  = numel(keyCodeMat);

end