function [cmX,cmY] = pix2cm(pix,scr)
% ----------------------------------------------------------------------
% [cmX,cmY] = pix2cm(pix,scr)
% ----------------------------------------------------------------------
% Goal of the function :
% Convert pix in cm ( x and y )
% ----------------------------------------------------------------------
% Input(s) :
% pix   = size in pixel                                ex : cm = 10
% scr   = screen configurations : scr.scr_sizeX (pix)  ex : = 1024
%                                 scr.scr_sizeY (pix)  ex : = 768
%                                 scr.disp_sizeX (mm)  ex : = 400
%                                 scr.disp_sizeY (mm)  ex : = 300
% ----------------------------------------------------------------------
% Output(s):
% cmX  = size in cm(X)                             ex : = 35
% cmY  = size in cm(Y)                             ex : = 25.35  
% ----------------------------------------------------------------------
% Fuction created by Martin SZINTE (martin.szinte@gmail.com)
% Last edit : 30 / 10 / 2008
% Project : All
% Version : 1.0
% ----------------------------------------------------------------------
pix_by_mmX = scr.scr_sizeX/scr.disp_sizeX;
pix_by_mmY = scr.scr_sizeY/scr.disp_sizeY;
cmX = pix./pix_by_mmX./10;
cmY = pix./pix_by_mmY./10;
end