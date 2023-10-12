function [scr]=scrConfig(const)
% ----------------------------------------------------------------------
% [scr]=scrConfig(const)
% ----------------------------------------------------------------------
% Goal of the function :
% Define configuration relative to the screen
% ----------------------------------------------------------------------
% Input(s) :
% const : struct containing constant configurations
% ----------------------------------------------------------------------
% Output(s):
% scr : struct containing screen configurations
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Last update : 22 / 06 / 2021
% Project :     MarmoRDK
% Version :     3.0
% ----------------------------------------------------------------------

% Number of the exp screen :
scr.all                 =   Screen('Screens');
scr.scr_num             =   max(scr.all);

% Screen resolution (pixel) :
[scr.scr_sizeX, scr.scr_sizeY]...
                        =   Screen('WindowSize', scr.scr_num);
if (scr.scr_sizeX ~= const.desiredRes(1) || scr.scr_sizeY ~= const.desiredRes(2)) && const.expStart
    error('Incorrect screen resolution => Please restart the program after changing the resolution to [%i,%i]',const.desiredRes(1),const.desiredRes(2));
end
scr.rect                =   [0,0,scr.scr_sizeX,scr.scr_sizeY];

% Settings Noritake screen
scr.disp_sizeX          =   85.92;
scr.disp_sizeY          =   154.08;
scr.dist                =   3;

% Pixels size :
scr.clr_depth = Screen('PixelSize', scr.scr_num);

% Frame rate : (fps)
scr.frame_duration      =   1/(Screen('FrameRate',scr.scr_num));
if scr.frame_duration == inf
    scr.frame_duration  = 1/const.desiredFD;
elseif scr.frame_duration == 0
    scr.frame_duration  = 1/const.desiredFD;
end

% Frame rate : (hertz)
scr.hz                  =   1/(scr.frame_duration);

if const.expStart == 0
    Screen('Preference','VisualDebugLevel', 0);
    Screen('Preference','SyncTestSettings', 0.01, 50, 0.25);
elseif const.expStart == 1
    Screen('Preference','VisualDebugLevel', 0);
    Screen('Preference','SyncTestSettings', 0.01, 50, 0.25);
    Screen('Preference','SuppressAllWarnings', 1);
    Screen('Preference','Verbosity', 0);
end

% Center of the screen :
scr.x_mid               =   (scr.scr_sizeX/2.0);
scr.y_mid               =   (scr.scr_sizeY/2.0);
scr.mid                 =   [scr.x_mid,scr.y_mid];

end